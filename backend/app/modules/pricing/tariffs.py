"""Versioned tariffs: creating a new version closes the previous one."""

import uuid
from datetime import UTC, datetime

from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.pricing.models import Tariff
from app.modules.pricing.schemas import TariffCreate
from app.modules.regions.models import Region


async def list_tariffs(session: AsyncSession, region_id: uuid.UUID) -> list[Tariff]:
    result = await session.execute(
        select(Tariff).where(Tariff.region_id == region_id).order_by(Tariff.valid_from.desc())
    )
    return list(result.scalars())


async def active_tariff(
    session: AsyncSession, region_id: uuid.UUID, at: datetime | None = None
) -> Tariff | None:
    at = at or datetime.now(UTC)
    result = await session.execute(
        select(Tariff)
        .where(
            Tariff.region_id == region_id,
            Tariff.valid_from <= at,
            or_(Tariff.valid_to.is_(None), Tariff.valid_to > at),
        )
        .order_by(Tariff.valid_from.desc())
        .limit(1)
    )
    return result.scalar_one_or_none()


async def create_tariff(
    session: AsyncSession, region_id: uuid.UUID, data: TariffCreate, created_by: str | None
) -> Tariff:
    # Lock the region row so two admins cannot create overlapping versions at once.
    region = await session.get(Region, region_id, with_for_update=True)
    if region is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Region not found")
    if data.minimum_fare < data.base_fare:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT,
            "Cena minimalna nie może być niższa niż opłata startowa",
        )
    valid_from = data.valid_from or datetime.now(UTC)
    if valid_from.tzinfo is None:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT, "valid_from musi zawierać strefę czasową"
        )

    latest = (
        await session.execute(
            select(Tariff)
            .where(Tariff.region_id == region_id)
            .order_by(Tariff.valid_from.desc())
            .limit(1)
        )
    ).scalar_one_or_none()
    if latest is not None:
        if valid_from <= latest.valid_from:
            raise HTTPException(
                status.HTTP_409_CONFLICT,
                "Nowa wersja cennika musi zaczynać się po początku obecnej wersji",
            )
        latest.valid_to = valid_from

    tariff = Tariff(
        region_id=region_id,
        valid_from=valid_from,
        valid_to=None,
        created_by=created_by,
        **data.model_dump(exclude={"valid_from"}),
    )
    session.add(tariff)
    await session.commit()
    await session.refresh(tariff)
    return tariff

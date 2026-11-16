"""Idempotent demo data: two neighbouring municipalities with different tariffs.

Polygons are simplified (rectangles sharing a border at lng 20.15) — good enough for the demo:
a pickup in Wieliczka is priced with Wieliczka's tariff, one in Niepołomice with its own.
Running the seed again changes nothing (regions matched by name, tariff only if none exists).
"""

import logging
from dataclasses import dataclass
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.pricing import tariffs
from app.modules.pricing.models import Tariff
from app.modules.pricing.schemas import TariffCreate
from app.modules.regions import service as regions_service
from app.modules.regions.models import Region
from app.modules.regions.schemas import RegionCreate

log = logging.getLogger(__name__)


def _rectangle(west: float, south: float, east: float, north: float) -> dict[str, Any]:
    ring = [[west, south], [east, south], [east, north], [west, north], [west, south]]
    return {"type": "Polygon", "coordinates": [ring]}


@dataclass(frozen=True)
class SeedRegion:
    name: str
    area: dict[str, Any]
    tariff: TariffCreate


SEED_REGIONS = (
    SeedRegion(
        name="Gmina Wieliczka",
        area=_rectangle(19.98, 49.93, 20.15, 50.03),
        tariff=TariffCreate(
            base_fare=800,
            per_km=300,
            per_minute=50,
            minimum_fare=1500,
            night_multiplier_percent=120,
            commission_percent=10,
        ),
    ),
    SeedRegion(
        name="Gmina Niepołomice",
        area=_rectangle(20.15, 49.98, 20.32, 50.09),
        tariff=TariffCreate(
            base_fare=600,
            per_km=350,
            per_minute=40,
            minimum_fare=1200,
            night_multiplier_percent=125,
            commission_percent=12,
        ),
    ),
)


async def seed(session: AsyncSession) -> None:
    for item in SEED_REGIONS:
        region = (
            await session.execute(select(Region).where(Region.name == item.name))
        ).scalar_one_or_none()
        if region is None:
            region = await regions_service.create_region(
                session, RegionCreate(name=item.name, area=item.area)
            )
            log.info("seed: created region %s", item.name)
        has_tariff = (
            await session.execute(select(Tariff.id).where(Tariff.region_id == region.id).limit(1))
        ).first()
        if has_tariff is None:
            await tariffs.create_tariff(session, region.id, item.tariff, created_by="seed")
            log.info("seed: created tariff for %s", item.name)

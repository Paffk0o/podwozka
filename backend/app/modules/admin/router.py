"""Admin panel endpoints (role `admin`, login via Entra ID brokered by Keycloak)."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from pydantic import Field
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.schemas import ApiModel, Page
from app.core.db import SessionDep
from app.core.errors import Responses
from app.core.keycloak_admin import IdentityAdmin, get_identity_admin_or_503
from app.core.security import AdminDep
from app.modules.drivers import service as drivers_service
from app.modules.drivers.models import DriverProfile as DriverProfileRow
from app.modules.drivers.schemas import DriverProfile, DriverStatus
from app.modules.drivers.storage import STORAGE_UNAVAILABLE, DocumentStorage, get_storage_or_503
from app.modules.pricing import tariffs
from app.modules.pricing.schemas import Tariff, TariffCreate
from app.modules.regions import service as regions_service
from app.modules.regions.schemas import RegionCreate, RegionDetail, RegionUpdate
from app.modules.rides import service as rides_service
from app.modules.rides.schemas import RidePage, RideStatus
from app.modules.users.models import User

router = APIRouter(prefix="/admin", tags=["admin"])


class AdminDriver(DriverProfile):
    full_name: str | None
    email: str | None
    phone: str | None
    submitted_at: datetime | None


class AdminDriverPage(Page[AdminDriver]):
    pass


class ReasonRequest(ApiModel):
    reason: str = Field(min_length=3, max_length=500)


class SignedUrl(ApiModel):
    url: str
    expires_at: datetime


# --- Drivers ---

DRIVER_NOT_FOUND: Responses = {404: {"description": "Kierowca / wniosek nie istnieje"}}
WRONG_STATE: Responses = {409: {"description": "Niedozwolone w obecnym statusie wniosku"}}


async def _admin_driver(session: AsyncSession, profile: DriverProfileRow) -> AdminDriver:
    base = await drivers_service.to_schema(session, profile)
    user = await session.get(User, profile.user_id)
    return AdminDriver(
        **base.model_dump(),
        full_name=user.full_name if user else None,
        email=user.email if user else None,
        phone=user.phone if user else None,
        submitted_at=profile.submitted_at,
    )


@router.get("/drivers", response_model=AdminDriverPage, summary="Kierowcy / wnioski")
async def admin_list_drivers(
    principal: AdminDep,
    session: SessionDep,
    status_filter: Annotated[DriverStatus | None, Query(alias="status")] = None,
    region_id: Annotated[UUID | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> AdminDriverPage:
    query = select(DriverProfileRow)
    if status_filter is not None:
        query = query.where(DriverProfileRow.status == status_filter)
    if region_id is not None:
        query = query.where(DriverProfileRow.region_id == region_id)
    total = (await session.execute(select(func.count()).select_from(query.subquery()))).scalar_one()
    rows = await session.execute(
        query.order_by(
            DriverProfileRow.submitted_at.desc().nulls_last(), DriverProfileRow.created_at.desc()
        )
        .limit(limit)
        .offset(offset)
    )
    items = [await _admin_driver(session, p) for p in rows.scalars()]
    return AdminDriverPage(items=items, total=total, limit=limit, offset=offset)


@router.get(
    "/drivers/{user_id}",
    response_model=AdminDriver,
    summary="Szczegóły kierowcy",
    responses=DRIVER_NOT_FOUND,
)
async def admin_get_driver(principal: AdminDep, session: SessionDep, user_id: str) -> AdminDriver:
    return await _admin_driver(session, await drivers_service.require_profile(session, user_id))


@router.get(
    "/drivers/{user_id}/documents/{document_id}/view-url",
    response_model=SignedUrl,
    summary="Krótkotrwały link do podglądu dokumentu",
    responses={
        404: {"description": "Dokument nie istnieje"},
        409: {"description": "Plik nie został jeszcze wysłany"},
        **STORAGE_UNAVAILABLE,
    },
)
async def admin_get_document_url(
    principal: AdminDep,
    session: SessionDep,
    storage: Annotated[DocumentStorage, Depends(get_storage_or_503)],
    user_id: str,
    document_id: UUID,
) -> SignedUrl:
    url, expires_at = await drivers_service.document_view_url(
        session, user_id, document_id, storage
    )
    return SignedUrl(url=url, expires_at=expires_at)


@router.post(
    "/drivers/{user_id}/approve",
    response_model=AdminDriver,
    summary="Zatwierdź kierowcę (nadaje rolę driver w Keycloaku)",
    responses={
        **DRIVER_NOT_FOUND,
        **WRONG_STATE,
        502: {"description": "Keycloak nie nadał roli"},
        503: {"description": "Konto serwisowe Keycloaka nie jest skonfigurowane"},
    },
)
async def admin_approve_driver(
    principal: AdminDep,
    session: SessionDep,
    identity: Annotated[IdentityAdmin, Depends(get_identity_admin_or_503)],
    user_id: str,
) -> AdminDriver:
    profile = await drivers_service.approve(session, user_id, identity)
    return await _admin_driver(session, profile)


@router.post(
    "/drivers/{user_id}/reject",
    response_model=AdminDriver,
    summary="Odrzuć wniosek",
    responses={**DRIVER_NOT_FOUND, **WRONG_STATE},
)
async def admin_reject_driver(
    principal: AdminDep, session: SessionDep, user_id: str, body: ReasonRequest
) -> AdminDriver:
    profile = await drivers_service.reject(session, user_id, body.reason)
    return await _admin_driver(session, profile)


@router.post(
    "/drivers/{user_id}/suspend",
    response_model=AdminDriver,
    summary="Zawieś kierowcę",
    responses={**DRIVER_NOT_FOUND, **WRONG_STATE},
)
async def admin_suspend_driver(
    principal: AdminDep, session: SessionDep, user_id: str, body: ReasonRequest
) -> AdminDriver:
    profile = await drivers_service.suspend(session, user_id, body.reason)
    return await _admin_driver(session, profile)


# --- Regions & tariffs ---

NOT_FOUND: Responses = {404: {"description": "Region nie istnieje"}}
INVALID_AREA: Responses = {422: {"description": "Niepoprawna granica GeoJSON"}}
DUPLICATE: Responses = {409: {"description": "Region o tej nazwie / TERYT już istnieje"}}


@router.get("/regions", response_model=list[RegionDetail], summary="Wszystkie regiony")
async def admin_list_regions(principal: AdminDep, session: SessionDep) -> list[RegionDetail]:
    return await regions_service.list_all_detail(session)


@router.post(
    "/regions",
    response_model=RegionDetail,
    status_code=status.HTTP_201_CREATED,
    summary="Dodaj region (granica GeoJSON)",
    responses={**INVALID_AREA, **DUPLICATE},
)
async def admin_create_region(
    principal: AdminDep, session: SessionDep, body: RegionCreate
) -> RegionDetail:
    region = await regions_service.create_region(session, body)
    return await regions_service.to_detail(session, region)


@router.patch(
    "/regions/{region_id}",
    response_model=RegionDetail,
    summary="Edytuj region",
    responses={**NOT_FOUND, **INVALID_AREA, **DUPLICATE},
)
async def admin_update_region(
    principal: AdminDep, session: SessionDep, region_id: UUID, body: RegionUpdate
) -> RegionDetail:
    region = await regions_service.update_region(session, region_id, body)
    return await regions_service.to_detail(session, region)


@router.get(
    "/regions/{region_id}/tariffs",
    response_model=list[Tariff],
    summary="Historia cenników regionu (najnowszy pierwszy)",
    responses=NOT_FOUND,
)
async def admin_list_tariffs(
    principal: AdminDep, session: SessionDep, region_id: UUID
) -> list[Tariff]:
    await regions_service.require_region(session, region_id)
    return [Tariff.model_validate(t) for t in await tariffs.list_tariffs(session, region_id)]


@router.post(
    "/regions/{region_id}/tariffs",
    response_model=Tariff,
    status_code=status.HTTP_201_CREATED,
    summary="Nowa wersja cennika (zamyka poprzednią)",
    responses={
        **NOT_FOUND,
        409: {"description": "valid_from nie jest późniejsze niż początek obecnej wersji"},
    },
)
async def admin_create_tariff(
    principal: AdminDep, session: SessionDep, region_id: UUID, body: TariffCreate
) -> Tariff:
    tariff = await tariffs.create_tariff(session, region_id, body, created_by=principal.sub)
    return Tariff.model_validate(tariff)


# --- Rides ---


@router.get(
    "/rides",
    response_model=RidePage,
    summary="Kursy (filtry)",
    description="Najnowsze pierwsze. `date_from`/`date_to` dotyczą chwili zamówienia "
    "(`requested_at`, przedział [od, do)) i muszą zawierać strefę czasową. Widok z danymi "
    "pasażera i kierowcy, także rozliczenie gotówki (`payment_status`).",
    responses={422: {"description": "Data bez strefy czasowej albo date_to przed date_from"}},
)
async def admin_list_rides(
    principal: AdminDep,
    session: SessionDep,
    region_id: Annotated[UUID | None, Query()] = None,
    status_filter: Annotated[RideStatus | None, Query(alias="status")] = None,
    date_from: Annotated[datetime | None, Query()] = None,
    date_to: Annotated[datetime | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> RidePage:
    return await rides_service.list_all_rides(
        session, region_id, status_filter, date_from, date_to, limit, offset
    )

"""Admin panel endpoints (role `admin`, login via Entra ID brokered by Keycloak)."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query, status
from pydantic import Field

from app.common.schemas import ApiModel, Page
from app.core.db import SessionDep
from app.core.errors import STUB_RESPONSES, Responses, not_implemented
from app.core.security import AdminDep
from app.modules.drivers.schemas import DriverProfile, DriverStatus
from app.modules.pricing import tariffs
from app.modules.pricing.schemas import Tariff, TariffCreate
from app.modules.regions import service as regions_service
from app.modules.regions.schemas import RegionCreate, RegionDetail, RegionUpdate
from app.modules.rides.schemas import RidePage, RideStatus

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


@router.get(
    "/drivers",
    response_model=AdminDriverPage,
    summary="Kierowcy / wnioski",
    responses=STUB_RESPONSES,
)
async def admin_list_drivers(
    principal: AdminDep,
    status_filter: Annotated[DriverStatus | None, Query(alias="status")] = None,
    region_id: Annotated[UUID | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> AdminDriverPage:
    not_implemented()


@router.get(
    "/drivers/{user_id}",
    response_model=AdminDriver,
    summary="Szczegóły kierowcy",
    responses=STUB_RESPONSES,
)
async def admin_get_driver(principal: AdminDep, user_id: str) -> AdminDriver:
    not_implemented()


@router.get(
    "/drivers/{user_id}/documents/{document_id}/view-url",
    response_model=SignedUrl,
    summary="Krótkotrwały link do podglądu dokumentu",
    responses=STUB_RESPONSES,
)
async def admin_get_document_url(principal: AdminDep, user_id: str, document_id: UUID) -> SignedUrl:
    not_implemented()


@router.post(
    "/drivers/{user_id}/approve",
    response_model=AdminDriver,
    summary="Zatwierdź kierowcę (nadaje rolę driver w Keycloaku)",
    responses=STUB_RESPONSES,
)
async def admin_approve_driver(principal: AdminDep, user_id: str) -> AdminDriver:
    not_implemented()


@router.post(
    "/drivers/{user_id}/reject",
    response_model=AdminDriver,
    summary="Odrzuć wniosek",
    responses=STUB_RESPONSES,
)
async def admin_reject_driver(
    principal: AdminDep, user_id: str, body: ReasonRequest
) -> AdminDriver:
    not_implemented()


@router.post(
    "/drivers/{user_id}/suspend",
    response_model=AdminDriver,
    summary="Zawieś kierowcę",
    responses=STUB_RESPONSES,
)
async def admin_suspend_driver(
    principal: AdminDep, user_id: str, body: ReasonRequest
) -> AdminDriver:
    not_implemented()


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


@router.get("/rides", response_model=RidePage, summary="Kursy (filtry)", responses=STUB_RESPONSES)
async def admin_list_rides(
    principal: AdminDep,
    region_id: Annotated[UUID | None, Query()] = None,
    status_filter: Annotated[RideStatus | None, Query(alias="status")] = None,
    date_from: Annotated[datetime | None, Query()] = None,
    date_to: Annotated[datetime | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 50,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> RidePage:
    not_implemented()

"""Admin panel endpoints (role `admin`, login via Entra ID brokered by Keycloak)."""

from datetime import datetime
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query, status
from pydantic import Field

from app.common.schemas import ApiModel, Page
from app.core.errors import STUB_RESPONSES, not_implemented
from app.core.security import AdminDep
from app.modules.drivers.schemas import DriverProfile, DriverStatus
from app.modules.pricing.schemas import Tariff, TariffCreate
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


@router.get(
    "/regions",
    response_model=list[RegionDetail],
    summary="Wszystkie regiony",
    responses=STUB_RESPONSES,
)
async def admin_list_regions(principal: AdminDep) -> list[RegionDetail]:
    not_implemented()


@router.post(
    "/regions",
    response_model=RegionDetail,
    status_code=status.HTTP_201_CREATED,
    summary="Dodaj region (granica GeoJSON)",
    responses=STUB_RESPONSES,
)
async def admin_create_region(principal: AdminDep, body: RegionCreate) -> RegionDetail:
    not_implemented()


@router.patch(
    "/regions/{region_id}",
    response_model=RegionDetail,
    summary="Edytuj region",
    responses=STUB_RESPONSES,
)
async def admin_update_region(
    principal: AdminDep, region_id: UUID, body: RegionUpdate
) -> RegionDetail:
    not_implemented()


@router.get(
    "/regions/{region_id}/tariffs",
    response_model=list[Tariff],
    summary="Historia cenników regionu (najnowszy pierwszy)",
    responses=STUB_RESPONSES,
)
async def admin_list_tariffs(principal: AdminDep, region_id: UUID) -> list[Tariff]:
    not_implemented()


@router.post(
    "/regions/{region_id}/tariffs",
    response_model=Tariff,
    status_code=status.HTTP_201_CREATED,
    summary="Nowa wersja cennika (zamyka poprzednią)",
    responses=STUB_RESPONSES,
)
async def admin_create_tariff(principal: AdminDep, region_id: UUID, body: TariffCreate) -> Tariff:
    not_implemented()


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

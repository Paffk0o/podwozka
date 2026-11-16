"""Driver-side endpoints.

Every endpoint that acts as a driver MUST check driver_profile.status == approved in the DB,
not only the `driver` role in the token (suspensions take effect immediately).
Application/document endpoints only require a logged-in user (applicant has no `driver` role yet).
"""

from datetime import date
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query, status

from app.core.db import SessionDep
from app.core.errors import STUB_RESPONSES, Responses, not_implemented
from app.core.security import DriverDep, PrincipalDep
from app.modules.dispatch import service as dispatch
from app.modules.drivers import service
from app.modules.drivers.schemas import (
    AvailabilityUpdate,
    DocumentUploadRequest,
    DocumentUploadSlot,
    DriverApplicationUpsert,
    DriverCurrentState,
    DriverDocument,
    DriverProfile,
    DriverRideActionRequest,
    EarningsSummary,
)
from app.modules.drivers.service import ApprovedDriverDep
from app.modules.drivers.storage import (
    STORAGE_UNAVAILABLE,
    DocumentStorage,
    get_storage_or_503,
)
from app.modules.earnings import service as earnings
from app.modules.rides import driver_service as driver_rides
from app.modules.rides import service as rides_service
from app.modules.rides.schemas import CancelRequest, RatingCreate, Ride, RidePage

router = APIRouter(prefix="/drivers/me", tags=["driver"])

CONFLICT: Responses = {409: {"description": "Niedozwolone przejście statusu / zasób zajęty"}}


# --- Application & documents (applicant, no driver role needed) ---

StorageDep = Annotated[DocumentStorage, Depends(get_storage_or_503)]
APPLICATION_NOT_FOUND: Responses = {404: {"description": "Brak wniosku"}}
LOCKED: Responses = {409: {"description": "Wniosek jest już wysłany / rozpatrzony"}}


@router.get(
    "",
    response_model=DriverProfile,
    summary="Mój profil kierowcy / status wniosku",
    responses=APPLICATION_NOT_FOUND,
)
async def get_my_driver_profile(principal: PrincipalDep, session: SessionDep) -> DriverProfile:
    profile = await service.require_profile(session, principal.sub)
    return await service.to_schema(session, profile)


@router.put(
    "/application",
    response_model=DriverProfile,
    summary="Utwórz / popraw wniosek kierowcy (region, pojazd)",
    responses={**LOCKED, 422: {"description": "Region nie istnieje lub jest nieaktywny"}},
)
async def upsert_driver_application(
    principal: PrincipalDep, session: SessionDep, body: DriverApplicationUpsert
) -> DriverProfile:
    profile = await service.upsert_application(session, principal, body)
    return await service.to_schema(session, profile)


@router.post(
    "/documents",
    response_model=DocumentUploadSlot,
    status_code=status.HTTP_201_CREATED,
    summary="Poproś o link do wysłania dokumentu (Azure Blob SAS)",
    responses={**APPLICATION_NOT_FOUND, **LOCKED, **STORAGE_UNAVAILABLE},
)
async def create_document_upload(
    principal: PrincipalDep, session: SessionDep, storage: StorageDep, body: DocumentUploadRequest
) -> DocumentUploadSlot:
    return await service.create_upload_slot(session, principal, body, storage)


@router.post(
    "/documents/{document_id}/complete",
    response_model=DriverDocument,
    summary="Potwierdź, że plik został wysłany",
    responses={
        404: {"description": "Dokument nie istnieje"},
        409: {"description": "Pliku nie ma jeszcze w magazynie"},
        **STORAGE_UNAVAILABLE,
    },
)
async def complete_document_upload(
    principal: PrincipalDep, session: SessionDep, storage: StorageDep, document_id: UUID
) -> DriverDocument:
    document = await service.complete_upload(session, principal, document_id, storage)
    return service.document_schema(document)


@router.post(
    "/application/submit",
    response_model=DriverProfile,
    summary="Wyślij wniosek do weryfikacji",
    responses={
        **APPLICATION_NOT_FOUND,
        **LOCKED,
        422: {"description": "Brakuje wymaganych dokumentów"},
    },
)
async def submit_driver_application(principal: PrincipalDep, session: SessionDep) -> DriverProfile:
    profile = await service.submit_application(session, principal)
    return await service.to_schema(session, profile)


# --- Working as a driver (role driver + status approved) ---


INACTIVE: Responses = {403: {"description": "Brak roli driver albo konto kierowcy nieaktywne"}}


@router.get(
    "/current",
    response_model=DriverCurrentState,
    summary="Bieżący stan kierowcy (oferta, aktywny kurs)",
    responses=INACTIVE,
)
async def get_driver_current_state(
    driver: ApprovedDriverDep, session: SessionDep
) -> DriverCurrentState:
    return await dispatch.current_state(session, driver)


@router.put(
    "/availability",
    response_model=DriverProfile,
    summary="Przejdź online / offline",
    responses=INACTIVE,
)
async def set_driver_availability(
    driver: ApprovedDriverDep, session: SessionDep, body: AvailabilityUpdate
) -> DriverProfile:
    profile = await dispatch.set_availability(session, driver, body.online)
    return await service.to_schema(session, profile)


@router.post(
    "/offers/{offer_id}/accept",
    response_model=Ride,
    summary="Przyjmij ofertę kursu",
    responses={
        **INACTIVE,
        404: {"description": "Oferta nie istnieje"},
        409: {"description": "Oferta wygasła lub przyjęta przez innego"},
    },
)
async def accept_offer(driver: ApprovedDriverDep, session: SessionDep, offer_id: UUID) -> Ride:
    ride = await dispatch.accept_offer(session, driver, offer_id)
    return await rides_service.to_schema(session, ride, "driver")


@router.post(
    "/offers/{offer_id}/decline",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Odrzuć ofertę kursu",
    responses={**INACTIVE, 404: {"description": "Oferta nie istnieje"}},
)
async def decline_offer(driver: ApprovedDriverDep, session: SessionDep, offer_id: UUID) -> None:
    await dispatch.decline_offer(session, driver.user_id, offer_id)


@router.get(
    "/scheduled-board",
    response_model=list[Ride],
    summary="Giełda rezerwacji w moim regionie (nieprzypisane)",
    responses=STUB_RESPONSES,
)
async def list_scheduled_board(principal: DriverDep) -> list[Ride]:
    not_implemented()


@router.post(
    "/scheduled-board/{ride_id}/claim",
    response_model=Ride,
    summary="Weź rezerwację z giełdy",
    responses={**STUB_RESPONSES, **CONFLICT},
)
async def claim_scheduled_ride(principal: DriverDep, ride_id: UUID) -> Ride:
    not_implemented()


RIDE_NOT_FOUND: Responses = {404: {"description": "Kurs nie istnieje albo nie jest Twój"}}


@router.get(
    "/rides",
    response_model=RidePage,
    summary="Moje kursy jako kierowca (aktywne, zaplanowane, historia)",
    responses=INACTIVE,
)
async def list_driver_rides(
    driver: ApprovedDriverDep,
    session: SessionDep,
    active: Annotated[bool | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> RidePage:
    return await driver_rides.list_driver_rides(session, driver.user_id, active, limit, offset)


@router.post(
    "/rides/{ride_id}/actions",
    response_model=Ride,
    summary="Zmień status kursu (wyjazd, na miejscu, start, koniec)",
    responses={**INACTIVE, **RIDE_NOT_FOUND, **CONFLICT},
)
async def perform_ride_action(
    driver: ApprovedDriverDep, session: SessionDep, ride_id: UUID, body: DriverRideActionRequest
) -> Ride:
    ride = await driver_rides.perform_action(session, driver.user_id, ride_id, body.action)
    return await rides_service.to_schema(session, ride, "driver")


@router.post(
    "/rides/{ride_id}/cash-collected",
    response_model=Ride,
    summary="Potwierdź przyjęcie gotówki",
    responses={
        **INACTIVE,
        **RIDE_NOT_FOUND,
        409: {"description": "Kurs niezakończony albo nie gotówkowy"},
    },
)
async def confirm_cash_collected(
    driver: ApprovedDriverDep, session: SessionDep, ride_id: UUID
) -> Ride:
    ride = await driver_rides.confirm_cash(session, driver.user_id, ride_id)
    return await rides_service.to_schema(session, ride, "driver")


@router.post(
    "/rides/{ride_id}/cancel",
    response_model=Ride,
    summary="Anuluj kurs (kierowca)",
    description="Rezerwacja oddana wcześniej niż 30 min przed odbiorem wraca na giełdę "
    "(status `scheduled`); w pozostałych przypadkach kurs ma status `cancelled_by_driver`.",
    responses={**INACTIVE, **RIDE_NOT_FOUND, **CONFLICT},
)
async def cancel_driver_ride(
    driver: ApprovedDriverDep, session: SessionDep, ride_id: UUID, body: CancelRequest
) -> Ride:
    ride = await driver_rides.cancel_by_driver(session, driver.user_id, ride_id, body.reason)
    return await rides_service.to_schema(session, ride, "driver")


@router.post(
    "/rides/{ride_id}/rating",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Oceń pasażera",
    responses={
        **INACTIVE,
        **RIDE_NOT_FOUND,
        409: {"description": "Kurs niezakończony lub już oceniony"},
    },
)
async def rate_passenger(
    driver: ApprovedDriverDep, session: SessionDep, ride_id: UUID, body: RatingCreate
) -> None:
    await driver_rides.rate_passenger(session, driver.user_id, ride_id, body)


@router.get(
    "/earnings",
    response_model=EarningsSummary,
    summary="Zarobki w okresie",
    description="Dni lokalne (Europe/Warsaw), oba końce włącznie, zakres najwyżej 366 dni.",
    responses={**INACTIVE, 422: {"description": "Zły zakres dat"}},
)
async def get_driver_earnings(
    driver: ApprovedDriverDep,
    session: SessionDep,
    date_from: Annotated[date, Query()],
    date_to: Annotated[date, Query()],
) -> EarningsSummary:
    return await earnings.summary(session, driver.user_id, date_from, date_to)

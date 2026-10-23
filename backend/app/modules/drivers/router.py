"""Driver-side endpoints.

Every endpoint that acts as a driver MUST check driver_profile.status == approved in the DB,
not only the `driver` role in the token (suspensions take effect immediately).
Application/document endpoints only require a logged-in user (applicant has no `driver` role yet).
"""

from datetime import date
from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query, status

from app.core.errors import STUB_RESPONSES, Responses, not_implemented
from app.core.security import DriverDep, PrincipalDep
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
from app.modules.rides.schemas import CancelRequest, RatingCreate, Ride, RidePage

router = APIRouter(prefix="/drivers/me", tags=["driver"])

CONFLICT: Responses = {409: {"description": "Niedozwolone przejście statusu / zasób zajęty"}}


# --- Application & documents (applicant, no driver role needed) ---


@router.get(
    "",
    response_model=DriverProfile,
    summary="Mój profil kierowcy / status wniosku",
    responses={**STUB_RESPONSES, 404: {"description": "Brak wniosku"}},
)
async def get_my_driver_profile(principal: PrincipalDep) -> DriverProfile:
    not_implemented()


@router.put(
    "/application",
    response_model=DriverProfile,
    summary="Utwórz / popraw wniosek kierowcy (region, pojazd)",
    responses=STUB_RESPONSES,
)
async def upsert_driver_application(
    principal: PrincipalDep, body: DriverApplicationUpsert
) -> DriverProfile:
    not_implemented()


@router.post(
    "/documents",
    response_model=DocumentUploadSlot,
    status_code=status.HTTP_201_CREATED,
    summary="Poproś o link do wysłania dokumentu (Azure Blob SAS)",
    responses=STUB_RESPONSES,
)
async def create_document_upload(
    principal: PrincipalDep, body: DocumentUploadRequest
) -> DocumentUploadSlot:
    not_implemented()


@router.post(
    "/documents/{document_id}/complete",
    response_model=DriverDocument,
    summary="Potwierdź, że plik został wysłany",
    responses=STUB_RESPONSES,
)
async def complete_document_upload(principal: PrincipalDep, document_id: UUID) -> DriverDocument:
    not_implemented()


@router.post(
    "/application/submit",
    response_model=DriverProfile,
    summary="Wyślij wniosek do weryfikacji",
    responses={**STUB_RESPONSES, 422: {"description": "Brakuje wymaganych dokumentów"}},
)
async def submit_driver_application(principal: PrincipalDep) -> DriverProfile:
    not_implemented()


# --- Working as a driver (role driver + status approved) ---


@router.get(
    "/current",
    response_model=DriverCurrentState,
    summary="Bieżący stan kierowcy (oferta, aktywny kurs)",
    responses=STUB_RESPONSES,
)
async def get_driver_current_state(principal: DriverDep) -> DriverCurrentState:
    not_implemented()


@router.put(
    "/availability",
    response_model=DriverProfile,
    summary="Przejdź online / offline",
    responses=STUB_RESPONSES,
)
async def set_driver_availability(principal: DriverDep, body: AvailabilityUpdate) -> DriverProfile:
    not_implemented()


@router.post(
    "/offers/{offer_id}/accept",
    response_model=Ride,
    summary="Przyjmij ofertę kursu",
    responses={**STUB_RESPONSES, 409: {"description": "Oferta wygasła lub przyjęta przez innego"}},
)
async def accept_offer(principal: DriverDep, offer_id: UUID) -> Ride:
    not_implemented()


@router.post(
    "/offers/{offer_id}/decline",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Odrzuć ofertę kursu",
    responses=STUB_RESPONSES,
)
async def decline_offer(principal: DriverDep, offer_id: UUID) -> None:
    not_implemented()


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


@router.get(
    "/rides",
    response_model=RidePage,
    summary="Moje kursy jako kierowca (aktywne, zaplanowane, historia)",
    responses=STUB_RESPONSES,
)
async def list_driver_rides(
    principal: DriverDep,
    active: Annotated[bool | None, Query()] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> RidePage:
    not_implemented()


@router.post(
    "/rides/{ride_id}/actions",
    response_model=Ride,
    summary="Zmień status kursu (wyjazd, na miejscu, start, koniec)",
    responses={**STUB_RESPONSES, **CONFLICT},
)
async def perform_ride_action(
    principal: DriverDep, ride_id: UUID, body: DriverRideActionRequest
) -> Ride:
    not_implemented()


@router.post(
    "/rides/{ride_id}/cash-collected",
    response_model=Ride,
    summary="Potwierdź przyjęcie gotówki",
    responses={**STUB_RESPONSES, **CONFLICT},
)
async def confirm_cash_collected(principal: DriverDep, ride_id: UUID) -> Ride:
    not_implemented()


@router.post(
    "/rides/{ride_id}/cancel",
    response_model=Ride,
    summary="Anuluj kurs (kierowca)",
    responses={**STUB_RESPONSES, **CONFLICT},
)
async def cancel_driver_ride(principal: DriverDep, ride_id: UUID, body: CancelRequest) -> Ride:
    not_implemented()


@router.post(
    "/rides/{ride_id}/rating",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Oceń pasażera",
    responses={**STUB_RESPONSES, **CONFLICT},
)
async def rate_passenger(principal: DriverDep, ride_id: UUID, body: RatingCreate) -> None:
    not_implemented()


@router.get(
    "/earnings",
    response_model=EarningsSummary,
    summary="Zarobki w okresie",
    responses=STUB_RESPONSES,
)
async def get_driver_earnings(
    principal: DriverDep,
    date_from: Annotated[date, Query()],
    date_to: Annotated[date, Query()],
) -> EarningsSummary:
    not_implemented()

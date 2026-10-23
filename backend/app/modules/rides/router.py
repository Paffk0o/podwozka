"""Passenger-side ride endpoints."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query, status

from app.core.errors import STUB_RESPONSES, not_implemented
from app.core.security import PassengerDep
from app.modules.rides.schemas import (
    CancelRequest,
    RatingCreate,
    Ride,
    RideCreate,
    RideCreated,
    RidePage,
)

router = APIRouter(prefix="/rides", tags=["rides"])


@router.post(
    "",
    response_model=RideCreated,
    status_code=status.HTTP_201_CREATED,
    summary="Zamów kurs na podstawie wyceny",
    responses={
        **STUB_RESPONSES,
        409: {"description": "Wycena wygasła albo pasażer ma już aktywny kurs"},
        422: {"description": "Numer telefonu niezweryfikowany"},
    },
)
async def create_ride(principal: PassengerDep, body: RideCreate) -> RideCreated:
    not_implemented()


@router.get(
    "", response_model=RidePage, summary="Moje kursy (najnowsze pierwsze)", responses=STUB_RESPONSES
)
async def list_my_rides(
    principal: PassengerDep,
    active: Annotated[bool | None, Query(description="Tylko aktywne / tylko zakończone")] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> RidePage:
    not_implemented()


@router.get("/{ride_id}", response_model=Ride, summary="Szczegóły kursu", responses=STUB_RESPONSES)
async def get_my_ride(principal: PassengerDep, ride_id: UUID) -> Ride:
    not_implemented()


@router.post(
    "/{ride_id}/cancel",
    response_model=Ride,
    summary="Anuluj kurs (pasażer)",
    responses={**STUB_RESPONSES, 409: {"description": "Kursu nie można już anulować"}},
)
async def cancel_my_ride(principal: PassengerDep, ride_id: UUID, body: CancelRequest) -> Ride:
    not_implemented()


@router.post(
    "/{ride_id}/rating",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Oceń kierowcę",
    responses={**STUB_RESPONSES, 409: {"description": "Kurs niezakończony lub już oceniony"}},
)
async def rate_driver(principal: PassengerDep, ride_id: UUID, body: RatingCreate) -> None:
    not_implemented()

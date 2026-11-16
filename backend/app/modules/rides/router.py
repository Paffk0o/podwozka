"""Passenger-side ride endpoints."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Query, status

from app.core.db import SessionDep
from app.core.errors import Responses
from app.core.security import PassengerDep
from app.modules.rides import service
from app.modules.rides.schemas import (
    CancelRequest,
    RatingCreate,
    Ride,
    RideCreate,
    RideCreated,
    RidePage,
)

router = APIRouter(prefix="/rides", tags=["rides"])

NOT_FOUND: Responses = {404: {"description": "Kurs nie istnieje albo nie należy do Ciebie"}}


@router.post(
    "",
    response_model=RideCreated,
    status_code=status.HTTP_201_CREATED,
    summary="Zamów kurs na podstawie wyceny",
    responses={
        404: {"description": "Wycena nie istnieje albo nie należy do Ciebie"},
        409: {"description": "Wycena wygasła / wykorzystana albo pasażer ma już aktywny kurs"},
        422: {
            "description": "Numer telefonu niezweryfikowany albo płatność online "
            "(karta, BLIK — dostępne w etapie 3)"
        },
    },
)
async def create_ride(
    principal: PassengerDep, session: SessionDep, body: RideCreate
) -> RideCreated:
    ride = await service.create_ride(session, principal, body)
    return await service.created_response(session, ride)


@router.get("", response_model=RidePage, summary="Moje kursy (najnowsze pierwsze)")
async def list_my_rides(
    principal: PassengerDep,
    session: SessionDep,
    active: Annotated[bool | None, Query(description="Tylko aktywne / tylko zakończone")] = None,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> RidePage:
    return await service.list_passenger_rides(session, principal, active, limit, offset)


@router.get("/{ride_id}", response_model=Ride, summary="Szczegóły kursu", responses=NOT_FOUND)
async def get_my_ride(principal: PassengerDep, session: SessionDep, ride_id: UUID) -> Ride:
    ride = await service.get_passenger_ride(session, principal, ride_id)
    return await service.to_schema(session, ride, "passenger")


@router.post(
    "/{ride_id}/cancel",
    response_model=Ride,
    summary="Anuluj kurs (pasażer)",
    responses={**NOT_FOUND, 409: {"description": "Kursu nie można już anulować"}},
)
async def cancel_my_ride(
    principal: PassengerDep, session: SessionDep, ride_id: UUID, body: CancelRequest
) -> Ride:
    ride = await service.cancel_by_passenger(session, principal, ride_id, body.reason)
    return await service.to_schema(session, ride, "passenger")


@router.post(
    "/{ride_id}/rating",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Oceń kierowcę",
    responses={**NOT_FOUND, 409: {"description": "Kurs niezakończony lub już oceniony"}},
)
async def rate_driver(
    principal: PassengerDep, session: SessionDep, ride_id: UUID, body: RatingCreate
) -> None:
    ride = await service.get_passenger_ride(session, principal, ride_id)
    await service.rate(session, ride, principal.sub, service.ActorRole.PASSENGER, body)

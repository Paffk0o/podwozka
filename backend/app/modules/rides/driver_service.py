"""Driver-side operations on an assigned ride. Status changes go through service.transition()."""

import uuid
from datetime import UTC, datetime, timedelta

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core import events
from app.modules.drivers.schemas import DriverRideAction
from app.modules.earnings import service as earnings
from app.modules.rides import service
from app.modules.rides.models import Ride
from app.modules.rides.schemas import (
    PaymentMethod,
    PaymentStatus,
    RatingCreate,
    RidePage,
    RideStatus,
)

S = RideStatus

ACTION_TARGETS = {
    DriverRideAction.DEPART: S.DRIVER_ARRIVING,
    DriverRideAction.ARRIVED: S.ARRIVED,
    DriverRideAction.START: S.IN_PROGRESS,
    DriverRideAction.COMPLETE: S.COMPLETED,
}
# A claimed reservation given back at least this long before pickup returns to the board.
RETURN_TO_BOARD_BEFORE = timedelta(minutes=30)


async def get_driver_ride(
    session: AsyncSession, driver_id: str, ride_id: uuid.UUID, for_update: bool = True
) -> Ride:
    ride = await (service.get_ride_for_update if for_update else service.get_ride)(session, ride_id)
    if ride is None or ride.driver_id != driver_id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Ride not found")
    return ride


async def perform_action(
    session: AsyncSession, driver_id: str, ride_id: uuid.UUID, action: DriverRideAction
) -> Ride:
    ride = await get_driver_ride(session, driver_id, ride_id)
    actor = service.Actor(driver_id, service.ActorRole.DRIVER)
    service.transition(session, ride, ACTION_TARGETS[action], actor)
    if action == DriverRideAction.COMPLETE:
        await earnings.record_completed_ride(session, ride)
    await service.commit(session)
    return ride


async def confirm_cash(session: AsyncSession, driver_id: str, ride_id: uuid.UUID) -> Ride:
    ride = await get_driver_ride(session, driver_id, ride_id)
    if ride.payment_method != PaymentMethod.CASH:
        raise HTTPException(status.HTTP_409_CONFLICT, "Kurs nie jest płatny gotówką")
    if ride.status != S.COMPLETED:
        raise HTTPException(status.HTTP_409_CONFLICT, "Gotówkę potwierdza się po zakończeniu kursu")
    if ride.payment_status == PaymentStatus.CASH_COLLECTED:
        await session.commit()  # releases the row lock; commit keeps loaded attributes
        return ride  # idempotent
    ride.payment_status = PaymentStatus.CASH_COLLECTED
    await earnings.mark_cash_collected(session, ride)
    service.queue_message(
        session,
        events.ride_channel(ride.id),
        {"type": "ride.payment", "ride_id": str(ride.id), "payment_status": ride.payment_status},
    )
    await service.commit(session)
    return ride


async def cancel_by_driver(
    session: AsyncSession, driver_id: str, ride_id: uuid.UUID, reason: str | None
) -> Ride:
    """A reservation given back early returns to the board; otherwise the ride is cancelled."""
    ride = await get_driver_ride(session, driver_id, ride_id)
    actor = service.Actor(driver_id, service.ActorRole.DRIVER)
    now = datetime.now(UTC)
    if (
        ride.status == S.ACCEPTED
        and ride.scheduled_at is not None
        and ride.scheduled_at - now > RETURN_TO_BOARD_BEFORE
    ):
        service.transition(session, ride, S.SCHEDULED, actor, note=reason)
        ride.driver_id = None
        ride.accepted_at = None
        service.board_updated(session, ride.region_id)
    else:
        ride.cancel_reason = reason
        service.transition(session, ride, S.CANCELLED_BY_DRIVER, actor, note=reason)
    await service.commit(session)
    return ride


async def rate_passenger(
    session: AsyncSession, driver_id: str, ride_id: uuid.UUID, data: RatingCreate
) -> None:
    ride = await get_driver_ride(session, driver_id, ride_id, for_update=False)
    await service.rate(session, ride, driver_id, service.ActorRole.DRIVER, data)


async def list_driver_rides(
    session: AsyncSession, driver_id: str, active: bool | None, limit: int, offset: int
) -> RidePage:
    query = service.filter_active(select(Ride).where(Ride.driver_id == driver_id), active)
    return await service.page_rides(session, query, limit, offset, view="driver")

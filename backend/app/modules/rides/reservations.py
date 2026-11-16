"""Reservations: the region's board, claiming, and the per-minute beat job.

Timeline of a reservation (scheduled_at = T):
- created -> `scheduled`, visible on the board of its region;
- a driver claims it -> `accepted` (reminder at T-60 min);
- nobody claimed it by T-30 min -> normal dispatch (`dispatching`), passenger notified.
State lives in PostgreSQL, so a restarted worker loses nothing.
"""

import logging
import uuid
from datetime import UTC, datetime, timedelta
from zoneinfo import ZoneInfo

from fastapi import HTTPException, status
from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core import events
from app.modules.drivers.models import DriverProfile
from app.modules.notifications.service import notify
from app.modules.rides import service
from app.modules.rides.models import Ride
from app.modules.rides.schemas import RideStatus

log = logging.getLogger(__name__)
S = RideStatus

REMIND_BEFORE = timedelta(minutes=60)
DISPATCH_BEFORE = timedelta(minutes=30)
# A driver cannot hold two reservations closer than the ride itself plus this margin.
OVERLAP_MARGIN = timedelta(minutes=60)


async def board(session: AsyncSession, driver: DriverProfile) -> list[Ride]:
    result = await session.execute(
        select(Ride)
        .where(
            Ride.region_id == driver.region_id,
            Ride.status == S.SCHEDULED,
            Ride.driver_id.is_(None),
        )
        .order_by(Ride.scheduled_at)
    )
    return list(result.scalars())


async def claim(session: AsyncSession, driver: DriverProfile, ride_id: uuid.UUID) -> Ride:
    driver_id, region_id = driver.user_id, driver.region_id
    ride = await service.get_ride_for_update(session, ride_id)
    if ride is None or ride.region_id != region_id or ride.scheduled_at is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Reservation not found")
    if ride.status != S.SCHEDULED or ride.driver_id is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Rezerwację wziął już inny kierowca")
    window = timedelta(seconds=ride.duration_s) + OVERLAP_MARGIN
    clash = await session.execute(
        select(Ride.id)
        .where(
            Ride.driver_id == driver_id,
            Ride.status.in_((S.ACCEPTED, S.DRIVER_ARRIVING, S.ARRIVED, S.IN_PROGRESS)),
            and_(
                Ride.scheduled_at > ride.scheduled_at - window,
                Ride.scheduled_at < ride.scheduled_at + window,
            ),
        )
        .limit(1)
    )
    if clash.first() is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Masz już rezerwację w tym czasie")

    ride.driver_id = driver_id
    service.transition(
        session, ride, S.ACCEPTED, service.Actor(driver_id, service.ActorRole.DRIVER)
    )
    service.queue_message(
        session,
        events.ride_channel(ride.id),
        {"type": "ride.driver_assigned", "ride_id": str(ride.id)},
    )
    notify(
        session,
        ride.passenger_id,
        "Kierowca przyjął rezerwację",
        f"Odbiór {_local(ride.scheduled_at)} — szczegóły w aplikacji",
        {"ride_id": str(ride.id)},
    )
    service.board_updated(session, ride.region_id)
    await service.commit(session)
    return ride


def _local(at: datetime) -> str:
    return at.astimezone(ZoneInfo("Europe/Warsaw")).strftime("%d.%m %H:%M")


async def tick(session: AsyncSession, now: datetime | None = None) -> tuple[int, int]:
    """Beat job (every minute): reminders at T-60, dispatch at T-30. Returns the counts."""
    from app.modules.dispatch.service import start_dispatch  # avoid an import cycle

    now = now or datetime.now(UTC)
    reminded = 0
    due = await session.execute(
        select(Ride)
        .where(
            Ride.status == S.ACCEPTED,
            Ride.scheduled_at.is_not(None),
            Ride.scheduled_at <= now + REMIND_BEFORE,
            Ride.reminder_sent_at.is_(None),
        )
        .with_for_update(skip_locked=True)
    )
    for reminder in due.scalars():
        reminder.reminder_sent_at = now
        if reminder.driver_id is not None:
            notify(
                session,
                reminder.driver_id,
                "Przypomnienie o rezerwacji",
                f"Odbiór {_local(reminder.scheduled_at or now)}: {reminder.pickup_address}",
                {"ride_id": str(reminder.id)},
            )
            reminded += 1
    await service.commit(session)

    unclaimed = (
        (
            await session.execute(
                select(Ride.id).where(
                    Ride.status == S.SCHEDULED, Ride.scheduled_at <= now + DISPATCH_BEFORE
                )
            )
        )
        .scalars()
        .all()
    )
    await session.rollback()
    dispatched = 0
    for ride_id in unclaimed:
        ride = await service.get_ride_for_update(session, ride_id)
        if ride is None or ride.status != S.SCHEDULED:
            await session.rollback()
            continue
        service.transition(
            session, ride, S.DISPATCHING, service.SYSTEM, note="Nikt nie wziął rezerwacji"
        )
        notify(
            session,
            ride.passenger_id,
            "Szukamy kierowcy",
            "Nikt nie przyjął rezerwacji z wyprzedzeniem — szukamy najbliższego kierowcy",
            {"ride_id": str(ride_id)},
        )
        service.board_updated(session, ride.region_id)
        await service.commit(session)
        await start_dispatch(session, ride_id)
        dispatched += 1
    if reminded or dispatched:
        log.info("reservations: %s reminders, %s dispatched", reminded, dispatched)
    return reminded, dispatched

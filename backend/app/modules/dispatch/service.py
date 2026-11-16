"""Live dispatch: offer a ride to the nearest free driver, 20 s to accept, then the next one.

Concurrency rules:
- Every operation on a ride locks the ride row first (`SELECT ... FOR UPDATE`), so dispatch,
  accept, decline and expiry of the same ride run one after another; the loser of a race sees
  the new state and gets 409.
- A Redis lock per driver (`driver:offer-lock:*`) prevents offering two rides to one driver.
"""

import logging
import uuid
from datetime import UTC, datetime, timedelta

from fastapi import HTTPException, status
from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core import events
from app.core.config import get_settings
from app.modules.dispatch import presence
from app.modules.dispatch.models import RideOffer as OfferRow
from app.modules.dispatch.queue import get_task_queue
from app.modules.drivers import service as drivers_service
from app.modules.drivers.models import DriverProfile as ProfileRow
from app.modules.drivers.schemas import DriverCurrentState, DriverStatus, RideOffer
from app.modules.pricing.routing import StraightLineRouting
from app.modules.rides import service as rides
from app.modules.rides.models import Ride as RideRow
from app.modules.rides.schemas import RideStatus

log = logging.getLogger(__name__)
S = RideStatus

PENDING = "pending"
ACCEPTED = "accepted"
DECLINED = "declined"
EXPIRED = "expired"
CANCELLED = "cancelled"

SEARCH_RADIUS_KM = 25.0
ACCEPT_GRACE = timedelta(seconds=2)  # network latency of the driver's tap
SCHEDULED_BUFFER = timedelta(minutes=60)  # a claimed reservation soon -> not offered rides now
# Rides the driver is working on right now.
WORKING_STATUSES = (S.DRIVER_ARRIVING, S.ARRIVED, S.IN_PROGRESS)


def _offer_ttl() -> timedelta:
    return timedelta(seconds=get_settings().offer_timeout_s)


def _driver_active_clause(driver_id: str) -> object:
    return and_(
        RideRow.driver_id == driver_id,
        or_(
            RideRow.status.in_(WORKING_STATUSES),
            and_(RideRow.status == S.ACCEPTED, RideRow.scheduled_at.is_(None)),
        ),
    )


async def active_ride_of(session: AsyncSession, driver_id: str) -> RideRow | None:
    result = await session.execute(
        select(RideRow).where(_driver_active_clause(driver_id)).limit(1)  # type: ignore[arg-type]
    )
    return result.scalar_one_or_none()


async def next_scheduled_of(session: AsyncSession, driver_id: str) -> RideRow | None:
    result = await session.execute(
        select(RideRow)
        .where(
            RideRow.driver_id == driver_id,
            RideRow.status == S.ACCEPTED,
            RideRow.scheduled_at.is_not(None),
        )
        .order_by(RideRow.scheduled_at)
        .limit(1)
    )
    return result.scalar_one_or_none()


async def is_busy(session: AsyncSession, driver_id: str, now: datetime) -> bool:
    """Working on a ride, has a ride "now" accepted, or a reservation within the next hour."""
    result = await session.execute(
        select(RideRow.id)
        .where(
            or_(
                _driver_active_clause(driver_id),  # type: ignore[arg-type]
                and_(
                    RideRow.driver_id == driver_id,
                    RideRow.status == S.ACCEPTED,
                    RideRow.scheduled_at <= now + SCHEDULED_BUFFER,
                ),
            )
        )
        .limit(1)
    )
    return result.first() is not None


async def _pending_offer_for_ride(session: AsyncSession, ride_id: uuid.UUID) -> OfferRow | None:
    result = await session.execute(
        select(OfferRow).where(OfferRow.ride_id == ride_id, OfferRow.status == PENDING).limit(1)
    )
    return result.scalar_one_or_none()


async def dispatch_next(session: AsyncSession, ride_id: uuid.UUID) -> OfferRow | None:
    """Offer the ride to the nearest free driver not asked yet; none left -> `no_driver`."""
    ride = await rides.get_ride_for_update(session, ride_id)
    if ride is None or ride.status != S.DISPATCHING:
        await session.rollback()
        return None
    if await _pending_offer_for_ride(session, ride.id) is not None:
        await session.rollback()
        return None  # someone is already deciding

    asked = set(
        (await session.execute(select(OfferRow.driver_id).where(OfferRow.ride_id == ride.id)))
        .scalars()
        .all()
    )
    now = datetime.now(UTC)
    pickup = rides.pickup_point(ride)
    for candidate in await presence.nearby(ride.region_id, pickup, SEARCH_RADIUS_KM):
        if candidate.driver_id in asked or candidate.driver_id == ride.passenger_id:
            continue
        profile = await session.get(ProfileRow, candidate.driver_id)
        if profile is None or profile.status != DriverStatus.APPROVED or not profile.online:
            continue
        if await is_busy(session, candidate.driver_id, now):
            continue
        ttl = _offer_ttl()
        if not await presence.lock_for_offer(candidate.driver_id, int(ttl.total_seconds()) + 5):
            continue  # being offered another ride right now
        offer = OfferRow(
            id=uuid.uuid4(),
            ride_id=ride.id,
            driver_id=candidate.driver_id,
            status=PENDING,
            pickup_distance_m=round(candidate.distance_m),
            pickup_eta_s=eta_from_distance(candidate.distance_m),
            created_at=now,
            expires_at=now + ttl,
        )
        session.add(offer)
        rides.queue_message(
            session,
            events.user_channel(candidate.driver_id),
            {
                "type": "offer.new",
                "offer_id": str(offer.id),
                "ride_id": str(ride.id),
                "expires_at": offer.expires_at,
            },
        )
        await rides.commit(session)
        await get_task_queue().expire_offer_at(offer.id, ttl.total_seconds())
        log.info("ride %s offered to %s", ride.id, candidate.driver_id)
        return offer

    rides.transition(session, ride, S.NO_DRIVER, rides.SYSTEM, note="Brak wolnych kierowców")
    await rides.commit(session)
    log.info("ride %s: no driver", ride.id)
    return None


async def start_dispatch(session: AsyncSession, ride_id: uuid.UUID) -> None:
    """Called after a ride enters `dispatching`; never fails the caller's request."""
    try:
        await dispatch_next(session, ride_id)
    except Exception:
        log.exception("dispatch of ride %s failed; the sweeper will retry", ride_id)
        await session.rollback()


async def _locked_offer(
    session: AsyncSession, offer_id: uuid.UUID, driver_id: str | None
) -> tuple[OfferRow, RideRow]:
    """Lock order everywhere: ride first, then offer."""
    offer = await session.get(OfferRow, offer_id)
    if offer is None or (driver_id is not None and offer.driver_id != driver_id):
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Offer not found")
    ride = await rides.get_ride_for_update(session, offer.ride_id)
    if ride is None:  # pragma: no cover - FK
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Ride not found")
    await session.refresh(offer, with_for_update=True)
    return offer, ride


async def accept_offer(session: AsyncSession, driver: ProfileRow, offer_id: uuid.UUID) -> RideRow:
    offer, ride = await _locked_offer(session, offer_id, driver.user_id)
    now = datetime.now(UTC)
    if offer.status != PENDING or offer.expires_at + ACCEPT_GRACE < now:
        await session.rollback()
        raise HTTPException(status.HTTP_409_CONFLICT, "Oferta wygasła")
    if ride.status != S.DISPATCHING:
        await session.rollback()
        raise HTTPException(status.HTTP_409_CONFLICT, "Kurs przyjął inny kierowca albo anulowano")
    if await active_ride_of(session, driver.user_id) is not None:
        await session.rollback()
        raise HTTPException(status.HTTP_409_CONFLICT, "Masz już aktywny kurs")
    offer.status = ACCEPTED
    offer.responded_at = now
    ride.driver_id = driver.user_id
    rides.transition(session, ride, S.ACCEPTED, rides.Actor(driver.user_id, rides.ActorRole.DRIVER))
    rides.queue_message(
        session,
        events.ride_channel(ride.id),
        {"type": "ride.driver_assigned", "ride_id": str(ride.id)},
    )
    await rides.commit(session)
    await presence.release_offer_lock(driver.user_id)
    return ride


async def decline_offer(session: AsyncSession, driver_id: str, offer_id: uuid.UUID) -> None:
    offer, ride = await _locked_offer(session, offer_id, driver_id)
    ride_id = ride.id
    if offer.status != PENDING:
        await session.rollback()
        return  # idempotent
    offer.status = DECLINED
    offer.responded_at = datetime.now(UTC)
    await session.commit()
    await presence.release_offer_lock(driver_id)
    await start_dispatch(session, ride_id)


async def expire_offer(session: AsyncSession, offer_id: uuid.UUID) -> bool:
    """Celery task body. True if the offer expired now (and dispatch moved on)."""
    try:
        offer, ride = await _locked_offer(session, offer_id, None)
    except HTTPException:
        return False
    if offer.status != PENDING or offer.expires_at > datetime.now(UTC):
        await session.rollback()
        return False
    offer.status = EXPIRED
    offer.responded_at = datetime.now(UTC)
    rides.queue_message(
        session,
        events.user_channel(offer.driver_id),
        {"type": "offer.expired", "offer_id": str(offer.id)},
    )
    await rides.commit(session)
    await presence.release_offer_lock(offer.driver_id)
    await start_dispatch(session, ride.id)
    return True


async def cancel_pending_offers(session: AsyncSession, ride: RideRow) -> list[str]:
    """Inside the caller's transaction (ride already locked): the ride is no longer available."""
    result = await session.execute(
        select(OfferRow).where(OfferRow.ride_id == ride.id, OfferRow.status == PENDING)
    )
    drivers = []
    for offer in result.scalars():
        offer.status = CANCELLED
        offer.responded_at = datetime.now(UTC)
        drivers.append(offer.driver_id)
        rides.queue_message(
            session,
            events.user_channel(offer.driver_id),
            {"type": "offer.expired", "offer_id": str(offer.id)},
        )
    return drivers


async def sweep(session: AsyncSession) -> int:
    """Safety net run by Celery beat: expire overdue offers (lost tasks) and restart dispatch
    for rides stuck in `dispatching` without a pending offer (e.g. API restarted mid-way)."""
    now = datetime.now(UTC)
    overdue = (
        (
            await session.execute(
                select(OfferRow.id).where(
                    OfferRow.status == PENDING, OfferRow.expires_at < now - ACCEPT_GRACE
                )
            )
        )
        .scalars()
        .all()
    )
    await session.rollback()
    handled = 0
    for offer_id in overdue:
        handled += await expire_offer(session, offer_id)
    pending = select(OfferRow.id).where(OfferRow.ride_id == RideRow.id, OfferRow.status == PENDING)
    stuck = (
        (
            await session.execute(
                select(RideRow.id).where(
                    RideRow.status == S.DISPATCHING,
                    RideRow.updated_at < now - timedelta(seconds=30),
                    ~pending.exists(),
                )
            )
        )
        .scalars()
        .all()
    )
    await session.rollback()
    for ride_id in stuck:
        await start_dispatch(session, ride_id)
        handled += 1
    return handled


# --- Availability and the driver's current state ---


async def set_availability(session: AsyncSession, driver: ProfileRow, online: bool) -> ProfileRow:
    profile = await drivers_service.require_profile(session, driver.user_id, for_update=True)
    user_id, region_id = profile.user_id, profile.region_id
    profile.online = online
    profile.online_changed_at = datetime.now(UTC)
    await session.commit()
    if not online:
        await presence.go_offline(region_id, user_id)
        pending = (
            (
                await session.execute(
                    select(OfferRow.id).where(
                        OfferRow.driver_id == user_id, OfferRow.status == PENDING
                    )
                )
            )
            .scalars()
            .all()
        )
        await session.rollback()
        for offer_id in pending:
            await decline_offer(session, user_id, offer_id)
    await session.refresh(profile)
    return profile


async def offer_schema(session: AsyncSession, offer: OfferRow) -> RideOffer:
    ride = await rides.get_ride(session, offer.ride_id)
    if ride is None:  # pragma: no cover - FK
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Ride not found")
    return RideOffer(
        id=offer.id,
        ride=await rides.to_schema(session, ride, "driver"),
        pickup_distance_m=offer.pickup_distance_m,
        pickup_eta_s=offer.pickup_eta_s,
        expires_at=offer.expires_at,
    )


async def current_state(session: AsyncSession, driver: ProfileRow) -> DriverCurrentState:
    pending = (
        await session.execute(
            select(OfferRow)
            .where(
                OfferRow.driver_id == driver.user_id,
                OfferRow.status == PENDING,
                OfferRow.expires_at > datetime.now(UTC),
            )
            .order_by(OfferRow.created_at.desc())
            .limit(1)
        )
    ).scalar_one_or_none()
    active = await active_ride_of(session, driver.user_id)
    scheduled = await next_scheduled_of(session, driver.user_id)
    return DriverCurrentState(
        profile=await drivers_service.to_schema(session, driver),
        pending_offer=await offer_schema(session, pending) if pending else None,
        active_ride=await rides.to_schema(session, active, "driver") if active else None,
        next_scheduled_ride=(
            await rides.to_schema(session, scheduled, "driver") if scheduled else None
        ),
    )


def eta_from_distance(straight_m: float) -> int:
    """Rough ETA from a straight-line distance (same model as the offline routing)."""
    return round(straight_m * StraightLineRouting.ROAD_FACTOR / StraightLineRouting.SPEED_MPS)

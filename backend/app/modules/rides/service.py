"""Rides: the state machine and passenger operations.

Every status change goes through `transition()` — it checks the table of allowed transitions,
sets timestamps, writes a `ride_events` row and queues a live notification that is published
after the transaction commits (`commit()`).
"""

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from enum import StrEnum
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy import Select, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.geo import point_wkt, wkb_point_latlng
from app.common.schemas import GeoPoint, Place
from app.core import events
from app.core.config import get_settings
from app.core.security import Principal
from app.modules.pricing.models import QuoteRecord
from app.modules.pricing.routing import haversine_m
from app.modules.rides.models import Rating, RideEvent
from app.modules.rides.models import Ride as RideRow
from app.modules.rides.schemas import (
    PaymentMethod,
    PaymentStatus,
    RatingCreate,
    Ride,
    RideCreate,
    RideCreated,
    RideDriverInfo,
    RidePage,
    RidePassengerInfo,
    RideStatus,
)
from app.modules.users import service as users_service
from app.modules.users.models import User

S = RideStatus

ALLOWED_TRANSITIONS: dict[RideStatus, frozenset[RideStatus]] = {
    S.REQUESTED: frozenset({S.DISPATCHING, S.SCHEDULED, S.CANCELLED_BY_PASSENGER}),
    # A reservation is either claimed from the board (-> accepted) or, at T-30 min with
    # nobody assigned, dispatched like a ride "now".
    S.SCHEDULED: frozenset({S.DISPATCHING, S.ACCEPTED, S.CANCELLED_BY_PASSENGER}),
    S.DISPATCHING: frozenset({S.ACCEPTED, S.NO_DRIVER, S.CANCELLED_BY_PASSENGER}),
    # accepted -> scheduled: the driver gives a claimed reservation back to the board.
    S.ACCEPTED: frozenset(
        {S.DRIVER_ARRIVING, S.SCHEDULED, S.CANCELLED_BY_PASSENGER, S.CANCELLED_BY_DRIVER}
    ),
    S.DRIVER_ARRIVING: frozenset({S.ARRIVED, S.CANCELLED_BY_PASSENGER, S.CANCELLED_BY_DRIVER}),
    S.ARRIVED: frozenset({S.IN_PROGRESS, S.CANCELLED_BY_PASSENGER, S.CANCELLED_BY_DRIVER}),
    S.IN_PROGRESS: frozenset({S.COMPLETED}),
    S.COMPLETED: frozenset(),
    S.CANCELLED_BY_PASSENGER: frozenset(),
    S.CANCELLED_BY_DRIVER: frozenset(),
    S.NO_DRIVER: frozenset(),
}

FINAL_STATUSES = frozenset(s for s, targets in ALLOWED_TRANSITIONS.items() if not targets)
ACTIVE_STATUSES = frozenset(RideStatus) - FINAL_STATUSES
PASSENGER_CANCELLABLE = frozenset(
    s for s, targets in ALLOWED_TRANSITIONS.items() if S.CANCELLED_BY_PASSENGER in targets
)
# Rides "now" that block ordering another one.
ONGOING_STATUSES = frozenset(
    {S.REQUESTED, S.DISPATCHING, S.ACCEPTED, S.DRIVER_ARRIVING, S.ARRIVED, S.IN_PROGRESS}
)

_TIMESTAMPS = {
    S.ACCEPTED: "accepted_at",
    S.IN_PROGRESS: "started_at",
    S.COMPLETED: "completed_at",
    S.CANCELLED_BY_PASSENGER: "cancelled_at",
    S.CANCELLED_BY_DRIVER: "cancelled_at",
}

_OUTBOX = "ride_outbox"


class ActorRole(StrEnum):
    PASSENGER = "passenger"
    DRIVER = "driver"
    ADMIN = "admin"
    SYSTEM = "system"


@dataclass(frozen=True, slots=True)
class Actor:
    id: str | None
    role: ActorRole


SYSTEM = Actor(id=None, role=ActorRole.SYSTEM)


class InvalidTransitionError(HTTPException):
    def __init__(self, current: str, target: str) -> None:
        super().__init__(
            status.HTTP_409_CONFLICT, f"Niedozwolona zmiana statusu kursu: {current} -> {target}"
        )


def can_transition(current: RideStatus, target: RideStatus) -> bool:
    return target in ALLOWED_TRANSITIONS[current]


def queue_message(session: AsyncSession, channel: str, message: dict[str, Any]) -> None:
    """Queue a live notification; sent by `commit()` only if the transaction succeeds."""
    session.info.setdefault(_OUTBOX, []).append((channel, message))


def transition(
    session: AsyncSession,
    ride: RideRow,
    target: RideStatus,
    actor: Actor,
    note: str | None = None,
    at: datetime | None = None,
) -> None:
    """The ONLY way to change a ride's status."""
    current = RideStatus(ride.status)
    if not can_transition(current, target):
        raise InvalidTransitionError(current, target)
    at = at or datetime.now(UTC)
    ride.status = target
    if field := _TIMESTAMPS.get(target):
        setattr(ride, field, at)
    session.add(
        RideEvent(
            ride_id=ride.id,
            from_status=current,
            to_status=target,
            actor_id=actor.id,
            actor_role=actor.role,
            note=note,
            at=at,
        )
    )
    message = {"type": "ride.status", "ride_id": str(ride.id), "status": target, "at": at}
    queue_message(session, events.ride_channel(ride.id), message)
    # Drivers learn about cancellations even if they are not subscribed to the ride.
    if ride.driver_id and actor.id != ride.driver_id and target in FINAL_STATUSES:
        queue_message(session, events.user_channel(ride.driver_id), message)


def board_updated(session: AsyncSession, region_id: uuid.UUID) -> None:
    """Tell the region's drivers to refresh the reservation board."""
    queue_message(
        session,
        events.board_channel(region_id),
        {"type": "board.updated", "region_id": str(region_id)},
    )


async def commit(session: AsyncSession) -> None:
    """Commit, then publish the queued notifications."""
    await session.commit()
    for channel, message in session.info.pop(_OUTBOX, []):
        await events.publish(channel, message)


async def get_ride(session: AsyncSession, ride_id: uuid.UUID) -> RideRow | None:
    return await session.get(RideRow, ride_id)


async def get_ride_for_update(session: AsyncSession, ride_id: uuid.UUID) -> RideRow | None:
    """Row-locked read; concurrent writers on the same ride wait for this transaction."""
    result = await session.execute(
        select(RideRow)
        .where(RideRow.id == ride_id)
        .with_for_update()
        .execution_options(populate_existing=True)
    )
    return result.scalar_one_or_none()


def _not_found() -> HTTPException:
    return HTTPException(status.HTTP_404_NOT_FOUND, "Ride not found")


# --- Passenger operations ---


async def create_ride(session: AsyncSession, principal: Principal, data: RideCreate) -> RideRow:
    if data.payment_method != PaymentMethod.CASH:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT,
            "Płatności online (karta, BLIK) będą dostępne w etapie 3 — wybierz gotówkę",
        )
    user = await users_service.ensure_user(session, principal)
    if get_settings().require_verified_phone and not user.phone_verified:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT, "Numer telefonu niezweryfikowany"
        )

    quote = (
        await session.execute(
            select(QuoteRecord).where(QuoteRecord.id == data.quote_id).with_for_update()
        )
    ).scalar_one_or_none()
    if quote is None or quote.passenger_id != principal.sub:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Quote not found")
    now = datetime.now(UTC)
    if quote.used_at is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Wycena została już wykorzystana")
    if quote.expires_at <= now:
        raise HTTPException(status.HTTP_409_CONFLICT, "Wycena wygasła — poproś o nową")
    if quote.scheduled_at is None and await _has_ongoing_ride(session, principal.sub):
        raise HTTPException(status.HTTP_409_CONFLICT, "Masz już aktywny kurs")

    quote.used_at = now
    ride = RideRow(
        id=uuid.uuid4(),
        passenger_id=principal.sub,
        region_id=quote.region_id,
        quote_id=quote.id,
        tariff_id=quote.tariff_id,
        status=S.REQUESTED,
        pickup_location=point_wkt(quote.pickup_lat, quote.pickup_lng),
        pickup_address=quote.pickup_address,
        pickup_place_id=quote.pickup_place_id,
        destination_location=point_wkt(quote.destination_lat, quote.destination_lng),
        destination_address=quote.destination_address,
        destination_place_id=quote.destination_place_id,
        scheduled_at=quote.scheduled_at,
        requested_at=now,
        price=quote.price,
        currency="PLN",
        payment_method=data.payment_method,
        payment_status=PaymentStatus.CASH_DUE,
        distance_m=quote.distance_m,
        duration_s=quote.duration_s,
        route_polyline=quote.route_polyline,
        passenger_note=data.passenger_note,
    )
    session.add(ride)
    session.add(
        RideEvent(
            ride_id=ride.id,
            from_status=None,
            to_status=S.REQUESTED,
            actor_id=principal.sub,
            actor_role=ActorRole.PASSENGER,
            at=now,
        )
    )
    await session.flush()
    passenger = Actor(principal.sub, ActorRole.PASSENGER)
    if ride.scheduled_at is not None:
        transition(session, ride, S.SCHEDULED, passenger, at=now)
        board_updated(session, ride.region_id)
    else:
        transition(session, ride, S.DISPATCHING, passenger, at=now)
    await commit(session)
    return ride


async def _has_ongoing_ride(session: AsyncSession, passenger_id: str) -> bool:
    result = await session.execute(
        select(RideRow.id)
        .where(
            RideRow.passenger_id == passenger_id,
            RideRow.scheduled_at.is_(None),
            RideRow.status.in_(ONGOING_STATUSES),
        )
        .limit(1)
    )
    return result.first() is not None


async def get_passenger_ride(
    session: AsyncSession, principal: Principal, ride_id: uuid.UUID, for_update: bool = False
) -> RideRow:
    ride = await (get_ride_for_update if for_update else get_ride)(session, ride_id)
    # 404, not 403: do not reveal that someone else's ride exists.
    if ride is None or ride.passenger_id != principal.sub:
        raise _not_found()
    return ride


def filter_active(query: Select[Any], active: bool | None) -> Select[Any]:
    if active is True:
        return query.where(RideRow.status.in_(ACTIVE_STATUSES))
    if active is False:
        return query.where(RideRow.status.in_(FINAL_STATUSES))
    return query


async def page_rides(
    session: AsyncSession,
    query: Select[Any],
    limit: int,
    offset: int,
    view: str,
) -> RidePage:
    total = (
        await session.execute(select(func.count()).select_from(query.order_by(None).subquery()))
    ).scalar_one()
    rows = (
        await session.execute(
            query.order_by(RideRow.requested_at.desc(), RideRow.id).limit(limit).offset(offset)
        )
    ).scalars()
    items = [await to_schema(session, ride, view) for ride in rows]
    return RidePage(items=items, total=total, limit=limit, offset=offset)


async def list_passenger_rides(
    session: AsyncSession, principal: Principal, active: bool | None, limit: int, offset: int
) -> RidePage:
    query = filter_active(select(RideRow).where(RideRow.passenger_id == principal.sub), active)
    return await page_rides(session, query, limit, offset, view="passenger")


async def cancel_by_passenger(
    session: AsyncSession, principal: Principal, ride_id: uuid.UUID, reason: str | None
) -> RideRow:
    from app.modules.dispatch import presence
    from app.modules.dispatch.service import cancel_pending_offers  # avoid an import cycle

    ride = await get_passenger_ride(session, principal, ride_id, for_update=True)
    ride.cancel_reason = reason
    if ride.status == S.SCHEDULED:
        board_updated(session, ride.region_id)
    transition(session, ride, S.CANCELLED_BY_PASSENGER, Actor(principal.sub, ActorRole.PASSENGER))
    offered = await cancel_pending_offers(session, ride)
    await commit(session)
    for driver_id in offered:
        await presence.release_offer_lock(driver_id)
    return ride


# --- Ratings ---


async def rate(
    session: AsyncSession,
    ride: RideRow,
    from_user: str,
    from_role: ActorRole,
    data: RatingCreate,
) -> None:
    if ride.status != S.COMPLETED:
        raise HTTPException(status.HTTP_409_CONFLICT, "Można ocenić tylko zakończony kurs")
    to_user = ride.driver_id if from_role == ActorRole.PASSENGER else ride.passenger_id
    if to_user is None:  # pragma: no cover - a completed ride always has a driver
        raise HTTPException(status.HTTP_409_CONFLICT, "Kurs nie ma kierowcy")
    exists = await session.execute(
        select(Rating.id).where(Rating.ride_id == ride.id, Rating.from_role == from_role)
    )
    if exists.first() is not None:
        raise HTTPException(status.HTTP_409_CONFLICT, "Kurs został już oceniony")
    session.add(
        Rating(
            ride_id=ride.id,
            from_user_id=from_user,
            to_user_id=to_user,
            from_role=from_role,
            stars=data.stars,
            comment=data.comment,
        )
    )
    await session.commit()


async def average_rating(session: AsyncSession, user_id: str, as_role: ActorRole) -> float | None:
    """Average stars a user received in a role (as driver: rated by passengers, and vice versa)."""
    from_role = ActorRole.PASSENGER if as_role == ActorRole.DRIVER else ActorRole.DRIVER
    value = (
        await session.execute(
            select(func.avg(Rating.stars)).where(
                Rating.to_user_id == user_id, Rating.from_role == from_role
            )
        )
    ).scalar_one()
    return round(float(value), 2) if value is not None else None


# --- Serialisation ---


def _place(location: Any, address: str, place_id: str | None) -> Place:
    lat, lng = wkb_point_latlng(location)
    return Place(location=GeoPoint(lat=lat, lng=lng), address=address, place_id=place_id)


def pickup_point(ride: RideRow) -> GeoPoint:
    lat, lng = wkb_point_latlng(ride.pickup_location)
    return GeoPoint(lat=lat, lng=lng)


def destination_point(ride: RideRow) -> GeoPoint:
    lat, lng = wkb_point_latlng(ride.destination_location)
    return GeoPoint(lat=lat, lng=lng)


def distance_m(a: GeoPoint, b: GeoPoint) -> float:
    return haversine_m(a, b)


async def _passenger_info(session: AsyncSession, ride: RideRow) -> RidePassengerInfo:
    user = await session.get(User, ride.passenger_id)
    return RidePassengerInfo(
        id=ride.passenger_id,
        full_name=(user.full_name if user else None) or "Pasażer",
        phone=user.phone if user else None,
        rating_avg=await average_rating(session, ride.passenger_id, ActorRole.PASSENGER),
    )


async def _driver_info(session: AsyncSession, ride: RideRow) -> RideDriverInfo | None:
    if ride.driver_id is None:
        return None
    from app.modules.drivers import service as drivers_service  # avoid an import cycle

    return await drivers_service.ride_driver_info(session, ride.driver_id)


async def to_schema(session: AsyncSession, ride: RideRow, view: str) -> Ride:
    """`view`: passenger (no passenger block), driver or admin (with passenger block)."""
    return Ride(
        id=ride.id,
        status=RideStatus(ride.status),
        region_id=ride.region_id,
        pickup=_place(ride.pickup_location, ride.pickup_address, ride.pickup_place_id),
        destination=_place(
            ride.destination_location, ride.destination_address, ride.destination_place_id
        ),
        scheduled_at=ride.scheduled_at,
        requested_at=ride.requested_at,
        accepted_at=ride.accepted_at,
        started_at=ride.started_at,
        completed_at=ride.completed_at,
        cancelled_at=ride.cancelled_at,
        cancel_reason=ride.cancel_reason,
        price=ride.price,
        currency=ride.currency,
        payment_method=PaymentMethod(ride.payment_method),
        payment_status=PaymentStatus(ride.payment_status),
        distance_m=ride.distance_m,
        duration_s=ride.duration_s,
        route_polyline=ride.route_polyline,
        passenger_note=ride.passenger_note,
        driver=await _driver_info(session, ride),
        passenger=None if view == "passenger" else await _passenger_info(session, ride),
    )


async def created_response(session: AsyncSession, ride: RideRow) -> RideCreated:
    return RideCreated(ride=await to_schema(session, ride, "passenger"), payment=None)

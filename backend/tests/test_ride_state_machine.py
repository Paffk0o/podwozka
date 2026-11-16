"""Unit tests for every (current, target) pair of the ride state machine."""

import uuid
from datetime import UTC, datetime
from typing import Any

import pytest

from app.modules.rides.models import Ride, RideEvent
from app.modules.rides.schemas import RideStatus
from app.modules.rides.service import (
    ACTIVE_STATUSES,
    ALLOWED_TRANSITIONS,
    FINAL_STATUSES,
    Actor,
    ActorRole,
    InvalidTransitionError,
    transition,
)

S = RideStatus

EXPECTED_ALLOWED = {
    (S.REQUESTED, S.DISPATCHING),
    (S.REQUESTED, S.SCHEDULED),
    (S.REQUESTED, S.CANCELLED_BY_PASSENGER),
    (S.SCHEDULED, S.DISPATCHING),
    (S.SCHEDULED, S.ACCEPTED),
    (S.SCHEDULED, S.CANCELLED_BY_PASSENGER),
    (S.DISPATCHING, S.ACCEPTED),
    (S.DISPATCHING, S.NO_DRIVER),
    (S.DISPATCHING, S.CANCELLED_BY_PASSENGER),
    (S.ACCEPTED, S.DRIVER_ARRIVING),
    (S.ACCEPTED, S.SCHEDULED),
    (S.ACCEPTED, S.CANCELLED_BY_PASSENGER),
    (S.ACCEPTED, S.CANCELLED_BY_DRIVER),
    (S.DRIVER_ARRIVING, S.ARRIVED),
    (S.DRIVER_ARRIVING, S.CANCELLED_BY_PASSENGER),
    (S.DRIVER_ARRIVING, S.CANCELLED_BY_DRIVER),
    (S.ARRIVED, S.IN_PROGRESS),
    (S.ARRIVED, S.CANCELLED_BY_PASSENGER),
    (S.ARRIVED, S.CANCELLED_BY_DRIVER),
    (S.IN_PROGRESS, S.COMPLETED),
}

ALL_PAIRS = [(a, b) for a in RideStatus for b in RideStatus]


class FakeSession:
    def __init__(self) -> None:
        self.added: list[Any] = []
        self.info: dict[str, Any] = {}

    def add(self, obj: Any) -> None:
        self.added.append(obj)


def make_ride(current: RideStatus, driver_id: str | None = "driver-1") -> Ride:
    return Ride(id=uuid.uuid4(), status=current, passenger_id="p-1", driver_id=driver_id)


def test_transition_table_matches_the_specification() -> None:
    table = {(a, b) for a, targets in ALLOWED_TRANSITIONS.items() for b in targets}
    assert table == EXPECTED_ALLOWED
    assert {
        S.COMPLETED,
        S.CANCELLED_BY_PASSENGER,
        S.CANCELLED_BY_DRIVER,
        S.NO_DRIVER,
    } == FINAL_STATUSES
    assert S.SCHEDULED in ACTIVE_STATUSES and S.COMPLETED not in ACTIVE_STATUSES


@pytest.mark.parametrize(("current", "target"), ALL_PAIRS, ids=lambda s: str(s))
def test_each_transition(current: RideStatus, target: RideStatus) -> None:
    session = FakeSession()
    ride = make_ride(current)
    actor = Actor("p-1", ActorRole.PASSENGER)
    at = datetime(2026, 11, 16, 12, tzinfo=UTC)

    if (current, target) not in EXPECTED_ALLOWED:
        with pytest.raises(InvalidTransitionError) as exc:
            transition(session, ride, target, actor, at=at)  # type: ignore[arg-type]
        assert exc.value.status_code == 409
        assert ride.status == current  # unchanged
        assert session.added == []
        return

    transition(session, ride, target, actor, note="n", at=at)  # type: ignore[arg-type]
    assert ride.status == target
    (event,) = session.added
    assert isinstance(event, RideEvent)
    assert (event.from_status, event.to_status, event.actor_id) == (current, target, "p-1")
    assert event.note == "n" and event.at == at
    expected_ts = {
        S.ACCEPTED: "accepted_at",
        S.IN_PROGRESS: "started_at",
        S.COMPLETED: "completed_at",
        S.CANCELLED_BY_PASSENGER: "cancelled_at",
        S.CANCELLED_BY_DRIVER: "cancelled_at",
    }.get(target)
    if expected_ts:
        assert getattr(ride, expected_ts) == at
    channels = [channel for channel, _ in session.info["ride_outbox"]]
    assert channels[0] == f"ride:{ride.id}"
    # The assigned driver is told directly when someone else ends the ride.
    assert ("user:driver-1" in channels) == (target in FINAL_STATUSES)

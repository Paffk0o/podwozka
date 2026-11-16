import asyncio
import json
import uuid
from datetime import UTC, datetime, timedelta

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update

from app.core.db import get_sessionmaker
from app.core.redis import get_redis
from app.modules.dispatch import presence
from app.modules.dispatch import service as dispatch
from app.modules.dispatch.models import RideOffer
from app.modules.rides.models import Ride, RideEvent
from tests.conftest import TokenFactory
from tests.dispatch_helpers import current, driver_headers, make_driver, order_now, region_id
from tests.fakes import FakeQueue

pytestmark = pytest.mark.usefixtures("seeded")


async def offers_of(ride_id: str) -> list[tuple[str, str]]:
    async with get_sessionmaker()() as session:
        rows = await session.execute(
            select(RideOffer.driver_id, RideOffer.status)
            .where(RideOffer.ride_id == ride_id)
            .order_by(RideOffer.created_at)
        )
        return [tuple(r) for r in rows]  # type: ignore[misc]


async def ride_status(ride_id: str) -> str:
    async with get_sessionmaker()() as session:
        ride = await session.get(Ride, ride_id)
        assert ride is not None
        return ride.status


async def expire_now(offer_id: str) -> bool:
    async with get_sessionmaker()() as session:
        await session.execute(
            update(RideOffer)
            .where(RideOffer.id == offer_id)
            .values(expires_at=datetime.now(UTC) - timedelta(seconds=5))
        )
        await session.commit()
        return await dispatch.expire_offer(session, uuid.UUID(offer_id))


async def test_offer_goes_to_the_nearest_free_driver(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    make_token: TokenFactory,
    task_queue: FakeQueue,
) -> None:
    await make_driver("far", km_from_pickup=5)
    await make_driver("near", km_from_pickup=1)
    ride = await order_now(client, passenger_headers)
    assert ride["status"] == "dispatching"

    near = await current(client, driver_headers(make_token, "near"))
    offer = near["pending_offer"]
    assert offer is not None and offer["ride"]["id"] == ride["id"]
    assert 900 < offer["pickup_distance_m"] < 1100
    assert offer["pickup_eta_s"] > 0
    assert offer["ride"]["passenger"]["id"] == "passenger-1"  # drivers see who they pick up
    assert (await current(client, driver_headers(make_token, "far")))["pending_offer"] is None
    assert task_queue.expiries == [(offer["id"], 20.0)]


async def test_accept_assigns_driver_and_notifies_passenger(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    ride = await order_now(client, passenger_headers)
    headers = driver_headers(make_token, "d1")
    offer = (await current(client, headers))["pending_offer"]

    pubsub = get_redis().pubsub()
    await pubsub.subscribe(f"ride:{ride['id']}")
    await pubsub.get_message(timeout=1)

    response = await client.post(f"/drivers/me/offers/{offer['id']}/accept", headers=headers)
    assert response.status_code == 200, response.text
    assert response.json()["status"] == "accepted"

    received = []
    for _ in range(30):
        message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=0.1)
        if message:
            received.append(json.loads(message["data"])["type"])
        if len(received) == 2:
            break
    await pubsub.aclose()
    assert received == ["ride.status", "ride.driver_assigned"]

    seen = (await client.get(f"/rides/{ride['id']}", headers=passenger_headers)).json()
    assert seen["status"] == "accepted" and seen["accepted_at"] is not None
    assert seen["driver"]["id"] == "d1"
    assert seen["driver"]["vehicle"]["plate"] == "KWI1"
    assert seen["driver"]["full_name"] == "Kierowca d1"

    state = await current(client, headers)
    assert state["active_ride"]["id"] == ride["id"]
    assert state["pending_offer"] is None


async def test_decline_moves_to_next_driver_then_no_driver(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("a", km_from_pickup=1)
    await make_driver("b", km_from_pickup=2)
    ride = await order_now(client, passenger_headers)

    for driver in ("a", "b"):
        offer = (await current(client, driver_headers(make_token, driver)))["pending_offer"]
        response = await client.post(
            f"/drivers/me/offers/{offer['id']}/decline", headers=driver_headers(make_token, driver)
        )
        assert response.status_code == 204
    assert await offers_of(ride["id"]) == [("a", "declined"), ("b", "declined")]
    assert await ride_status(ride["id"]) == "no_driver"

    # Declining twice is harmless.
    again = await client.post(
        f"/drivers/me/offers/{offer['id']}/decline", headers=driver_headers(make_token, "b")
    )
    assert again.status_code == 204


async def test_expired_offer_goes_to_next_driver(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("slow", km_from_pickup=1)
    await make_driver("next", km_from_pickup=3)
    ride = await order_now(client, passenger_headers)
    offer = (await current(client, driver_headers(make_token, "slow")))["pending_offer"]

    pubsub = get_redis().pubsub()
    await pubsub.subscribe("user:slow")
    await pubsub.get_message(timeout=1)
    assert await expire_now(offer["id"]) is True
    message = None
    for _ in range(20):
        message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=0.1)
        if message:
            break
    await pubsub.aclose()
    assert message is not None
    assert json.loads(message["data"]) == {"type": "offer.expired", "offer_id": offer["id"]}

    assert await offers_of(ride["id"]) == [("slow", "expired"), ("next", "pending")]
    late = await client.post(
        f"/drivers/me/offers/{offer['id']}/accept", headers=driver_headers(make_token, "slow")
    )
    assert late.status_code == 409

    # A second expiry run (e.g. the beat sweeper) is a no-op.
    assert await expire_now(offer["id"]) is False


async def test_only_one_of_two_racing_drivers_wins(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("x", km_from_pickup=1)
    await make_driver("y", km_from_pickup=2)
    ride = await order_now(client, passenger_headers)
    first = (await current(client, driver_headers(make_token, "x")))["pending_offer"]
    # Simulate the worst case: a second live offer for the same ride at the same moment.
    async with get_sessionmaker()() as session:
        second = RideOffer(
            id=uuid.uuid4(),
            ride_id=uuid.UUID(ride["id"]),
            driver_id="y",
            status="pending",
            pickup_distance_m=2000,
            pickup_eta_s=200,
            expires_at=datetime.now(UTC) + timedelta(seconds=20),
        )
        session.add(second)
        await session.commit()

    responses = await asyncio.gather(
        client.post(
            f"/drivers/me/offers/{first['id']}/accept", headers=driver_headers(make_token, "x")
        ),
        client.post(
            f"/drivers/me/offers/{second.id}/accept", headers=driver_headers(make_token, "y")
        ),
    )
    codes = sorted(r.status_code for r in responses)
    assert codes == [200, 409]
    winner = next(r for r in responses if r.status_code == 200).json()
    async with get_sessionmaker()() as session:
        db_ride = await session.get(Ride, ride["id"])
        accepted_events = (
            await session.execute(
                select(RideEvent).where(
                    RideEvent.ride_id == ride["id"], RideEvent.to_status == "accepted"
                )
            )
        ).all()
    assert db_ride is not None and db_ride.driver_id == winner["driver"]["id"]
    assert len(accepted_events) == 1


async def test_suspended_driver_cannot_accept_and_is_not_offered(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    admin_headers: dict[str, str],
    make_token: TokenFactory,
) -> None:
    await make_driver("bad", km_from_pickup=1)
    await make_driver("good", km_from_pickup=4)
    ride = await order_now(client, passenger_headers)
    offer = (await current(client, driver_headers(make_token, "bad")))["pending_offer"]

    await client.post(
        "/admin/drivers/bad/suspend", headers=admin_headers, json={"reason": "Skargi"}
    )
    # The token still carries the `driver` role — the database decides.
    response = await client.post(
        f"/drivers/me/offers/{offer['id']}/accept", headers=driver_headers(make_token, "bad")
    )
    assert response.status_code == 403
    assert (
        await client.get("/drivers/me/current", headers=driver_headers(make_token, "bad"))
    ).status_code == 403

    await expire_now(offer["id"])
    assert (await offers_of(ride["id"]))[-1] == ("good", "pending")


async def test_offline_stale_busy_and_other_region_drivers_are_skipped(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    make_token: TokenFactory,
) -> None:
    await make_driver("offline", km_from_pickup=0.5, online=False)
    await make_driver("pending-app", km_from_pickup=0.6, status="pending")
    await make_driver("stale", km_from_pickup=0.7)
    await get_redis().delete(presence.location_key("stale"))
    await make_driver("busy", km_from_pickup=0.8)
    await make_driver("elsewhere", km_from_pickup=0.9, region="Gmina Niepołomice")
    # "busy" already works on another ride.
    other = await order_now(client, {"Authorization": passenger_headers["Authorization"]})
    offer = (await current(client, driver_headers(make_token, "busy")))["pending_offer"]
    await client.post(
        f"/drivers/me/offers/{offer['id']}/accept", headers=driver_headers(make_token, "busy")
    )

    second_passenger = {
        "Authorization": "Bearer " + make_token(sub="passenger-2", client="passenger-app")
    }
    ride = await order_now(client, second_passenger)
    assert ride["id"] != other["id"]
    assert await offers_of(ride["id"]) == []
    assert await ride_status(ride["id"]) == "no_driver"
    # The stale driver was dropped from the GEO set.
    members = await get_redis().zrange(presence.online_key(await region_id()), 0, -1)
    assert "stale" not in members


async def test_one_driver_is_not_offered_two_rides_at_once(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("only")
    first = await order_now(client, passenger_headers)
    second = await order_now(
        client, {"Authorization": "Bearer " + make_token(sub="passenger-2", client="passenger-app")}
    )
    assert await offers_of(first["id"]) == [("only", "pending")]
    assert await offers_of(second["id"]) == []
    assert await ride_status(second["id"]) == "no_driver"


async def test_going_offline_passes_the_offer_on(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("leaving", km_from_pickup=1)
    await make_driver("staying", km_from_pickup=2)
    ride = await order_now(client, passenger_headers)
    headers = driver_headers(make_token, "leaving")
    response = await client.put("/drivers/me/availability", headers=headers, json={"online": False})
    assert response.status_code == 200 and response.json()["online"] is False
    assert await offers_of(ride["id"]) == [("leaving", "declined"), ("staying", "pending")]
    members = await get_redis().zrange(presence.online_key(await region_id()), 0, -1)
    assert "leaving" not in members

    back = await client.put("/drivers/me/availability", headers=headers, json={"online": True})
    assert back.json()["online"] is True


async def test_passenger_cancel_withdraws_the_offer(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    ride = await order_now(client, passenger_headers)
    await client.post(f"/rides/{ride['id']}/cancel", headers=passenger_headers, json={})
    assert await offers_of(ride["id"]) == [("d1", "cancelled")]
    # The driver's lock is released, so the next ride can be offered right away.
    assert await presence.lock_for_offer("d1", 5) is True


async def test_sweeper_recovers_lost_expiries_and_stuck_rides(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("a", km_from_pickup=1)
    ride = await order_now(client, passenger_headers)
    async with get_sessionmaker()() as session:
        await session.execute(
            update(RideOffer).values(expires_at=datetime.now(UTC) - timedelta(minutes=1))
        )
        await session.commit()
        assert await dispatch.sweep(session) >= 1
    assert await offers_of(ride["id"]) == [("a", "expired")]
    assert await ride_status(ride["id"]) == "no_driver"

    # A ride left in `dispatching` without any offer (e.g. the API crashed) is picked up again.
    await make_driver("b", km_from_pickup=1)
    async with get_sessionmaker()() as session:
        await session.execute(
            update(Ride)
            .where(Ride.id == ride["id"])
            .values(status="dispatching", updated_at=datetime.now(UTC) - timedelta(minutes=5))
        )
        await session.commit()
        await dispatch.sweep(session)
    assert await offers_of(ride["id"]) == [("a", "expired"), ("b", "pending")]


async def test_driver_endpoints_need_an_approved_profile(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    headers = driver_headers(make_token, "ghost")
    assert (await client.get("/drivers/me/current", headers=headers)).status_code == 403
    response = await client.put("/drivers/me/availability", headers=headers, json={"online": True})
    assert response.status_code == 403
    passenger_only = {"Authorization": "Bearer " + make_token(sub="p")}
    assert (await client.get("/drivers/me/current", headers=passenger_only)).status_code == 403


async def test_unknown_offer_is_404(client: AsyncClient, make_token: TokenFactory) -> None:
    await make_driver("d1")
    missing = uuid.uuid4()
    response = await client.post(
        f"/drivers/me/offers/{missing}/accept", headers=driver_headers(make_token, "d1")
    )
    assert response.status_code == 404

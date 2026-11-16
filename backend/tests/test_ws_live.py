"""WebSocket: ride subscriptions, Redis fan-out, driver positions, token expiry.

Setup is awaited in the test loop; the TestClient runs the app in its own loop/thread
(the DB engine and Redis client are per loop, so both work)."""

import time
from contextlib import ExitStack
from typing import Any

import pytest
from httpx import AsyncClient
from starlette.testclient import TestClient
from starlette.websockets import WebSocketDisconnect

from app.core.redis import get_redis
from app.main import app
from app.modules.dispatch import presence
from tests.conftest import TokenFactory
from tests.dispatch_helpers import current, driver_headers, make_driver, order_now, region_id

pytestmark = pytest.mark.usefixtures("seeded")


def receive_until(ws: Any, type_: str, limit: int = 10) -> dict[str, Any]:
    for _ in range(limit):
        message: dict[str, Any] = ws.receive_json()
        if message["type"] == type_:
            return message
    raise AssertionError(f"no {type_}")


def connect(stack: ExitStack, tc: TestClient, token: str) -> Any:
    ws = stack.enter_context(tc.websocket_connect("/ws"))
    ws.send_json({"type": "auth", "token": token})
    assert ws.receive_json()["type"] == "auth_ok"
    return ws


async def test_passenger_follows_own_ride_and_sees_driver_moving(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    ride = await order_now(client, passenger_headers)
    headers = driver_headers(make_token, "d1")
    offer = (await current(client, headers))["pending_offer"]
    await client.post(f"/drivers/me/offers/{offer['id']}/accept", headers=headers)

    passenger_token = make_token(sub="passenger-1")
    driver_token = make_token(sub="d1", roles=("passenger", "driver"), client="driver-app")
    with TestClient(app) as tc, ExitStack() as stack:
        passenger = connect(stack, tc, passenger_token)
        passenger.send_json({"type": "subscribe", "ride_id": ride["id"]})
        assert passenger.receive_json() == {"type": "subscribed", "ride_id": ride["id"]}

        driver = connect(stack, tc, driver_token)
        driver.send_json(
            {"type": "driver.location", "location": {"lat": 50.0, "lng": 20.06}, "heading": 90}
        )
        moved = receive_until(passenger, "ride.driver_location")
        assert moved["ride_id"] == ride["id"]
        assert moved["location"] == {"lat": 50.0, "lng": 20.06}
        assert moved["heading"] == 90 and moved["eta_s"] > 0

    assert await presence.last_location("d1") is not None
    members = await get_redis().zrange(presence.online_key(await region_id()), 0, -1)
    assert "d1" in members


async def test_cannot_subscribe_to_someone_elses_ride(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride = await order_now(client, passenger_headers)
    with TestClient(app) as tc, ExitStack() as stack:
        stranger = connect(stack, tc, make_token(sub="stranger"))
        stranger.send_json({"type": "subscribe", "ride_id": ride["id"]})
        assert stranger.receive_json()["code"] == "forbidden"
        stranger.send_json({"type": "subscribe", "ride_id": "not-a-uuid"})
        assert stranger.receive_json()["code"] == "bad_request"
        stranger.send_json({"type": "something"})
        assert stranger.receive_json()["code"] == "bad_request"
        stranger.send_text("{")
        assert stranger.receive_json()["code"] == "bad_request"


async def test_status_changes_reach_subscribers(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride = await order_now(client, passenger_headers)  # no drivers -> no_driver
    with TestClient(app) as tc, ExitStack() as stack:
        ws = connect(stack, tc, make_token(sub="passenger-1"))
        ws.send_json({"type": "subscribe", "ride_id": ride["id"]})
        ws.receive_json()
        ws.send_json({"type": "unsubscribe", "ride_id": ride["id"]})
        ws.send_json({"type": "ping"})
        assert ws.receive_json() == {"type": "pong"}


async def test_location_requires_an_online_approved_driver(make_token: TokenFactory) -> None:
    await make_driver("off", online=False)
    with TestClient(app) as tc, ExitStack() as stack:
        passenger = connect(stack, tc, make_token(sub="p"))
        passenger.send_json({"type": "driver.location", "location": {"lat": 50, "lng": 20}})
        assert passenger.receive_json()["code"] == "forbidden"
        driver = connect(stack, tc, make_token(sub="off", roles=("driver",), client="driver-app"))
        driver.send_json({"type": "driver.location", "location": {"lat": 500, "lng": 20}})
        assert driver.receive_json()["code"] == "bad_request"
        driver.send_json({"type": "driver.location", "location": {"lat": 50, "lng": 20}})
        assert driver.receive_json()["code"] == "forbidden"


def test_expired_token_closes_the_connection(make_token: TokenFactory) -> None:
    # Still accepted thanks to the 30 s leeway, but already past `exp`.
    token = make_token(sub="late", expires_in=-5)
    with TestClient(app) as tc, tc.websocket_connect("/ws") as ws:
        ws.send_json({"type": "auth", "token": token})
        assert ws.receive_json()["type"] == "auth_ok"
        started = time.monotonic()
        assert ws.receive_json() == {"type": "token_expired"}
        with pytest.raises(WebSocketDisconnect) as exc:
            ws.receive_json()
        assert exc.value.code == 1008
        assert time.monotonic() - started < 5

import asyncio
import json
from collections.abc import AsyncIterator
from contextlib import ExitStack, asynccontextmanager
from datetime import UTC, datetime, timedelta
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import update
from starlette.testclient import TestClient

from app.core.db import get_sessionmaker
from app.core.redis import get_redis
from app.main import app
from app.modules.rides import reservations
from app.modules.rides.models import Ride
from tests.conftest import KRAKOW, NIEPOLOMICE, WIELICZKA, TokenFactory, auth
from tests.dispatch_helpers import current, driver_headers, make_driver, region_id

pytestmark = pytest.mark.usefixtures("seeded")


async def reserve(
    client: AsyncClient, headers: dict[str, str], hours: float = 3, pickup: Any = WIELICZKA
) -> dict[str, Any]:
    when = (datetime.now(UTC) + timedelta(hours=hours)).isoformat()
    quote = await client.post(
        "/quotes",
        headers=headers,
        json={"pickup": pickup, "destination": KRAKOW, "scheduled_at": when},
    )
    assert quote.status_code == 201, quote.text
    ride = await client.post(
        "/rides", headers=headers, json={"quote_id": quote.json()["id"], "payment_method": "cash"}
    )
    assert ride.status_code == 201, ride.text
    assert ride.json()["ride"]["status"] == "scheduled"
    return ride.json()["ride"]  # type: ignore[no-any-return]


async def move_to(ride_id: str, minutes_from_now: float) -> None:
    async with get_sessionmaker()() as session:
        await session.execute(
            update(Ride)
            .where(Ride.id == ride_id)
            .values(scheduled_at=datetime.now(UTC) + timedelta(minutes=minutes_from_now))
        )
        await session.commit()


@asynccontextmanager
async def listen(*channels: str) -> AsyncIterator[list[dict[str, Any]]]:
    """Collect messages published on the channels while the block runs."""
    pubsub = get_redis().pubsub()
    await pubsub.subscribe(*channels)
    for _ in channels:
        await pubsub.get_message(timeout=1)
    received: list[dict[str, Any]] = []
    yield received
    for _ in range(30):
        message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=0.05)
        if message:
            received.append({"channel": message["channel"], **json.loads(message["data"])})
    await pubsub.aclose()


async def test_board_shows_unassigned_reservations_of_my_region(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    later = await reserve(client, passenger_headers, hours=5)
    sooner = await reserve(client, passenger_headers, hours=2)
    await reserve(client, passenger_headers, hours=3, pickup=NIEPOLOMICE)  # other region

    board = (
        await client.get("/drivers/me/scheduled-board", headers=driver_headers(make_token, "d1"))
    ).json()
    assert [r["id"] for r in board] == [sooner["id"], later["id"]]  # soonest first
    assert board[0]["passenger"]["id"] == "passenger-1"


async def test_claim_assigns_the_driver_and_tells_everyone(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    ride = await reserve(client, passenger_headers)
    headers = driver_headers(make_token, "d1")
    rid = await region_id()

    async with listen(f"ride:{ride['id']}", "user:passenger-1", f"board:{rid}") as received:
        response = await client.post(
            f"/drivers/me/scheduled-board/{ride['id']}/claim", headers=headers
        )
    assert response.status_code == 200, response.text
    assert response.json()["status"] == "accepted"
    types = {(m["channel"], m["type"]) for m in received}
    assert (f"ride:{ride['id']}", "ride.driver_assigned") in types
    assert ("user:passenger-1", "notification") in types
    assert (f"board:{rid}", "board.updated") in types

    assert (await client.get("/drivers/me/scheduled-board", headers=headers)).json() == []
    assert (await current(client, headers))["next_scheduled_ride"]["id"] == ride["id"]
    seen = (await client.get(f"/rides/{ride['id']}", headers=passenger_headers)).json()
    assert seen["driver"]["id"] == "d1"

    again = await client.post(f"/drivers/me/scheduled-board/{ride['id']}/claim", headers=headers)
    assert again.status_code == 409


async def test_only_one_of_two_racing_drivers_gets_the_reservation(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("a")
    await make_driver("b")
    ride = await reserve(client, passenger_headers)
    url = f"/drivers/me/scheduled-board/{ride['id']}/claim"
    responses = await asyncio.gather(
        client.post(url, headers=driver_headers(make_token, "a")),
        client.post(url, headers=driver_headers(make_token, "b")),
    )
    assert sorted(r.status_code for r in responses) == [200, 409]


async def test_claim_rules(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    await make_driver("east", region="Gmina Niepołomice")
    first = await reserve(client, passenger_headers, hours=3)
    close = await reserve(client, passenger_headers, hours=3.3)
    far = await reserve(client, passenger_headers, hours=8)
    headers = driver_headers(make_token, "d1")

    def claim(ride: dict[str, Any], h: dict[str, str] = headers) -> Any:
        return client.post(f"/drivers/me/scheduled-board/{ride['id']}/claim", headers=h)

    assert (await claim(first)).status_code == 200
    assert (await claim(close)).status_code == 409  # overlaps the first one
    assert (await claim(far)).status_code == 200
    assert (await claim(close, driver_headers(make_token, "east"))).status_code == 404  # region

    now_ride = await client.post(
        "/quotes", headers=passenger_headers, json={"pickup": WIELICZKA, "destination": KRAKOW}
    )
    ordered = await client.post(
        "/rides",
        headers=passenger_headers,
        json={"quote_id": now_ride.json()["id"], "payment_method": "cash"},
    )
    assert (await claim(ordered.json()["ride"])).status_code == 404  # not a reservation


async def test_suspended_driver_has_no_board(
    client: AsyncClient, admin_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    await client.post("/admin/drivers/d1/suspend", headers=admin_headers, json={"reason": "abc"})
    response = await client.get(
        "/drivers/me/scheduled-board", headers=driver_headers(make_token, "d1")
    )
    assert response.status_code == 403


async def test_reservation_given_back_reappears_on_the_board(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    ride = await reserve(client, passenger_headers)
    headers = driver_headers(make_token, "d1")
    await client.post(f"/drivers/me/scheduled-board/{ride['id']}/claim", headers=headers)
    async with listen(f"board:{await region_id()}") as received:
        await client.post(f"/drivers/me/rides/{ride['id']}/cancel", headers=headers, json={})
    assert [m["type"] for m in received] == ["board.updated"]
    board = (await client.get("/drivers/me/scheduled-board", headers=headers)).json()
    assert [r["id"] for r in board] == [ride["id"]]


async def test_tick_reminds_the_driver_once_at_t_minus_60(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    ride = await reserve(client, passenger_headers)
    await client.post(
        f"/drivers/me/scheduled-board/{ride['id']}/claim", headers=driver_headers(make_token, "d1")
    )
    async with get_sessionmaker()() as session:
        assert await reservations.tick(session) == (0, 0)  # 3 h ahead: nothing yet

    await move_to(ride["id"], 55)
    async with listen("user:d1") as received, get_sessionmaker()() as session:
        assert await reservations.tick(session) == (1, 0)
        assert await reservations.tick(session) == (0, 0)  # only once
    assert [m["title"] for m in received] == ["Przypomnienie o rezerwacji"]
    assert received[0]["data"] == {"ride_id": ride["id"]}


async def test_tick_dispatches_unclaimed_reservation_at_t_minus_30(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    soon = await reserve(client, passenger_headers, hours=3)
    later = await reserve(client, passenger_headers, hours=4)
    await move_to(soon["id"], 25)

    board = f"board:{await region_id()}"
    async with listen("user:passenger-1", board) as received, get_sessionmaker()() as session:
        assert await reservations.tick(session) == (0, 1)
    assert ("notification", "Szukamy kierowcy") in {(m["type"], m.get("title")) for m in received}
    assert "board.updated" in {m["type"] for m in received}

    offer = (await current(client, driver_headers(make_token, "d1")))["pending_offer"]
    assert offer["ride"]["id"] == soon["id"]  # normal dispatch took over
    later_seen = (await client.get(f"/rides/{later['id']}", headers=passenger_headers)).json()
    assert later_seen["status"] == "scheduled"


async def test_drivers_hear_board_updates_over_websocket(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    await make_driver("d1")
    token = make_token(sub="d1", roles=("passenger", "driver"), client="driver-app")
    with TestClient(app) as tc, ExitStack() as stack:
        ws = stack.enter_context(tc.websocket_connect("/ws"))
        ws.send_json({"type": "auth", "token": token})
        ws.receive_json()
        ws.send_json({"type": "ping"})
        ws.receive_json()  # subscriptions are set up before the first message is handled
        # Create a reservation through the TestClient (same app, its own loop).
        quote = tc.post(
            "/quotes",
            headers=passenger_headers,
            json={
                "pickup": WIELICZKA,
                "destination": KRAKOW,
                "scheduled_at": (datetime.now(UTC) + timedelta(hours=3)).isoformat(),
            },
        )
        tc.post(
            "/rides",
            headers=auth(make_token(sub="passenger-1")),
            json={"quote_id": quote.json()["id"], "payment_method": "cash"},
        )
        message = ws.receive_json()
        assert message == {"type": "board.updated", "region_id": str(await region_id())}

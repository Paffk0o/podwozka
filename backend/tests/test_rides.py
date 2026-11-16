import asyncio
import json
from datetime import UTC, datetime, timedelta
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update

from app.core.config import get_settings
from app.core.db import get_sessionmaker
from app.core.redis import get_redis
from app.modules.pricing.models import QuoteRecord
from app.modules.rides.models import Ride, RideEvent
from app.modules.users.models import User
from tests.conftest import KRAKOW, NIEPOLOMICE, WIELICZKA, TokenFactory, auth

pytestmark = pytest.mark.usefixtures("seeded")


async def quote(
    client: AsyncClient, headers: dict[str, str], scheduled_in: timedelta | None = None, **body: Any
) -> dict[str, Any]:
    body.setdefault("pickup", WIELICZKA)
    body.setdefault("destination", KRAKOW)
    if scheduled_in is not None:
        body["scheduled_at"] = (datetime.now(UTC) + scheduled_in).isoformat()
    response = await client.post("/quotes", headers=headers, json=body)
    assert response.status_code == 201, response.text
    return response.json()  # type: ignore[no-any-return]


async def order(
    client: AsyncClient,
    headers: dict[str, str],
    scheduled_in: timedelta | None = None,
    method: str = "cash",
    **body: Any,
) -> dict[str, Any]:
    q = await quote(client, headers, scheduled_in, **body)
    response = await client.post(
        "/rides",
        headers=headers,
        json={"quote_id": q["id"], "payment_method": method, "passenger_note": "Brama od podwórza"},
    )
    assert response.status_code == 201, response.text
    return response.json()["ride"]  # type: ignore[no-any-return]


async def set_ride(ride_id: str, **values: Any) -> None:
    async with get_sessionmaker()() as session:
        await session.execute(update(Ride).where(Ride.id == ride_id).values(**values))
        await session.commit()


async def test_cash_ride_now_goes_to_dispatching(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    q = await quote(client, passenger_headers)
    response = await client.post(
        "/rides", headers=passenger_headers, json={"quote_id": q["id"], "payment_method": "cash"}
    )
    assert response.status_code == 201
    body = response.json()
    assert body["payment"] is None
    ride = body["ride"]
    assert ride["status"] == "dispatching"
    assert ride["payment_method"] == "cash"
    assert ride["payment_status"] == "cash_due"
    assert ride["price"] == q["price"]
    assert ride["pickup"] == q["pickup"]
    assert ride["destination"]["location"] == KRAKOW["location"]
    assert ride["driver"] is None and ride["passenger"] is None
    assert ride["scheduled_at"] is None

    async with get_sessionmaker()() as session:
        events = (
            await session.execute(
                select(RideEvent.from_status, RideEvent.to_status)
                .where(RideEvent.ride_id == ride["id"])
                .order_by(RideEvent.id)
            )
        ).all()
        db_ride = await session.get(Ride, ride["id"])
        user = await session.get(User, "passenger-1")
    assert [tuple(e) for e in events] == [(None, "requested"), ("requested", "dispatching")]
    assert db_ride is not None and str(db_ride.tariff_id) == q["tariff_id"]
    assert user is not None  # profile created from the token on first order


async def test_reservation_goes_to_scheduled(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    ride = await order(client, passenger_headers, scheduled_in=timedelta(hours=3))
    assert ride["status"] == "scheduled"
    assert ride["scheduled_at"] is not None


async def test_online_payments_are_not_available_yet(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    q = await quote(client, passenger_headers)
    for method in ("card", "blik"):
        response = await client.post(
            "/rides",
            headers=passenger_headers,
            json={"quote_id": q["id"], "payment_method": method},
        )
        assert response.status_code == 422
        assert "etapie 3" in response.json()["detail"]


async def test_quote_rules(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    q = await quote(client, passenger_headers, scheduled_in=timedelta(hours=2))
    stranger = auth(make_token(sub="stranger"))
    body = {"quote_id": q["id"], "payment_method": "cash"}
    assert (await client.post("/rides", headers=stranger, json=body)).status_code == 404

    assert (await client.post("/rides", headers=passenger_headers, json=body)).status_code == 201
    reused = await client.post("/rides", headers=passenger_headers, json=body)
    assert reused.status_code == 409

    expired = await quote(client, passenger_headers)
    async with get_sessionmaker()() as session:
        await session.execute(
            update(QuoteRecord)
            .where(QuoteRecord.id == expired["id"])
            .values(expires_at=datetime.now(UTC) - timedelta(seconds=1))
        )
        await session.commit()
    response = await client.post(
        "/rides",
        headers=passenger_headers,
        json={"quote_id": expired["id"], "payment_method": "cash"},
    )
    assert response.status_code == 409
    assert "wygasła" in response.json()["detail"]


async def test_one_ongoing_ride_now_at_a_time(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    await order(client, passenger_headers)
    q = await quote(client, passenger_headers)
    response = await client.post(
        "/rides", headers=passenger_headers, json={"quote_id": q["id"], "payment_method": "cash"}
    )
    assert response.status_code == 409
    # Reservations are still allowed.
    await order(client, passenger_headers, scheduled_in=timedelta(hours=5))


async def test_verified_phone_can_be_required(
    client: AsyncClient, passenger_headers: dict[str, str], monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(get_settings(), "require_verified_phone", True)
    q = await quote(client, passenger_headers)
    response = await client.post(
        "/rides", headers=passenger_headers, json={"quote_id": q["id"], "payment_method": "cash"}
    )
    assert response.status_code == 422
    assert "telefonu" in response.json()["detail"]


async def test_passenger_sees_only_own_rides(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    mine = await order(client, passenger_headers)
    other_headers = auth(make_token(sub="passenger-2"))
    theirs = await order(client, other_headers, pickup=NIEPOLOMICE)

    listed = (await client.get("/rides", headers=passenger_headers)).json()
    assert [r["id"] for r in listed["items"]] == [mine["id"]]
    assert listed["total"] == 1

    assert (
        await client.get(f"/rides/{theirs['id']}", headers=passenger_headers)
    ).status_code == 404
    own = await client.get(f"/rides/{mine['id']}", headers=passenger_headers)
    assert own.status_code == 200 and own.json()["passenger_note"] == "Brama od podwórza"

    cancel = await client.post(f"/rides/{theirs['id']}/cancel", headers=passenger_headers, json={})
    assert cancel.status_code == 404
    rating = await client.post(
        f"/rides/{theirs['id']}/rating", headers=passenger_headers, json={"stars": 1}
    )
    assert rating.status_code == 404


async def test_list_filters_and_pagination(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    first = await order(client, passenger_headers, scheduled_in=timedelta(hours=2))
    second = await order(client, passenger_headers, scheduled_in=timedelta(hours=3))
    await client.post(f"/rides/{first['id']}/cancel", headers=passenger_headers, json={})

    page = (await client.get("/rides?limit=1", headers=passenger_headers)).json()
    assert page["total"] == 2 and len(page["items"]) == 1
    assert page["items"][0]["id"] == second["id"]  # newest first

    active = (await client.get("/rides?active=true", headers=passenger_headers)).json()
    finished = (await client.get("/rides?active=false", headers=passenger_headers)).json()
    assert [r["id"] for r in active["items"]] == [second["id"]]
    assert [r["id"] for r in finished["items"]] == [first["id"]]


async def test_cancel_by_passenger(client: AsyncClient, passenger_headers: dict[str, str]) -> None:
    ride = await order(client, passenger_headers)
    response = await client.post(
        f"/rides/{ride['id']}/cancel", headers=passenger_headers, json={"reason": "Zmiana planów"}
    )
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "cancelled_by_passenger"
    assert body["cancel_reason"] == "Zmiana planów"
    assert body["cancelled_at"] is not None

    again = await client.post(f"/rides/{ride['id']}/cancel", headers=passenger_headers, json={})
    assert again.status_code == 409


async def test_cannot_cancel_ride_in_progress(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    ride = await order(client, passenger_headers)
    await set_ride(ride["id"], status="in_progress")
    response = await client.post(f"/rides/{ride['id']}/cancel", headers=passenger_headers, json={})
    assert response.status_code == 409


async def test_rating_only_once_and_only_after_completion(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride = await order(client, passenger_headers)
    url = f"/rides/{ride['id']}/rating"
    assert (await client.post(url, headers=passenger_headers, json={"stars": 5})).status_code == 409

    async with get_sessionmaker()() as session:
        session.add(User(id="driver-1", full_name="Kierowca", phone_verified=False))
        await session.commit()
    await set_ride(ride["id"], status="completed", driver_id="driver-1")

    assert (await client.post(url, headers=passenger_headers, json={"stars": 6})).status_code == 422
    ok = await client.post(url, headers=passenger_headers, json={"stars": 5, "comment": "Super"})
    assert ok.status_code == 204
    assert (await client.post(url, headers=passenger_headers, json={"stars": 4})).status_code == 409


async def test_status_changes_are_published_to_the_ride_channel(
    client: AsyncClient, passenger_headers: dict[str, str]
) -> None:
    ride = await order(client, passenger_headers)
    pubsub = get_redis().pubsub()
    await pubsub.subscribe(f"ride:{ride['id']}")
    await pubsub.get_message(timeout=1)  # subscribe confirmation
    await client.post(f"/rides/{ride['id']}/cancel", headers=passenger_headers, json={})
    message = None
    for _ in range(20):
        message = await pubsub.get_message(ignore_subscribe_messages=True, timeout=0.1)
        if message:
            break
        await asyncio.sleep(0.05)
    await pubsub.aclose()
    assert message is not None
    payload = json.loads(message["data"])
    assert payload["type"] == "ride.status"
    assert payload["status"] == "cancelled_by_passenger"
    assert payload["ride_id"] == ride["id"]


async def test_driver_role_cannot_use_passenger_endpoints(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    headers = auth(make_token(roles=("driver",), client="driver-app"))
    assert (await client.get("/rides", headers=headers)).status_code == 403

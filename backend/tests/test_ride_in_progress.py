from datetime import UTC, date, datetime, timedelta
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import select, update

from app.common.schemas import GeoPoint
from app.core.db import get_sessionmaker
from app.modules.dispatch import presence
from app.modules.earnings.models import LedgerEntry
from app.modules.rides.models import Ride, RideEvent
from tests.conftest import NIEPOLOMICE, TokenFactory
from tests.dispatch_helpers import current, driver_headers, make_driver, order_now, region_id

pytestmark = pytest.mark.usefixtures("seeded")


async def accepted_ride(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    make_token: TokenFactory,
    driver: str = "d1",
    **body: Any,
) -> tuple[dict[str, Any], dict[str, str]]:
    region = "Gmina Niepołomice" if body.get("pickup") == NIEPOLOMICE else "Gmina Wieliczka"
    await make_driver(driver, region=region)
    if region != "Gmina Wieliczka":
        # make_driver places drivers near the Wieliczka pickup; move to the actual pickup.
        await presence.update_location(
            await region_id(region), driver, GeoPoint(lat=50.035, lng=20.22)
        )
    ride = await order_now(client, passenger_headers, **body)
    headers = driver_headers(make_token, driver)
    offer = (await current(client, headers))["pending_offer"]
    accepted = await client.post(f"/drivers/me/offers/{offer['id']}/accept", headers=headers)
    assert accepted.status_code == 200, accepted.text
    return ride, headers


async def act(client: AsyncClient, headers: dict[str, str], ride_id: str, action: str) -> Any:
    return await client.post(
        f"/drivers/me/rides/{ride_id}/actions", headers=headers, json={"action": action}
    )


async def drive_to_completion(client: AsyncClient, headers: dict[str, str], ride_id: str) -> Any:
    for action in ("depart", "arrived", "start", "complete"):
        response = await act(client, headers, ride_id, action)
        assert response.status_code == 200, (action, response.text)
    return response.json()


async def test_full_ride_with_cash_and_earnings(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride, headers = await accepted_ride(client, passenger_headers, make_token)
    done = await drive_to_completion(client, headers, ride["id"])
    assert done["status"] == "completed"
    assert done["started_at"] is not None and done["completed_at"] is not None
    assert done["payment_status"] == "cash_due"
    assert done["passenger"]["id"] == "passenger-1"

    async with get_sessionmaker()() as session:
        statuses = (
            (
                await session.execute(
                    select(RideEvent.to_status)
                    .where(RideEvent.ride_id == ride["id"])
                    .order_by(RideEvent.id)
                )
            )
            .scalars()
            .all()
        )
        entry = (
            await session.execute(select(LedgerEntry).where(LedgerEntry.ride_id == ride["id"]))
        ).scalar_one()
    assert statuses == [
        "requested",
        "dispatching",
        "accepted",
        "driver_arriving",
        "arrived",
        "in_progress",
        "completed",
    ]
    price = ride["price"]
    assert (entry.gross, entry.commission_percent) == (price, 10)  # Wieliczka tariff
    assert entry.commission == (price * 10 + 50) // 100
    assert entry.net == price - entry.commission
    assert entry.cash_collected is False

    cash = await client.post(f"/drivers/me/rides/{ride['id']}/cash-collected", headers=headers)
    assert cash.status_code == 200 and cash.json()["payment_status"] == "cash_collected"
    again = await client.post(f"/drivers/me/rides/{ride['id']}/cash-collected", headers=headers)
    assert again.status_code == 200  # idempotent

    today = date.today().isoformat()
    earnings = (
        await client.get(f"/drivers/me/earnings?date_from={today}&date_to={today}", headers=headers)
    ).json()
    assert earnings["rides_count"] == 1
    assert earnings["gross"] == price
    assert earnings["commission"] == entry.commission
    assert earnings["net"] == entry.net
    assert earnings["cash_collected"] == price
    assert earnings["commission_due_from_cash"] == entry.commission
    assert earnings["items"][0]["payment_method"] == "cash"

    passenger_view = (await client.get(f"/rides/{ride['id']}", headers=passenger_headers)).json()
    assert passenger_view["payment_status"] == "cash_collected"

    # No active ride any more: the driver can be offered the next one.
    assert (await current(client, headers))["active_ride"] is None


async def test_commission_uses_the_rides_own_tariff(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride, headers = await accepted_ride(client, passenger_headers, make_token, pickup=NIEPOLOMICE)
    await drive_to_completion(client, headers, ride["id"])
    async with get_sessionmaker()() as session:
        entry = (
            await session.execute(select(LedgerEntry).where(LedgerEntry.ride_id == ride["id"]))
        ).scalar_one()
    assert entry.commission_percent == 12


async def test_actions_must_follow_the_state_machine(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride, headers = await accepted_ride(client, passenger_headers, make_token)
    assert (await act(client, headers, ride["id"], "start")).status_code == 409
    assert (await act(client, headers, ride["id"], "complete")).status_code == 409
    early_cash = await client.post(
        f"/drivers/me/rides/{ride['id']}/cash-collected", headers=headers
    )
    assert early_cash.status_code == 409
    early_rating = await client.post(
        f"/drivers/me/rides/{ride['id']}/rating", headers=headers, json={"stars": 5}
    )
    assert early_rating.status_code == 409
    assert (await act(client, headers, ride["id"], "depart")).status_code == 200
    assert (await act(client, headers, ride["id"], "depart")).status_code == 409


async def test_other_drivers_cannot_touch_the_ride(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride, _ = await accepted_ride(client, passenger_headers, make_token)
    await make_driver("intruder")
    other = driver_headers(make_token, "intruder")
    base = f"/drivers/me/rides/{ride['id']}"
    assert (await act(client, other, ride["id"], "depart")).status_code == 404
    assert (await client.post(f"{base}/cash-collected", headers=other)).status_code == 404
    assert (await client.post(f"{base}/cancel", headers=other, json={})).status_code == 404
    rating = await client.post(f"{base}/rating", headers=other, json={"stars": 1})
    assert rating.status_code == 404


async def test_suspended_driver_cannot_continue(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    admin_headers: dict[str, str],
    make_token: TokenFactory,
) -> None:
    ride, headers = await accepted_ride(client, passenger_headers, make_token)
    await client.post("/admin/drivers/d1/suspend", headers=admin_headers, json={"reason": "Skarga"})
    assert (await act(client, headers, ride["id"], "depart")).status_code == 403


async def test_driver_cancels_ride_now(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride, headers = await accepted_ride(client, passenger_headers, make_token)
    await act(client, headers, ride["id"], "depart")
    response = await client.post(
        f"/drivers/me/rides/{ride['id']}/cancel", headers=headers, json={"reason": "Awaria auta"}
    )
    assert response.status_code == 200
    assert response.json()["status"] == "cancelled_by_driver"
    assert response.json()["cancel_reason"] == "Awaria auta"
    seen = (await client.get(f"/rides/{ride['id']}", headers=passenger_headers)).json()
    assert seen["status"] == "cancelled_by_driver"


async def _claimed_reservation(
    client: AsyncClient, passenger_headers: dict[str, str], hours_ahead: float
) -> str:
    await make_driver("d1")
    when = (datetime.now(UTC) + timedelta(hours=max(hours_ahead, 1))).isoformat()
    quote = await client.post(
        "/quotes",
        headers=passenger_headers,
        json={
            "pickup": {"location": {"lat": 49.99, "lng": 20.06}, "address": "A"},
            "destination": {"location": {"lat": 50.06, "lng": 19.94}, "address": "B"},
            "scheduled_at": when,
        },
    )
    ride = await client.post(
        "/rides",
        headers=passenger_headers,
        json={"quote_id": quote.json()["id"], "payment_method": "cash"},
    )
    ride_id: str = ride.json()["ride"]["id"]
    async with get_sessionmaker()() as session:
        await session.execute(
            update(Ride)
            .where(Ride.id == ride_id)
            .values(
                status="accepted",
                driver_id="d1",
                accepted_at=datetime.now(UTC),
                scheduled_at=datetime.now(UTC) + timedelta(hours=hours_ahead),
            )
        )
        await session.commit()
    return ride_id


async def test_reservation_given_back_early_returns_to_the_board(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride_id = await _claimed_reservation(client, passenger_headers, hours_ahead=3)
    headers = driver_headers(make_token, "d1")
    assert (await current(client, headers))["next_scheduled_ride"]["id"] == ride_id
    response = await client.post(f"/drivers/me/rides/{ride_id}/cancel", headers=headers, json={})
    assert response.status_code == 200
    assert response.json()["status"] == "scheduled"
    seen = (await client.get(f"/rides/{ride_id}", headers=passenger_headers)).json()
    assert seen["status"] == "scheduled"
    assert seen["driver"] is None and seen["accepted_at"] is None


async def test_reservation_given_back_late_is_cancelled(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride_id = await _claimed_reservation(client, passenger_headers, hours_ahead=0.25)
    headers = driver_headers(make_token, "d1")
    response = await client.post(f"/drivers/me/rides/{ride_id}/cancel", headers=headers, json={})
    assert response.json()["status"] == "cancelled_by_driver"


async def test_ratings_both_ways(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride, headers = await accepted_ride(client, passenger_headers, make_token)
    await drive_to_completion(client, headers, ride["id"])
    url = f"/drivers/me/rides/{ride['id']}/rating"
    assert (await client.post(url, headers=headers, json={"stars": 4})).status_code == 204
    assert (await client.post(url, headers=headers, json={"stars": 4})).status_code == 409
    await client.post(f"/rides/{ride['id']}/rating", headers=passenger_headers, json={"stars": 5})

    driver_view = (await client.get("/drivers/me/rides?active=false", headers=headers)).json()[
        "items"
    ][0]
    assert driver_view["passenger"]["rating_avg"] == 4.0
    assert driver_view["driver"]["rating_avg"] == 5.0
    assert (await client.get("/drivers/me", headers=headers)).json()["rating_avg"] == 5.0


async def test_driver_ride_list_filters(
    client: AsyncClient, passenger_headers: dict[str, str], make_token: TokenFactory
) -> None:
    ride, headers = await accepted_ride(client, passenger_headers, make_token)
    active = (await client.get("/drivers/me/rides?active=true", headers=headers)).json()
    assert [r["id"] for r in active["items"]] == [ride["id"]]
    finished = (await client.get("/drivers/me/rides?active=false", headers=headers)).json()
    assert finished["total"] == 0


async def test_earnings_validation_and_empty_range(
    client: AsyncClient, make_token: TokenFactory
) -> None:
    await make_driver("d1")
    headers = driver_headers(make_token, "d1")
    url = "/drivers/me/earnings"
    assert (
        await client.get(f"{url}?date_from=2026-11-10&date_to=2026-11-01", headers=headers)
    ).status_code == 422
    assert (
        await client.get(f"{url}?date_from=2025-01-01&date_to=2026-11-01", headers=headers)
    ).status_code == 422
    empty = (
        await client.get(f"{url}?date_from=2026-01-01&date_to=2026-01-31", headers=headers)
    ).json()
    assert empty["rides_count"] == 0 and empty["gross"] == 0 and empty["items"] == []

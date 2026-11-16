from datetime import UTC, datetime, timedelta
from typing import Any

import pytest
from httpx import AsyncClient
from sqlalchemy import update

from app.core.db import get_sessionmaker
from app.modules.rides.models import Ride
from tests.conftest import NIEPOLOMICE, TokenFactory, auth
from tests.dispatch_helpers import current, driver_headers, make_driver, order_now, region_id

pytestmark = pytest.mark.usefixtures("seeded")


async def listed(client: AsyncClient, headers: dict[str, str], **params: Any) -> Any:
    response = await client.get("/admin/rides", headers=headers, params=params)
    assert response.status_code == 200, response.text
    return response.json()


async def test_admin_filters_rides(
    client: AsyncClient,
    passenger_headers: dict[str, str],
    admin_headers: dict[str, str],
    make_token: TokenFactory,
) -> None:
    await make_driver("d1")
    accepted = await order_now(client, passenger_headers)
    offer = (await current(client, driver_headers(make_token, "d1")))["pending_offer"]
    await client.post(
        f"/drivers/me/offers/{offer['id']}/accept", headers=driver_headers(make_token, "d1")
    )
    other = auth(make_token(sub="passenger-2"))
    east = await order_now(client, other, pickup=NIEPOLOMICE)  # no drivers there -> no_driver
    async with get_sessionmaker()() as session:
        await session.execute(
            update(Ride)
            .where(Ride.id == east["id"])
            .values(requested_at=datetime.now(UTC) - timedelta(days=3))
        )
        await session.commit()

    everything = await listed(client, admin_headers)
    assert everything["total"] == 2
    assert [r["id"] for r in everything["items"]] == [accepted["id"], east["id"]]  # newest first
    first = everything["items"][0]
    assert first["passenger"]["id"] == "passenger-1" and first["driver"]["id"] == "d1"

    wieliczka = await listed(client, admin_headers, region_id=str(await region_id()))
    assert [r["id"] for r in wieliczka["items"]] == [accepted["id"]]
    no_driver = await listed(client, admin_headers, status="no_driver")
    assert [r["id"] for r in no_driver["items"]] == [east["id"]]

    yesterday = (datetime.now(UTC) - timedelta(days=1)).isoformat()
    recent = await listed(client, admin_headers, date_from=yesterday)
    assert [r["id"] for r in recent["items"]] == [accepted["id"]]
    older = await listed(client, admin_headers, date_to=yesterday)
    assert [r["id"] for r in older["items"]] == [east["id"]]

    page = await listed(client, admin_headers, limit=1, offset=1)
    assert page["total"] == 2 and [r["id"] for r in page["items"]] == [east["id"]]


async def test_admin_rides_validation_and_permissions(
    client: AsyncClient, admin_headers: dict[str, str], passenger_headers: dict[str, str]
) -> None:
    naive = await client.get(
        "/admin/rides", headers=admin_headers, params={"date_from": "2026-11-01T00:00:00"}
    )
    assert naive.status_code == 422
    backwards = await client.get(
        "/admin/rides",
        headers=admin_headers,
        params={"date_from": "2026-11-10T00:00:00Z", "date_to": "2026-11-01T00:00:00Z"},
    )
    assert backwards.status_code == 422
    bad_status = await client.get("/admin/rides", headers=admin_headers, params={"status": "x"})
    assert bad_status.status_code == 422
    assert (await client.get("/admin/rides", headers=passenger_headers)).status_code == 403

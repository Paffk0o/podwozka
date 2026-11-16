"""Shared setup for dispatch / driver-work tests: approved drivers placed on the map."""

from datetime import UTC, datetime
from typing import Any

from httpx import AsyncClient
from sqlalchemy import select

from app.common.schemas import GeoPoint
from app.core.db import get_sessionmaker
from app.modules.dispatch import presence
from app.modules.drivers.models import DriverProfile, Vehicle
from app.modules.regions.models import Region
from app.modules.users.models import User
from tests.conftest import KRAKOW, WIELICZKA, TokenFactory, auth

PICKUP = GeoPoint(lat=WIELICZKA["location"]["lat"], lng=WIELICZKA["location"]["lng"])


async def region_id(name: str = "Gmina Wieliczka") -> Any:
    async with get_sessionmaker()() as session:
        return (await session.execute(select(Region.id).where(Region.name == name))).scalar_one()


async def make_driver(
    user_id: str,
    km_from_pickup: float | None = 1.0,
    status: str = "approved",
    online: bool = True,
    region: str = "Gmina Wieliczka",
) -> None:
    """An approved, online driver `km_from_pickup` north of the Wieliczka pickup point."""
    rid = await region_id(region)
    async with get_sessionmaker()() as session:
        session.add(User(id=user_id, full_name=f"Kierowca {user_id}", phone="+48600100200"))
        await session.flush()
        session.add(
            DriverProfile(
                user_id=user_id,
                region_id=rid,
                status=status,
                online=online,
                approved_at=datetime.now(UTC),
            )
        )
        await session.flush()
        session.add(
            Vehicle(
                driver_id=user_id, make="Skoda", model="Fabia", color="biały", plate="KWI1", seats=4
            )
        )
        await session.commit()
    if km_from_pickup is not None:
        point = GeoPoint(lat=PICKUP.lat + km_from_pickup / 111.32, lng=PICKUP.lng)
        await presence.update_location(rid, user_id, point)


def driver_headers(make_token: TokenFactory, user_id: str) -> dict[str, str]:
    return auth(make_token(sub=user_id, roles=("passenger", "driver"), client="driver-app"))


async def order_now(client: AsyncClient, headers: dict[str, str], **body: Any) -> Any:
    body.setdefault("pickup", WIELICZKA)
    body.setdefault("destination", KRAKOW)
    quote = await client.post("/quotes", headers=headers, json=body)
    assert quote.status_code == 201, quote.text
    response = await client.post(
        "/rides", headers=headers, json={"quote_id": quote.json()["id"], "payment_method": "cash"}
    )
    assert response.status_code == 201, response.text
    return response.json()["ride"]


async def current(client: AsyncClient, headers: dict[str, str]) -> Any:
    response = await client.get("/drivers/me/current", headers=headers)
    assert response.status_code == 200, response.text
    return response.json()

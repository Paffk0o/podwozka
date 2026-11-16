import json
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from typing import Any
from zoneinfo import ZoneInfo

import httpx
import pytest
from httpx import AsyncClient

from app.common.schemas import GeoPoint
from app.core.config import get_settings
from app.modules.pricing import routing
from app.modules.pricing.calculator import calculate_price, commission, is_night
from app.modules.pricing.routing import (
    GoogleRoutesProvider,
    Route,
    StraightLineRouting,
    get_routing_provider,
)
from tests.conftest import KRAKOW, NIEPOLOMICE, WIELICZKA, TokenFactory, auth, place

WARSAW = ZoneInfo("Europe/Warsaw")


@dataclass
class Rates:
    base_fare: int = 800
    per_km: int = 300
    per_minute: int = 50
    minimum_fare: int = 1500
    night_multiplier_percent: int = 120
    night_start_hour: int = 22
    night_end_hour: int = 6


NOON = datetime(2026, 11, 16, 12, 0, tzinfo=WARSAW)


# --- calculator ---


def test_day_price_is_base_plus_distance_plus_time() -> None:
    # 800 + 300 * 10 km + 50 * 15 min
    assert calculate_price(Rates(), 10_000, 900, NOON) == 4550


def test_night_multiplier_applies_inside_window_wrapping_midnight() -> None:
    for hour in (22, 23, 0, 5):
        at = NOON.replace(hour=hour)
        assert calculate_price(Rates(), 10_000, 900, at) == 5460, hour
    assert calculate_price(Rates(), 10_000, 900, NOON.replace(hour=6)) == 4550


def test_minimum_fare_wins_for_short_rides() -> None:
    assert calculate_price(Rates(), 1000, 120, NOON) == 1500


def test_rounding_is_integer_half_up() -> None:
    # 300 gr/km * 0.555 km = 166.5 → 167; 50 gr/min * 0.5 min = 25
    rates = Rates(base_fare=0, minimum_fare=0)
    assert calculate_price(rates, 555, 30, NOON) == 167 + 25


def test_is_night_edge_cases() -> None:
    assert not is_night(3, 5, 5)  # empty window
    assert is_night(1, 0, 6) and not is_night(6, 0, 6)  # window not crossing midnight
    assert commission(4550, 10) == 455
    assert commission(4555, 10) == 456


# --- routing providers ---


async def test_straight_line_routing_uses_factor_and_40_kmh() -> None:
    a = GeoPoint(lat=50.0, lng=20.0)
    b = GeoPoint(lat=50.0, lng=20.1)  # ~7.15 km in a straight line
    route = await StraightLineRouting().route(a, b)
    assert 9200 < route.distance_m < 9400
    assert route.duration_s == round(route.distance_m / (40 / 3.6))
    assert route.polyline is None


async def test_google_routes_request_and_response() -> None:
    seen: dict[str, Any] = {}

    def handler(request: httpx.Request) -> httpx.Response:
        seen["headers"] = request.headers
        seen["body"] = json.loads(request.content)
        return httpx.Response(
            200,
            json={
                "routes": [
                    {
                        "distanceMeters": 12345,
                        "duration": "678s",
                        "polyline": {"encodedPolyline": "abc"},
                    }
                ]
            },
        )

    provider = GoogleRoutesProvider("test-key", transport=httpx.MockTransport(handler))
    departure = datetime.now(UTC) + timedelta(hours=2)
    route = await provider.route(
        GeoPoint(lat=50.0, lng=20.0), GeoPoint(lat=50.1, lng=20.1), departure
    )
    assert route == Route(distance_m=12345, duration_s=678, polyline="abc")
    assert seen["headers"]["X-Goog-Api-Key"] == "test-key"
    assert "routes.distanceMeters" in seen["headers"]["X-Goog-FieldMask"]
    assert seen["body"]["origin"]["location"]["latLng"] == {"latitude": 50.0, "longitude": 20.0}
    assert seen["body"]["departureTime"].endswith("Z")


async def test_google_routes_falls_back_on_error() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(403, json={"error": "API key not valid"})

    provider = GoogleRoutesProvider("bad", transport=httpx.MockTransport(handler))
    a, b = GeoPoint(lat=50.0, lng=20.0), GeoPoint(lat=50.0, lng=20.1)
    assert await provider.route(a, b) == await StraightLineRouting().route(a, b)


def test_provider_selection_depends_on_server_key(monkeypatch: pytest.MonkeyPatch) -> None:
    get_routing_provider.cache_clear()
    assert isinstance(get_routing_provider(), StraightLineRouting)
    get_routing_provider.cache_clear()
    monkeypatch.setattr(get_settings(), "google_maps_server_key", "k")
    assert isinstance(routing.get_routing_provider(), GoogleRoutesProvider)
    get_routing_provider.cache_clear()


# --- POST /quotes ---


def at_local(days: int, hour: int) -> str:
    local = (datetime.now(WARSAW) + timedelta(days=days)).replace(
        hour=hour, minute=0, second=0, microsecond=0
    )
    return local.isoformat()


async def test_quote_uses_tariff_of_pickup_region(
    client: AsyncClient, seeded: None, passenger_headers: dict[str, str]
) -> None:
    body = {"pickup": WIELICZKA, "destination": KRAKOW, "scheduled_at": at_local(1, 12)}
    response = await client.post("/quotes", headers=passenger_headers, json=body)
    assert response.status_code == 201, response.text
    quote = response.json()
    assert quote["region_name"] == "Gmina Wieliczka"
    assert quote["price"] == 4550
    assert quote["currency"] == "PLN"
    assert quote["distance_m"] == 10_000 and quote["duration_s"] == 900
    assert quote["pickup"]["address"] == "Rynek Górny, Wieliczka"

    body["pickup"] = NIEPOLOMICE
    other = (await client.post("/quotes", headers=passenger_headers, json=body)).json()
    assert other["region_name"] == "Gmina Niepołomice"
    assert other["price"] == 600 + 3500 + 600
    assert other["tariff_id"] != quote["tariff_id"]


async def test_quote_now_is_valid_for_five_minutes(
    client: AsyncClient, seeded: None, passenger_headers: dict[str, str]
) -> None:
    before = datetime.now(UTC)
    response = await client.post(
        "/quotes", headers=passenger_headers, json={"pickup": WIELICZKA, "destination": KRAKOW}
    )
    assert response.status_code == 201
    expires_at = datetime.fromisoformat(response.json()["expires_at"])
    assert timedelta(minutes=4, seconds=50) < expires_at - before <= timedelta(minutes=5, seconds=5)
    assert response.json()["scheduled_at"] is None


async def test_night_reservation_costs_more(
    client: AsyncClient, seeded: None, passenger_headers: dict[str, str]
) -> None:
    body = {"pickup": WIELICZKA, "destination": KRAKOW, "scheduled_at": at_local(2, 23)}
    response = await client.post("/quotes", headers=passenger_headers, json=body)
    assert response.json()["price"] == 5460


async def test_quote_rejections(
    client: AsyncClient, seeded: None, passenger_headers: dict[str, str]
) -> None:
    soon = (datetime.now(UTC) + timedelta(minutes=10)).isoformat()
    far = (datetime.now(UTC) + timedelta(days=15)).isoformat()
    cases = [
        {"pickup": KRAKOW, "destination": WIELICZKA},  # pickup outside regions
        {"pickup": WIELICZKA, "destination": KRAKOW, "scheduled_at": soon},
        {"pickup": WIELICZKA, "destination": KRAKOW, "scheduled_at": far},
        {"pickup": WIELICZKA, "destination": KRAKOW, "scheduled_at": "2030-01-01T10:00:00"},
        {"pickup": WIELICZKA, "destination": place(49.9901, 20.0601)},  # ~13 m away
    ]
    for body in cases:
        response = await client.post("/quotes", headers=passenger_headers, json=body)
        assert response.status_code == 422, body


async def test_region_without_tariff_cannot_be_quoted(
    client: AsyncClient, admin_headers: dict[str, str], passenger_headers: dict[str, str]
) -> None:
    from tests.test_regions import create, square

    await create(client, admin_headers, name="Gmina Bez Cennika", area=square(18.0, 50.0))
    response = await client.post(
        "/quotes",
        headers=passenger_headers,
        json={"pickup": place(50.05, 18.05), "destination": place(50.08, 18.08)},
    )
    assert response.status_code == 422
    assert "cennika" in response.json()["detail"]


async def test_only_passengers_can_quote(
    client: AsyncClient, seeded: None, make_token: TokenFactory
) -> None:
    token = make_token(roles=("driver",), client="driver-app")
    response = await client.post(
        "/quotes", headers=auth(token), json={"pickup": WIELICZKA, "destination": KRAKOW}
    )
    assert response.status_code == 403

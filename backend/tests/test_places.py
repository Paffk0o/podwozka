import json
from collections.abc import Callable, Iterator
from typing import Any

import httpx
import pytest
from httpx import AsyncClient

from app.common.schemas import GeoPoint, Place
from app.core.config import get_settings
from app.main import app
from app.modules.places.providers import (
    GooglePlacesProvider,
    NominatimProvider,
    PlacesUnavailableError,
    RateLimiter,
    TTLCache,
    get_places_provider,
)
from app.modules.places.schemas import PlaceSuggestion

Handler = Callable[[httpx.Request], httpx.Response]
TOKEN = "session-token-123"


class NoWait(RateLimiter):
    def __init__(self) -> None:
        super().__init__(0)


def nominatim(handler: Handler) -> NominatimProvider:
    return NominatimProvider(
        "https://nominatim.test", "Podwozka-test/1.0", NoWait(), httpx.MockTransport(handler)
    )


# --- Google ---


async def test_google_autocomplete_maps_predictions() -> None:
    seen: dict[str, Any] = {}

    def handler(request: httpx.Request) -> httpx.Response:
        seen["url"] = str(request.url)
        seen["body"] = json.loads(request.content)
        seen["key"] = request.headers["X-Goog-Api-Key"]
        return httpx.Response(
            200,
            json={
                "suggestions": [
                    {
                        "placePrediction": {
                            "placeId": "ChIJ1",
                            "text": {"text": "Rynek Górny 1, Wieliczka"},
                            "structuredFormat": {
                                "mainText": {"text": "Rynek Górny 1"},
                                "secondaryText": {"text": "Wieliczka"},
                            },
                        }
                    },
                    {"queryPrediction": {"text": {"text": "rynek"}}},
                ]
            },
        )

    provider = GooglePlacesProvider("k", httpx.MockTransport(handler))
    result = await provider.autocomplete("Rynek", TOKEN, GeoPoint(lat=50.0, lng=20.0))
    assert result == [
        PlaceSuggestion(place_id="ChIJ1", primary_text="Rynek Górny 1", secondary_text="Wieliczka")
    ]
    assert seen["url"].endswith("/places:autocomplete")
    assert seen["key"] == "k"
    assert seen["body"]["sessionToken"] == TOKEN
    assert seen["body"]["includedRegionCodes"] == ["pl"]
    assert seen["body"]["locationBias"]["circle"]["center"] == {"latitude": 50.0, "longitude": 20.0}


async def test_google_details_and_reverse() -> None:
    def handler(request: httpx.Request) -> httpx.Response:
        if "/places/ChIJ1" in request.url.path:
            assert request.headers["X-Goog-FieldMask"] == "id,formattedAddress,location"
            assert request.url.params["sessionToken"] == TOKEN
            return httpx.Response(
                200,
                json={
                    "id": "ChIJ1",
                    "formattedAddress": "Rynek Górny 1, 32-020 Wieliczka",
                    "location": {"latitude": 49.98, "longitude": 20.06},
                },
            )
        if "/places/" in request.url.path:
            return httpx.Response(404, json={})
        assert request.url.params["latlng"] == "49.9,20.1"
        return httpx.Response(
            200,
            json={
                "status": "OK",
                "results": [{"formatted_address": "Dobczycka 5, Wieliczka", "place_id": "ChIJ2"}],
            },
        )

    provider = GooglePlacesProvider("k", httpx.MockTransport(handler))
    place = await provider.details("ChIJ1", TOKEN)
    assert place == Place(
        location=GeoPoint(lat=49.98, lng=20.06),
        address="Rynek Górny 1, 32-020 Wieliczka",
        place_id="ChIJ1",
    )
    assert await provider.details("missing", TOKEN) is None
    reverse = await provider.reverse(GeoPoint(lat=49.9, lng=20.1))
    assert reverse is not None
    assert reverse.address == "Dobczycka 5, Wieliczka"
    assert reverse.location == GeoPoint(lat=49.9, lng=20.1)  # the point the user picked


async def test_google_errors_raise_unavailable() -> None:
    provider = GooglePlacesProvider("k", httpx.MockTransport(lambda r: httpx.Response(500)))
    with pytest.raises(PlacesUnavailableError):
        await provider.autocomplete("abc", TOKEN, None)
    with pytest.raises(PlacesUnavailableError):
        await provider.details("x", TOKEN)
    with pytest.raises(PlacesUnavailableError):
        await provider.reverse(GeoPoint(lat=1, lng=1))

    denied = GooglePlacesProvider(
        "k", httpx.MockTransport(lambda r: httpx.Response(200, json={"status": "REQUEST_DENIED"}))
    )
    with pytest.raises(PlacesUnavailableError):
        await denied.reverse(GeoPoint(lat=1, lng=1))
    empty = GooglePlacesProvider(
        "k", httpx.MockTransport(lambda r: httpx.Response(200, json={"status": "ZERO_RESULTS"}))
    )
    assert await empty.reverse(GeoPoint(lat=1, lng=1)) is None

    def boom(request: httpx.Request) -> httpx.Response:
        raise httpx.ConnectError("down")

    with pytest.raises(PlacesUnavailableError):
        await GooglePlacesProvider("k", httpx.MockTransport(boom)).details("x", TOKEN)


# --- Nominatim ---

SEARCH_ITEM = {
    "osm_type": "node",
    "osm_id": 123,
    "name": "Kopalnia Soli",
    "display_name": "Kopalnia Soli, Daniłowicza, Wieliczka, Polska",
    "lat": "49.9838",
    "lon": "20.0546",
}


async def test_nominatim_search_lookup_reverse_and_user_agent() -> None:
    calls: list[httpx.Request] = []

    def handler(request: httpx.Request) -> httpx.Response:
        calls.append(request)
        assert request.headers["User-Agent"] == "Podwozka-test/1.0"
        assert request.url.params["format"] == "jsonv2"
        match request.url.path:
            case "/search":
                assert request.url.params["countrycodes"] == "pl"
                return httpx.Response(200, json=[SEARCH_ITEM, {"display_name": "no id"}])
            case "/lookup":
                assert request.url.params["osm_ids"] == "N123"
                return httpx.Response(200, json=[SEARCH_ITEM])
            case _:
                if request.url.params["lat"].startswith("0"):
                    return httpx.Response(200, json={"error": "Unable to geocode"})
                return httpx.Response(200, json=SEARCH_ITEM)

    provider = nominatim(handler)
    suggestions = await provider.autocomplete("kopalnia", TOKEN, GeoPoint(lat=50.0, lng=20.0))
    assert suggestions == [
        PlaceSuggestion(
            place_id="osm:N123",
            primary_text="Kopalnia Soli",
            secondary_text="Daniłowicza, Wieliczka, Polska",
        )
    ]
    assert "viewbox" in calls[0].url.params

    place = await provider.details("osm:N123", TOKEN)
    assert place is not None and place.location == GeoPoint(lat=49.9838, lng=20.0546)
    assert await provider.details("ChIJ-google-id", TOKEN) is None  # not ours

    reverse = await provider.reverse(GeoPoint(lat=49.98, lng=20.05))
    assert reverse is not None and reverse.address.startswith("Kopalnia Soli")
    assert await provider.reverse(GeoPoint(lat=0.5, lng=0.5)) is None

    # Cached: repeating a query does not hit Nominatim again.
    before = len(calls)
    await provider.autocomplete("kopalnia", TOKEN, GeoPoint(lat=50.0, lng=20.0))
    assert len(calls) == before


async def test_nominatim_errors_raise_unavailable() -> None:
    provider = nominatim(lambda r: httpx.Response(429))
    with pytest.raises(PlacesUnavailableError):
        await provider.autocomplete("abc", TOKEN, None)

    def boom(request: httpx.Request) -> httpx.Response:
        raise httpx.ReadTimeout("slow")

    with pytest.raises(PlacesUnavailableError):
        await nominatim(boom).reverse(GeoPoint(lat=1, lng=1))


async def test_rate_limiter_spaces_calls_by_interval() -> None:
    now = [100.0]
    sleeps: list[float] = []

    async def fake_sleep(seconds: float) -> None:
        sleeps.append(seconds)
        now[0] += seconds

    limiter = RateLimiter(1.0, clock=lambda: now[0], sleep=fake_sleep)
    await limiter.wait()  # first call: no wait
    now[0] += 0.25
    await limiter.wait()  # 0.25 s later: wait the remaining 0.75 s
    now[0] += 5
    await limiter.wait()  # long after: no wait
    assert sleeps == [pytest.approx(0.75)]


def test_ttl_cache_expires_and_evicts() -> None:
    cache = TTLCache(ttl_s=-1)
    cache.set("a", 1)
    assert cache.get("a") is None  # already expired
    small = TTLCache(ttl_s=60, max_items=2)
    for key in "abc":
        small.set(key, key)
    assert small.get("a") is None and small.get("c") == "c"


def test_provider_selection(monkeypatch: pytest.MonkeyPatch) -> None:
    get_places_provider.cache_clear()
    assert isinstance(get_places_provider(), NominatimProvider)
    get_places_provider.cache_clear()
    monkeypatch.setattr(get_settings(), "google_maps_server_key", "k")
    assert isinstance(get_places_provider(), GooglePlacesProvider)
    get_places_provider.cache_clear()


# --- HTTP endpoints ---


class FakePlaces:
    def __init__(self, fail: bool = False) -> None:
        self.fail = fail

    def _check(self) -> None:
        if self.fail:
            raise PlacesUnavailableError("down")

    async def autocomplete(
        self, text: str, session_token: str, near: GeoPoint | None
    ) -> list[PlaceSuggestion]:
        self._check()
        hint = f"{near.lat},{near.lng}" if near else None
        return [PlaceSuggestion(place_id="p1", primary_text=text, secondary_text=hint)]

    async def details(self, place_id: str, session_token: str) -> Place | None:
        self._check()
        if place_id != "p1":
            return None
        return Place(location=GeoPoint(lat=50, lng=20), address="Adres 1", place_id="p1")

    async def reverse(self, point: GeoPoint) -> Place | None:
        self._check()
        if point.lat == 0:
            return None
        return Place(location=point, address="Adres 2")


@pytest.fixture
def fake_places() -> Iterator[FakePlaces]:
    fake = FakePlaces()
    app.dependency_overrides[get_places_provider] = lambda: fake
    yield fake
    app.dependency_overrides.pop(get_places_provider, None)


async def test_places_endpoints(
    client: AsyncClient, fake_places: FakePlaces, passenger_headers: dict[str, str]
) -> None:
    response = await client.get(
        "/places/autocomplete",
        headers=passenger_headers,
        params={"input": "Rynek", "session_token": TOKEN, "lat": 50.1, "lng": 20.2},
    )
    assert response.json() == [
        {"place_id": "p1", "primary_text": "Rynek", "secondary_text": "50.1,20.2"}
    ]
    details = await client.get(
        "/places/p1", headers=passenger_headers, params={"session_token": TOKEN}
    )
    assert details.json()["address"] == "Adres 1"
    missing = await client.get(
        "/places/zzz", headers=passenger_headers, params={"session_token": TOKEN}
    )
    assert missing.status_code == 404
    reverse = await client.get(
        "/places/reverse", headers=passenger_headers, params={"lat": 49.9, "lng": 20.1}
    )
    assert reverse.json()["location"] == {"lat": 49.9, "lng": 20.1}
    nothing = await client.get(
        "/places/reverse", headers=passenger_headers, params={"lat": 0, "lng": 0}
    )
    assert nothing.status_code == 404


async def test_places_upstream_failure_is_503(
    client: AsyncClient, fake_places: FakePlaces, passenger_headers: dict[str, str]
) -> None:
    fake_places.fail = True
    for path, params in (
        ("/places/autocomplete", {"input": "abc", "session_token": TOKEN}),
        ("/places/p1", {"session_token": TOKEN}),
        ("/places/reverse", {"lat": 1, "lng": 1}),
    ):
        response = await client.get(path, headers=passenger_headers, params=params)
        assert response.status_code == 503, path


async def test_places_require_login(client: AsyncClient, fake_places: FakePlaces) -> None:
    response = await client.get("/places/reverse", params={"lat": 1, "lng": 1})
    assert response.status_code == 401

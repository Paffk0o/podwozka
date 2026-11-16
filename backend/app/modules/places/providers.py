"""Address search behind an interface.

- `GooglePlacesProvider` — Places API (New) for autocomplete/details + Geocoding API for reverse,
  used when GOOGLE_MAPS_SERVER_KEY is set. Session tokens group autocomplete + details into one
  billed session.
- `NominatimProvider` — OpenStreetMap fallback without a key. Its usage policy requires an
  identifying User-Agent and at most 1 request/s, and asks clients to cache results — all done
  here (the apps also debounce typing).
"""

import asyncio
import logging
import time
from collections import OrderedDict
from collections.abc import Awaitable, Callable
from functools import lru_cache
from typing import Any, Protocol

import httpx

from app.common.schemas import GeoPoint, Place
from app.core.config import get_settings
from app.modules.places.schemas import PlaceSuggestion

log = logging.getLogger(__name__)


class PlacesUnavailableError(Exception):
    """The upstream geocoding service failed."""


class PlacesProvider(Protocol):
    async def autocomplete(
        self, text: str, session_token: str, near: GeoPoint | None
    ) -> list[PlaceSuggestion]: ...

    async def details(self, place_id: str, session_token: str) -> Place | None: ...

    async def reverse(self, point: GeoPoint) -> Place | None: ...


def _split_address(full: str) -> tuple[str, str | None]:
    head, _, tail = full.partition(", ")
    return head, tail or None


# --- Google ---


class GooglePlacesProvider:
    PLACES_URL = "https://places.googleapis.com/v1"
    GEOCODE_URL = "https://maps.googleapis.com/maps/api/geocode/json"
    BIAS_RADIUS_M = 30_000.0

    def __init__(self, api_key: str, transport: httpx.AsyncBaseTransport | None = None) -> None:
        self._key = api_key
        self._transport = transport

    async def _request(self, method: str, url: str, **kwargs: Any) -> httpx.Response:
        try:
            async with httpx.AsyncClient(timeout=5, transport=self._transport) as client:
                return await client.request(method, url, **kwargs)
        except httpx.HTTPError as exc:
            raise PlacesUnavailableError(str(exc)) from exc

    async def autocomplete(
        self, text: str, session_token: str, near: GeoPoint | None
    ) -> list[PlaceSuggestion]:
        body: dict[str, Any] = {
            "input": text,
            "sessionToken": session_token,
            "languageCode": "pl",
            "includedRegionCodes": ["pl"],
        }
        if near is not None:
            body["locationBias"] = {
                "circle": {
                    "center": {"latitude": near.lat, "longitude": near.lng},
                    "radius": self.BIAS_RADIUS_M,
                }
            }
        response = await self._request(
            "POST",
            f"{self.PLACES_URL}/places:autocomplete",
            json=body,
            headers={"X-Goog-Api-Key": self._key},
        )
        if response.status_code != 200:
            raise PlacesUnavailableError(f"autocomplete HTTP {response.status_code}")
        suggestions = []
        for item in response.json().get("suggestions", []):
            prediction = item.get("placePrediction")
            if not prediction:
                continue  # query predictions are not places
            structured = prediction.get("structuredFormat", {})
            main = structured.get("mainText", {}).get("text") or prediction["text"]["text"]
            secondary = structured.get("secondaryText", {}).get("text")
            suggestions.append(
                PlaceSuggestion(
                    place_id=prediction["placeId"], primary_text=main, secondary_text=secondary
                )
            )
        return suggestions

    async def details(self, place_id: str, session_token: str) -> Place | None:
        response = await self._request(
            "GET",
            f"{self.PLACES_URL}/places/{place_id}",
            params={"sessionToken": session_token, "languageCode": "pl"},
            headers={
                "X-Goog-Api-Key": self._key,
                "X-Goog-FieldMask": "id,formattedAddress,location",
            },
        )
        if response.status_code in (400, 404):
            return None
        if response.status_code != 200:
            raise PlacesUnavailableError(f"details HTTP {response.status_code}")
        data = response.json()
        return Place(
            location=GeoPoint(lat=data["location"]["latitude"], lng=data["location"]["longitude"]),
            address=data["formattedAddress"][:300],
            place_id=data.get("id", place_id),
        )

    async def reverse(self, point: GeoPoint) -> Place | None:
        response = await self._request(
            "GET",
            self.GEOCODE_URL,
            params={"latlng": f"{point.lat},{point.lng}", "language": "pl", "key": self._key},
        )
        if response.status_code != 200:
            raise PlacesUnavailableError(f"geocode HTTP {response.status_code}")
        data = response.json()
        if data.get("status") == "ZERO_RESULTS":
            return None
        if data.get("status") != "OK":
            raise PlacesUnavailableError(f"geocode status {data.get('status')}")
        best = data["results"][0]
        # Keep the point the user picked; only the address comes from the geocoder.
        return Place(
            location=point, address=best["formatted_address"][:300], place_id=best.get("place_id")
        )


# --- Nominatim (OpenStreetMap) ---


class RateLimiter:
    """At most one call per `interval` seconds (per API process)."""

    def __init__(
        self,
        interval: float,
        clock: Callable[[], float] = time.monotonic,
        sleep: Callable[[float], Awaitable[None]] = asyncio.sleep,
    ) -> None:
        self._interval = interval
        self._clock = clock
        self._sleep = sleep
        self._lock = asyncio.Lock()
        self._last = float("-inf")

    async def wait(self) -> None:
        async with self._lock:
            delay = self._last + self._interval - self._clock()
            if delay > 0:
                await self._sleep(delay)
            self._last = self._clock()


class TTLCache:
    def __init__(self, ttl_s: float, max_items: int = 2000) -> None:
        self._ttl = ttl_s
        self._max = max_items
        self._data: OrderedDict[str, tuple[float, Any]] = OrderedDict()

    def get(self, key: str) -> Any | None:
        item = self._data.get(key)
        if item is None:
            return None
        expires, value = item
        if expires < time.monotonic():
            del self._data[key]
            return None
        self._data.move_to_end(key)
        return value

    def set(self, key: str, value: Any) -> None:
        self._data[key] = (time.monotonic() + self._ttl, value)
        self._data.move_to_end(key)
        while len(self._data) > self._max:
            self._data.popitem(last=False)


class NominatimProvider:
    """IDs are `osm:<N|W|R><osm_id>` so details can be fetched with /lookup."""

    def __init__(
        self,
        base_url: str,
        user_agent: str,
        limiter: RateLimiter | None = None,
        transport: httpx.AsyncBaseTransport | None = None,
        cache_ttl_s: float = 24 * 3600,
    ) -> None:
        self._base = base_url.rstrip("/")
        self._headers = {"User-Agent": user_agent, "Accept-Language": "pl"}
        self._limiter = limiter or RateLimiter(1.0)
        self._transport = transport
        self._cache = TTLCache(cache_ttl_s)

    async def _get(self, path: str, params: dict[str, Any]) -> Any:
        key = path + "?" + "&".join(f"{k}={v}" for k, v in sorted(params.items()))
        cached = self._cache.get(key)
        if cached is not None:
            return cached
        await self._limiter.wait()
        try:
            async with httpx.AsyncClient(
                timeout=8, transport=self._transport, headers=self._headers
            ) as client:
                response = await client.get(
                    f"{self._base}{path}", params={**params, "format": "jsonv2"}
                )
        except httpx.HTTPError as exc:
            raise PlacesUnavailableError(str(exc)) from exc
        if response.status_code != 200:
            raise PlacesUnavailableError(f"nominatim HTTP {response.status_code}")
        data = response.json()
        self._cache.set(key, data)
        return data

    @staticmethod
    def _osm_id(item: dict[str, Any]) -> str | None:
        osm_type, osm_id = item.get("osm_type"), item.get("osm_id")
        if not osm_type or osm_id is None:
            return None
        return f"osm:{str(osm_type)[0].upper()}{osm_id}"

    def _to_place(self, item: dict[str, Any], location: GeoPoint | None = None) -> Place:
        return Place(
            location=location or GeoPoint(lat=float(item["lat"]), lng=float(item["lon"])),
            address=str(item["display_name"])[:300],
            place_id=self._osm_id(item),
        )

    async def autocomplete(
        self, text: str, session_token: str, near: GeoPoint | None
    ) -> list[PlaceSuggestion]:
        params: dict[str, Any] = {"q": text.strip(), "countrycodes": "pl", "limit": 5}
        if near is not None:
            # Prefer results near the user (not a hard bound).
            west, east = near.lng - 0.3, near.lng + 0.3
            north, south = near.lat + 0.2, near.lat - 0.2
            params["viewbox"] = f"{west:.4f},{north:.4f},{east:.4f},{south:.4f}"
        suggestions = []
        for item in await self._get("/search", params):
            place_id = self._osm_id(item)
            if place_id is None:
                continue
            head, tail = _split_address(str(item.get("display_name", "")))
            suggestions.append(
                PlaceSuggestion(
                    place_id=place_id, primary_text=item.get("name") or head, secondary_text=tail
                )
            )
        return suggestions

    async def details(self, place_id: str, session_token: str) -> Place | None:
        if not place_id.startswith("osm:") or len(place_id) < 6:
            return None
        items = await self._get("/lookup", {"osm_ids": place_id.removeprefix("osm:")})
        return self._to_place(items[0]) if items else None

    async def reverse(self, point: GeoPoint) -> Place | None:
        data = await self._get(
            "/reverse", {"lat": f"{point.lat:.6f}", "lon": f"{point.lng:.6f}", "zoom": 18}
        )
        if not isinstance(data, dict) or "error" in data or "display_name" not in data:
            return None
        return self._to_place(data, location=point)


@lru_cache
def get_places_provider() -> PlacesProvider:
    settings = get_settings()
    if settings.google_maps_server_key:
        return GooglePlacesProvider(settings.google_maps_server_key)
    return NominatimProvider(settings.nominatim_url, settings.nominatim_user_agent)

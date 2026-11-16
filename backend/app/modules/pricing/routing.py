"""Route distance/duration for quotes, behind an interface.

- `GoogleRoutesProvider` — Google Routes API (`computeRoutes`), used when GOOGLE_MAPS_SERVER_KEY
  is set. Errors fall back to the straight-line estimate, so a Google outage never blocks orders.
- `StraightLineRouting` — offline default: great-circle distance x 1.3 at 40 km/h.
"""

import logging
import math
from dataclasses import dataclass
from datetime import UTC, datetime
from functools import lru_cache
from typing import Any, Protocol

import httpx

from app.common.schemas import GeoPoint
from app.core.config import get_settings

log = logging.getLogger(__name__)

EARTH_RADIUS_M = 6_371_000


def haversine_m(a: GeoPoint, b: GeoPoint) -> float:
    """Great-circle distance in metres."""
    lat1, lat2 = math.radians(a.lat), math.radians(b.lat)
    dlat = lat2 - lat1
    dlng = math.radians(b.lng - a.lng)
    h = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    return 2 * EARTH_RADIUS_M * math.asin(math.sqrt(h))


@dataclass(frozen=True, slots=True)
class Route:
    distance_m: int
    duration_s: int
    polyline: str | None = None


class RoutingProvider(Protocol):
    async def route(
        self, origin: GeoPoint, destination: GeoPoint, departure: datetime | None = None
    ) -> Route: ...


class StraightLineRouting:
    """Offline estimate: road distance ≈ straight line x 1.3, average speed 40 km/h."""

    ROAD_FACTOR = 1.3
    SPEED_MPS = 40 / 3.6

    async def route(
        self, origin: GeoPoint, destination: GeoPoint, departure: datetime | None = None
    ) -> Route:
        distance = haversine_m(origin, destination) * self.ROAD_FACTOR
        return Route(distance_m=round(distance), duration_s=round(distance / self.SPEED_MPS))


class GoogleRoutesProvider:
    URL = "https://routes.googleapis.com/directions/v2:computeRoutes"
    FIELD_MASK = "routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline"

    def __init__(
        self,
        api_key: str,
        fallback: RoutingProvider | None = None,
        transport: httpx.AsyncBaseTransport | None = None,
    ) -> None:
        self._api_key = api_key
        self._fallback = fallback or StraightLineRouting()
        self._transport = transport

    @staticmethod
    def _waypoint(p: GeoPoint) -> dict[str, Any]:
        return {"location": {"latLng": {"latitude": p.lat, "longitude": p.lng}}}

    async def route(
        self, origin: GeoPoint, destination: GeoPoint, departure: datetime | None = None
    ) -> Route:
        body: dict[str, Any] = {
            "origin": self._waypoint(origin),
            "destination": self._waypoint(destination),
            "travelMode": "DRIVE",
            "routingPreference": "TRAFFIC_AWARE",
            "languageCode": "pl-PL",
            "units": "METRIC",
        }
        if departure is not None and departure > datetime.now(UTC):
            body["departureTime"] = departure.astimezone(UTC).isoformat().replace("+00:00", "Z")
        headers = {"X-Goog-Api-Key": self._api_key, "X-Goog-FieldMask": self.FIELD_MASK}
        try:
            async with httpx.AsyncClient(timeout=5, transport=self._transport) as client:
                response = await client.post(self.URL, json=body, headers=headers)
                response.raise_for_status()
                route = response.json()["routes"][0]
            return Route(
                distance_m=int(route["distanceMeters"]),
                duration_s=int(str(route["duration"]).rstrip("s")),
                polyline=route.get("polyline", {}).get("encodedPolyline"),
            )
        except (httpx.HTTPError, KeyError, IndexError, ValueError) as exc:
            log.warning("Google Routes failed (%s), using straight-line estimate", exc)
            return await self._fallback.route(origin, destination, departure)


@lru_cache
def get_routing_provider() -> RoutingProvider:
    key = get_settings().google_maps_server_key
    if key:
        return GoogleRoutesProvider(key)
    return StraightLineRouting()

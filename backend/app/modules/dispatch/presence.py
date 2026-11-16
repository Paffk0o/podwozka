"""Online drivers in Redis (volatile): one GEO set per region + a short-lived position hash.

- `drivers:online:{region_id}` — GEO set (GEOADD / GEOSEARCH), member = driver user id.
- `driver:loc:{user_id}` — last position; expires after LOCATION_TTL_S, so a driver whose app
  stopped sending positions is skipped by dispatch even if still in the GEO set.
- `driver:offer-lock:{user_id}` — held while an offer to this driver is pending, so two rides
  dispatched at the same moment cannot offer to the same driver.
"""

import uuid
from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Any

from redis.typing import EncodableT, FieldT

from app.common.schemas import GeoPoint
from app.core.redis import get_redis

LOCATION_TTL_S = 120


def online_key(region_id: uuid.UUID) -> str:
    return f"drivers:online:{region_id}"


def location_key(user_id: str) -> str:
    return f"driver:loc:{user_id}"


def offer_lock_key(user_id: str) -> str:
    return f"driver:offer-lock:{user_id}"


@dataclass(frozen=True, slots=True)
class Nearby:
    driver_id: str
    distance_m: float


async def update_location(
    region_id: uuid.UUID, user_id: str, point: GeoPoint, heading: float | None = None
) -> None:
    redis = get_redis()
    await redis.geoadd(online_key(region_id), [point.lng, point.lat, user_id])
    mapping: dict[FieldT, EncodableT] = {
        "lat": point.lat,
        "lng": point.lng,
        "at": datetime.now(UTC).isoformat(),
    }
    if heading is not None:
        mapping["heading"] = heading
    await redis.hset(location_key(user_id), mapping=mapping)
    await redis.expire(location_key(user_id), LOCATION_TTL_S)


async def last_location(user_id: str) -> GeoPoint | None:
    raw = await get_redis().hgetall(location_key(user_id))
    data = {str(k): str(v) for k, v in raw.items()}
    if not data:
        return None
    return GeoPoint(lat=float(data["lat"]), lng=float(data["lng"]))


async def go_offline(region_id: uuid.UUID, user_id: str) -> None:
    redis = get_redis()
    await redis.zrem(online_key(region_id), user_id)
    await redis.delete(location_key(user_id))


async def nearby(region_id: uuid.UUID, point: GeoPoint, radius_km: float) -> list[Nearby]:
    """Fresh online drivers nearest first; stale GEO members are removed on the way."""
    redis = get_redis()
    found: list[Any] = await redis.geosearch(
        online_key(region_id),
        longitude=point.lng,
        latitude=point.lat,
        radius=radius_km,
        unit="km",
        sort="ASC",
        count=50,
        withdist=True,
    )
    result = []
    for item in found:
        driver_id, distance = str(item[0]), float(item[1])
        if not await redis.exists(location_key(driver_id)):
            await redis.zrem(online_key(region_id), driver_id)
            continue
        result.append(Nearby(driver_id=driver_id, distance_m=distance * 1000))
    return result


async def lock_for_offer(user_id: str, ttl_s: int) -> bool:
    return bool(await get_redis().set(offer_lock_key(user_id), "1", nx=True, ex=ttl_s))


async def release_offer_lock(user_id: str) -> None:
    await get_redis().delete(offer_lock_key(user_id))


async def throttle(key: str, seconds: int) -> bool:
    """True at most once per `seconds` for a key (e.g. location broadcasts every 3 s)."""
    return bool(await get_redis().set(f"throttle:{key}", "1", nx=True, ex=seconds))

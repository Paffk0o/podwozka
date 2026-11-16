"""Quotes: the price is computed only on the server and is valid for 5 minutes."""

import uuid
from datetime import UTC, datetime, timedelta
from zoneinfo import ZoneInfo

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.schemas import GeoPoint, Place
from app.core.config import get_settings
from app.core.security import Principal
from app.modules.pricing.calculator import calculate_price
from app.modules.pricing.models import QuoteRecord
from app.modules.pricing.routing import RoutingProvider, haversine_m
from app.modules.pricing.schemas import Quote, QuoteRequest
from app.modules.pricing.tariffs import active_tariff
from app.modules.regions import service as regions_service
from app.modules.regions.models import Region

SCHEDULE_MIN_AHEAD = timedelta(minutes=30)
SCHEDULE_MAX_AHEAD = timedelta(days=14)
MIN_TRIP_M = 200


def _unprocessable(message: str) -> HTTPException:
    return HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, message)


def validate_schedule(scheduled_at: datetime | None, now: datetime) -> None:
    if scheduled_at is None:
        return
    if scheduled_at.tzinfo is None:
        raise _unprocessable("scheduled_at musi zawierać strefę czasową")
    if scheduled_at < now + SCHEDULE_MIN_AHEAD:
        raise _unprocessable("Rezerwacja musi być co najmniej 30 minut do przodu")
    if scheduled_at > now + SCHEDULE_MAX_AHEAD:
        raise _unprocessable("Rezerwacja może być najwyżej 14 dni do przodu")


async def create_quote(
    session: AsyncSession, principal: Principal, data: QuoteRequest, routing: RoutingProvider
) -> Quote:
    now = datetime.now(UTC)
    validate_schedule(data.scheduled_at, now)

    region = await regions_service.find_region_for_point(
        session, data.pickup.location.lat, data.pickup.location.lng
    )
    if region is None:
        raise _unprocessable("Punkt odbioru poza obsługiwanymi regionami")
    pickup_time = data.scheduled_at or now
    tariff = await active_tariff(session, region.id, pickup_time)
    if tariff is None:
        raise _unprocessable("Region nie ma aktywnego cennika")
    if haversine_m(data.pickup.location, data.destination.location) < MIN_TRIP_M:
        raise _unprocessable("Cel jest zbyt blisko punktu odbioru")

    route = await routing.route(data.pickup.location, data.destination.location, pickup_time)
    local_time = pickup_time.astimezone(ZoneInfo(region.timezone))
    price = calculate_price(tariff, route.distance_m, route.duration_s, local_time)

    record = QuoteRecord(
        id=uuid.uuid4(),
        passenger_id=principal.sub,
        region_id=region.id,
        tariff_id=tariff.id,
        pickup_lat=data.pickup.location.lat,
        pickup_lng=data.pickup.location.lng,
        pickup_address=data.pickup.address,
        pickup_place_id=data.pickup.place_id,
        destination_lat=data.destination.location.lat,
        destination_lng=data.destination.location.lng,
        destination_address=data.destination.address,
        destination_place_id=data.destination.place_id,
        scheduled_at=data.scheduled_at,
        distance_m=route.distance_m,
        duration_s=route.duration_s,
        price=price,
        route_polyline=route.polyline,
        expires_at=now + timedelta(seconds=get_settings().quote_ttl_s),
    )
    session.add(record)
    await session.commit()
    return to_quote(record, region)


def to_quote(record: QuoteRecord, region: Region) -> Quote:
    return Quote(
        id=record.id,
        region_id=region.id,
        region_name=region.name,
        pickup=Place(
            location=GeoPoint(lat=record.pickup_lat, lng=record.pickup_lng),
            address=record.pickup_address,
            place_id=record.pickup_place_id,
        ),
        destination=Place(
            location=GeoPoint(lat=record.destination_lat, lng=record.destination_lng),
            address=record.destination_address,
            place_id=record.destination_place_id,
        ),
        scheduled_at=record.scheduled_at,
        distance_m=record.distance_m,
        duration_s=record.duration_s,
        price=record.price,
        tariff_id=record.tariff_id,
        route_polyline=record.route_polyline,
        expires_at=record.expires_at,
    )

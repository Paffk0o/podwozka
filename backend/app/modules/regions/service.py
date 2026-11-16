import json
import uuid
from typing import Any

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.geo import point_sql
from app.modules.regions.models import Region
from app.modules.regions.schemas import RegionCreate, RegionDetail, RegionUpdate

ALLOWED_GEOMETRIES = {"Polygon", "MultiPolygon"}


def _validate_geojson_shape(area: dict[str, Any]) -> str:
    if area.get("type") not in ALLOWED_GEOMETRIES or not isinstance(area.get("coordinates"), list):
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT,
            "Granica musi być geometrią GeoJSON typu Polygon lub MultiPolygon",
        )
    return json.dumps({"type": area["type"], "coordinates": area["coordinates"]})


async def _area_sql(session: AsyncSession, area: dict[str, Any]) -> Any:
    """Validate GeoJSON in PostGIS and return a MultiPolygon expression for it."""
    raw = _validate_geojson_shape(area)
    geom = func.ST_Multi(func.ST_SetSRID(func.ST_GeomFromGeoJSON(raw), 4326))
    try:
        valid = (await session.execute(select(func.ST_IsValid(geom)))).scalar_one()
    except Exception as exc:  # malformed coordinates → PostGIS raises
        await session.rollback()
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT, "Nieprawidłowa geometria GeoJSON"
        ) from exc
    if not valid:
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_CONTENT,
            "Geometria jest niepoprawna (np. samoprzecinający się poligon)",
        )
    return geom


async def list_active(session: AsyncSession) -> list[Region]:
    result = await session.execute(select(Region).where(Region.active).order_by(Region.name))
    return list(result.scalars())


async def get_region(session: AsyncSession, region_id: uuid.UUID) -> Region | None:
    return await session.get(Region, region_id)


async def require_region(session: AsyncSession, region_id: uuid.UUID) -> Region:
    region = await get_region(session, region_id)
    if region is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Region not found")
    return region


async def to_detail(session: AsyncSession, region: Region) -> RegionDetail:
    geojson = (await session.execute(select(func.ST_AsGeoJSON(region.area, 6)))).scalar_one()
    return RegionDetail(
        id=region.id,
        name=region.name,
        teryt=region.teryt,
        timezone=region.timezone,
        active=region.active,
        area=json.loads(geojson),
    )


async def list_all_detail(session: AsyncSession) -> list[RegionDetail]:
    rows = await session.execute(
        select(Region, func.ST_AsGeoJSON(Region.area, 6)).order_by(Region.name)
    )
    return [
        RegionDetail(
            id=r.id,
            name=r.name,
            teryt=r.teryt,
            timezone=r.timezone,
            active=r.active,
            area=json.loads(geojson),
        )
        for r, geojson in rows
    ]


async def create_region(session: AsyncSession, data: RegionCreate) -> Region:
    region = Region(
        name=data.name,
        teryt=data.teryt,
        active=data.active,
        area=await _area_sql(session, data.area),
    )
    session.add(region)
    await _commit_unique(session)
    await session.refresh(region)
    return region


async def update_region(session: AsyncSession, region_id: uuid.UUID, data: RegionUpdate) -> Region:
    region = await require_region(session, region_id)
    if data.name is not None:
        region.name = data.name
    if data.active is not None:
        region.active = data.active
    if data.area is not None:
        region.area = await _area_sql(session, data.area)
    await _commit_unique(session)
    await session.refresh(region)
    return region


async def _commit_unique(session: AsyncSession) -> None:
    try:
        await session.commit()
    except IntegrityError as exc:
        await session.rollback()
        raise HTTPException(
            status.HTTP_409_CONFLICT, "Region o tej nazwie lub kodzie TERYT już istnieje"
        ) from exc


async def find_region_for_point(session: AsyncSession, lat: float, lng: float) -> Region | None:
    """Active region containing the point; the smallest one wins if regions overlap."""
    result = await session.execute(
        select(Region)
        .where(Region.active, func.ST_Contains(Region.area, point_sql(lat, lng)))
        .order_by(func.ST_Area(Region.area))
        .limit(1)
    )
    return result.scalar_one_or_none()

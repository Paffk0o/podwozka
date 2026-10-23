from typing import Any
from uuid import UUID

from pydantic import Field

from app.common.schemas import ApiModel


class Region(ApiModel):
    """A municipality (gmina) served by the platform."""

    id: UUID
    name: str
    teryt: str | None = Field(description="Kod TERYT gminy (7 cyfr)")
    timezone: str = "Europe/Warsaw"
    active: bool


class RegionDetail(Region):
    area: dict[str, Any] = Field(
        description="Granica gminy jako GeoJSON (Polygon lub MultiPolygon, WGS84 / EPSG:4326)"
    )


class RegionCreate(ApiModel):
    name: str = Field(min_length=2, max_length=120)
    teryt: str | None = Field(default=None, pattern=r"^\d{7}$")
    area: dict[str, Any] = Field(description="GeoJSON Polygon lub MultiPolygon (EPSG:4326)")
    active: bool = True


class RegionUpdate(ApiModel):
    name: str | None = Field(default=None, min_length=2, max_length=120)
    area: dict[str, Any] | None = None
    active: bool | None = None

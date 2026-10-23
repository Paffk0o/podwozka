"""Shared API schemas. Money is always an integer number of grosze (1 PLN = 100)."""

from typing import Annotated

from pydantic import BaseModel, ConfigDict, Field

MoneyGrosze = Annotated[int, Field(ge=0, description="Kwota w groszach (1 PLN = 100)")]
Lat = Annotated[float, Field(ge=-90, le=90)]
Lng = Annotated[float, Field(ge=-180, le=180)]


class ApiModel(BaseModel):
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)


class GeoPoint(ApiModel):
    lat: Lat
    lng: Lng


class Place(ApiModel):
    """A point with a human-readable address (pickup / destination)."""

    location: GeoPoint
    address: str = Field(max_length=300)
    place_id: str | None = Field(default=None, description="Google Places ID, jeśli znany")


class Page[T](ApiModel):
    items: list[T]
    total: int
    limit: int
    offset: int


class ErrorResponse(ApiModel):
    detail: str

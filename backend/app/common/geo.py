"""Geometry helpers. API uses {lat, lng}; PostGIS/GeoJSON use (lng, lat) — convert only here."""

from typing import Any

from sqlalchemy import func
from sqlalchemy.sql.elements import ColumnElement

SRID = 4326


def point_sql(lat: float, lng: float) -> ColumnElement[Any]:
    """SQL expression for a WGS84 point (note the lng, lat order of ST_MakePoint)."""
    return func.ST_SetSRID(func.ST_MakePoint(lng, lat), SRID)

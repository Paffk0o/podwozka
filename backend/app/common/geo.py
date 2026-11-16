"""Geometry helpers. API uses {lat, lng}; PostGIS/GeoJSON use (lng, lat) — convert only here."""

import re
import struct
from typing import Any

from sqlalchemy import func
from sqlalchemy.sql.elements import ColumnElement

SRID = 4326
_WKT_POINT = re.compile(r"POINT\s*\(\s*(\S+)\s+(\S+)\s*\)", re.IGNORECASE)


def point_sql(lat: float, lng: float) -> ColumnElement[Any]:
    """SQL expression for a WGS84 point (note the lng, lat order of ST_MakePoint)."""
    return func.ST_SetSRID(func.ST_MakePoint(lng, lat), SRID)


def point_wkt(lat: float, lng: float) -> str:
    """EWKT for assigning a point to a Geometry column."""
    return f"SRID={SRID};POINT({lng} {lat})"


def wkb_point_latlng(element: Any) -> tuple[float, float]:
    """(lat, lng) from a PostGIS point returned as (E)WKB — no shapely needed for points."""
    data = getattr(element, "data", element)
    if isinstance(data, str) and (match := _WKT_POINT.search(data)):
        # Still the EWKT we assigned (object not reloaded from the database yet).
        return float(match.group(2)), float(match.group(1))
    raw = bytes.fromhex(data) if isinstance(data, str) else bytes(data)
    endian = "<" if raw[0] == 1 else ">"
    geom_type = struct.unpack(f"{endian}I", raw[1:5])[0]
    offset = 9 if geom_type & 0x20000000 else 5  # EWKB carries a 4-byte SRID
    x, y = struct.unpack(f"{endian}dd", raw[offset : offset + 16])
    return y, x

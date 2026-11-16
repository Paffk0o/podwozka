"""Import every module's ORM models here so Alembic sees the full metadata."""

from app.core.db import Base
from app.modules.drivers.models import DriverDocument, DriverProfile, Vehicle
from app.modules.pricing.models import QuoteRecord, Tariff
from app.modules.regions.models import Region
from app.modules.rides.models import Rating, Ride, RideEvent
from app.modules.users.models import User

__all__ = [
    "Base",
    "DriverDocument",
    "DriverProfile",
    "QuoteRecord",
    "Rating",
    "Region",
    "Ride",
    "RideEvent",
    "Tariff",
    "User",
    "Vehicle",
]

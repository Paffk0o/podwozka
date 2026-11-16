"""Import every module's ORM models here so Alembic sees the full metadata."""

from app.core.db import Base
from app.modules.pricing.models import Tariff
from app.modules.regions.models import Region
from app.modules.users.models import User

__all__ = ["Base", "Region", "Tariff", "User"]

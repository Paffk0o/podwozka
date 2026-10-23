"""Import every module's ORM models here so Alembic sees the full metadata."""

from app.core.db import Base
from app.modules.users.models import User

__all__ = ["Base", "User"]

from datetime import datetime
from uuid import UUID

from pydantic import Field

from app.common.schemas import ApiModel, MoneyGrosze, Place


class TariffBase(ApiModel):
    base_fare: MoneyGrosze = Field(description="Opłata startowa")
    per_km: MoneyGrosze = Field(description="Stawka za km")
    per_minute: MoneyGrosze = Field(description="Stawka za minutę jazdy")
    minimum_fare: MoneyGrosze = Field(description="Cena minimalna kursu")
    night_multiplier_percent: int = Field(
        default=100, ge=100, le=300, description="Mnożnik nocny w procentach (np. 120 = +20%)"
    )
    night_start_hour: int = Field(default=22, ge=0, le=23)
    night_end_hour: int = Field(default=6, ge=0, le=23)
    commission_percent: int = Field(default=10, ge=0, le=50, description="Prowizja platformy")


class TariffCreate(TariffBase):
    valid_from: datetime | None = Field(default=None, description="Domyślnie: teraz")


class Tariff(TariffBase):
    """A tariff version. Creating a new one closes the previous version (`valid_to`)."""

    id: UUID
    region_id: UUID
    valid_from: datetime
    valid_to: datetime | None


class QuoteRequest(ApiModel):
    pickup: Place
    destination: Place
    scheduled_at: datetime | None = Field(
        default=None, description="Brak = kurs teraz; data = rezerwacja (min. 30 min, max. 14 dni)"
    )


class Quote(ApiModel):
    id: UUID
    region_id: UUID
    region_name: str
    pickup: Place
    destination: Place
    scheduled_at: datetime | None
    distance_m: int
    duration_s: int
    price: MoneyGrosze
    currency: str = "PLN"
    tariff_id: UUID
    route_polyline: str | None = Field(description="Trasa w formacie encoded polyline (Google)")
    expires_at: datetime = Field(description="Wycena ważna do (5 min)")

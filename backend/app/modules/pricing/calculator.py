"""Price calculation — pure integer arithmetic in grosze (never floats for money)."""

from datetime import datetime
from typing import Protocol


class TariffRates(Protocol):
    base_fare: int
    per_km: int
    per_minute: int
    minimum_fare: int
    night_multiplier_percent: int
    night_start_hour: int
    night_end_hour: int


def _div_round(numerator: int, denominator: int) -> int:
    """Integer division rounding half up (inputs are non-negative)."""
    return (numerator + denominator // 2) // denominator


def is_night(hour: int, start_hour: int, end_hour: int) -> bool:
    """Night window [start, end) in local hours; may wrap past midnight (e.g. 22 → 6)."""
    if start_hour == end_hour:
        return False
    if start_hour < end_hour:
        return start_hour <= hour < end_hour
    return hour >= start_hour or hour < end_hour


def calculate_price(
    tariff: TariffRates, distance_m: int, duration_s: int, local_time: datetime
) -> int:
    """base + per_km·km + per_minute·min, times night multiplier, but never below minimum_fare."""
    subtotal = (
        tariff.base_fare
        + _div_round(tariff.per_km * distance_m, 1000)
        + _div_round(tariff.per_minute * duration_s, 60)
    )
    if is_night(local_time.hour, tariff.night_start_hour, tariff.night_end_hour):
        subtotal = _div_round(subtotal * tariff.night_multiplier_percent, 100)
    return max(subtotal, tariff.minimum_fare)


def commission(gross: int, commission_percent: int) -> int:
    return _div_round(gross * commission_percent, 100)

from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import Field

from app.common.schemas import ApiModel, GeoPoint, MoneyGrosze, Page, Place


class RideStatus(StrEnum):
    """Ride state machine — transitions only via the `rides` service (zarys §6)."""

    REQUESTED = "requested"
    SCHEDULED = "scheduled"
    DISPATCHING = "dispatching"
    ACCEPTED = "accepted"
    DRIVER_ARRIVING = "driver_arriving"
    ARRIVED = "arrived"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED_BY_PASSENGER = "cancelled_by_passenger"
    CANCELLED_BY_DRIVER = "cancelled_by_driver"
    NO_DRIVER = "no_driver"


class PaymentMethod(StrEnum):
    """`card` covers cards and wallets (Apple Pay / Google Pay) in Stripe PaymentSheet."""

    CARD = "card"
    BLIK = "blik"
    CASH = "cash"


class PaymentStatus(StrEnum):
    PENDING = "pending"  # waiting for the customer in PaymentSheet
    AUTHORIZED = "authorized"  # card: funds held (manual capture)
    PAID = "paid"
    REFUNDED = "refunded"
    FAILED = "failed"
    CASH_DUE = "cash_due"
    CASH_COLLECTED = "cash_collected"


class Vehicle(ApiModel):
    make: str = Field(max_length=60)
    model: str = Field(max_length=60)
    color: str = Field(max_length=30)
    plate: str = Field(max_length=12, description="Numer rejestracyjny")
    seats: int = Field(default=4, ge=1, le=8)


class RideDriverInfo(ApiModel):
    """What the passenger sees about the assigned driver."""

    id: str
    full_name: str
    phone: str | None
    rating_avg: float | None
    vehicle: Vehicle
    location: GeoPoint | None = Field(description="Ostatnia znana pozycja (dalej przez WebSocket)")


class RidePassengerInfo(ApiModel):
    """What the driver sees about the passenger."""

    id: str
    full_name: str
    phone: str | None
    rating_avg: float | None


class Ride(ApiModel):
    id: UUID
    status: RideStatus
    region_id: UUID
    pickup: Place
    destination: Place
    scheduled_at: datetime | None = Field(description="Rezerwacja; brak = kurs teraz")
    requested_at: datetime
    accepted_at: datetime | None
    started_at: datetime | None
    completed_at: datetime | None
    cancelled_at: datetime | None
    cancel_reason: str | None
    price: MoneyGrosze
    currency: str = "PLN"
    payment_method: PaymentMethod
    payment_status: PaymentStatus
    distance_m: int
    duration_s: int
    route_polyline: str | None
    passenger_note: str | None
    driver: RideDriverInfo | None
    passenger: RidePassengerInfo | None = Field(
        description="Wypełniane tylko w widoku kierowcy/admina"
    )


class RideCreate(ApiModel):
    quote_id: UUID
    payment_method: PaymentMethod
    passenger_note: str | None = Field(default=None, max_length=300)


class StripePaymentInit(ApiModel):
    """Data for Stripe PaymentSheet in the app (`flutter_stripe`)."""

    payment_intent_id: str
    client_secret: str
    customer_id: str | None
    ephemeral_key_secret: str | None
    publishable_key: str


class RideCreated(ApiModel):
    ride: Ride
    payment: StripePaymentInit | None = Field(description="Brak dla gotówki")


class CancelRequest(ApiModel):
    reason: str | None = Field(default=None, max_length=300)


class RatingCreate(ApiModel):
    stars: int = Field(ge=1, le=5)
    comment: str | None = Field(default=None, max_length=500)


class RidePage(Page[Ride]):
    pass

from datetime import date, datetime
from enum import StrEnum
from uuid import UUID

from pydantic import Field

from app.common.schemas import ApiModel, MoneyGrosze
from app.modules.rides.schemas import PaymentMethod, Ride, Vehicle


class DriverStatus(StrEnum):
    DRAFT = "draft"  # application started, documents being uploaded
    PENDING = "pending"  # submitted, waiting for admin
    APPROVED = "approved"
    REJECTED = "rejected"
    SUSPENDED = "suspended"


class DocumentType(StrEnum):
    DRIVING_LICENSE = "driving_license"
    VEHICLE_REGISTRATION = "vehicle_registration"
    INSURANCE_OC = "insurance_oc"
    DRIVER_PHOTO = "driver_photo"


class DocumentStatus(StrEnum):
    AWAITING_UPLOAD = "awaiting_upload"
    UPLOADED = "uploaded"
    ACCEPTED = "accepted"
    REJECTED = "rejected"


class DriverDocument(ApiModel):
    id: UUID
    type: DocumentType
    status: DocumentStatus
    content_type: str
    expires_on: date | None
    uploaded_at: datetime | None
    review_comment: str | None


class DriverProfile(ApiModel):
    user_id: str
    status: DriverStatus
    region_id: UUID
    vehicle: Vehicle
    documents: list[DriverDocument]
    rejection_reason: str | None
    rating_avg: float | None
    online: bool
    approved_at: datetime | None


class DriverApplicationUpsert(ApiModel):
    region_id: UUID
    vehicle: Vehicle


class DocumentUploadRequest(ApiModel):
    type: DocumentType
    content_type: str = Field(pattern=r"^(image/jpeg|image/png|image/heic|application/pdf)$")
    size_bytes: int = Field(gt=0, le=10 * 1024 * 1024, description="Maks. 10 MB")
    expires_on: date | None = Field(default=None, description="Data ważności dokumentu")


class DocumentUploadSlot(ApiModel):
    """Upload the file with `PUT upload_url` (body = file bytes) and `required_headers`,
    then call `POST /drivers/me/documents/{document_id}/complete`."""

    document_id: UUID
    upload_url: str
    required_headers: dict[str, str] = Field(
        description='Np. {"x-ms-blob-type": "BlockBlob", "Content-Type": "image/jpeg"}'
    )
    expires_at: datetime


class AvailabilityUpdate(ApiModel):
    online: bool


class RideOffer(ApiModel):
    """An offer to take a ride now. Expires after ~20 s (then goes to the next driver)."""

    id: UUID
    ride: Ride
    pickup_distance_m: int
    pickup_eta_s: int
    expires_at: datetime


class DriverCurrentState(ApiModel):
    """Used after app (re)start to restore the screen; live updates come via WebSocket."""

    profile: DriverProfile
    pending_offer: RideOffer | None
    active_ride: Ride | None
    next_scheduled_ride: Ride | None


class DriverRideAction(StrEnum):
    DEPART = "depart"  # accepted -> driver_arriving (for scheduled rides: start driving to pickup)
    ARRIVED = "arrived"  # driver_arriving -> arrived
    START = "start"  # arrived -> in_progress
    COMPLETE = "complete"  # in_progress -> completed


class DriverRideActionRequest(ApiModel):
    action: DriverRideAction


class EarningEntry(ApiModel):
    ride_id: UUID
    completed_at: datetime
    payment_method: PaymentMethod
    gross: MoneyGrosze
    commission: MoneyGrosze
    net: MoneyGrosze


class EarningsSummary(ApiModel):
    date_from: date
    date_to: date
    rides_count: int
    gross: MoneyGrosze
    commission: MoneyGrosze
    net: MoneyGrosze
    cash_collected: MoneyGrosze = Field(description="Gotówka przyjęta przez kierowcę")
    commission_due_from_cash: MoneyGrosze = Field(description="Prowizja do rozliczenia z gotówki")
    items: list[EarningEntry]

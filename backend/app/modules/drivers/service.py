"""Driver applications, documents, admin review and the "approved driver" check."""

import uuid
from datetime import UTC, date, datetime, timedelta
from typing import Annotated

from fastapi import Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.common.schemas import GeoPoint
from app.core.db import SessionDep
from app.core.keycloak_admin import IdentityAdmin, IdentityAdminError
from app.core.security import DriverDep, Principal, Role
from app.modules.drivers.models import DriverDocument as DocumentRow
from app.modules.drivers.models import DriverProfile as ProfileRow
from app.modules.drivers.models import Vehicle as VehicleRow
from app.modules.drivers.schemas import (
    DocumentStatus,
    DocumentType,
    DocumentUploadRequest,
    DocumentUploadSlot,
    DriverApplicationUpsert,
    DriverDocument,
    DriverProfile,
    DriverStatus,
)
from app.modules.drivers.storage import DocumentStorage
from app.modules.regions import service as regions_service
from app.modules.rides.schemas import RideDriverInfo, Vehicle
from app.modules.users import service as users_service
from app.modules.users.models import User

UPLOAD_LINK_TTL = timedelta(minutes=15)
VIEW_LINK_TTL = timedelta(minutes=5)
REQUIRED_DOCUMENTS = frozenset(DocumentType)
EDITABLE = frozenset({DriverStatus.DRAFT, DriverStatus.REJECTED})


def _conflict(message: str) -> HTTPException:
    return HTTPException(status.HTTP_409_CONFLICT, message)


def _unprocessable(message: str) -> HTTPException:
    return HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, message)


async def get_profile(
    session: AsyncSession, user_id: str, for_update: bool = False
) -> ProfileRow | None:
    query = select(ProfileRow).where(ProfileRow.user_id == user_id)
    if for_update:
        query = query.with_for_update().execution_options(populate_existing=True)
    return (await session.execute(query)).scalar_one_or_none()


async def require_profile(
    session: AsyncSession, user_id: str, for_update: bool = False
) -> ProfileRow:
    profile = await get_profile(session, user_id, for_update)
    if profile is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Driver application not found")
    return profile


async def current_documents(session: AsyncSession, user_id: str) -> list[DocumentRow]:
    result = await session.execute(
        select(DocumentRow)
        .where(DocumentRow.driver_id == user_id, DocumentRow.replaced_at.is_(None))
        .order_by(DocumentRow.type, DocumentRow.created_at)
    )
    return list(result.scalars())


# --- Applicant ---


async def upsert_application(
    session: AsyncSession, principal: Principal, data: DriverApplicationUpsert
) -> ProfileRow:
    region = await regions_service.get_region(session, data.region_id)
    if region is None or not region.active:
        raise _unprocessable("Region nie istnieje albo jest nieaktywny")
    await users_service.ensure_user(session, principal)
    profile = await get_profile(session, principal.sub, for_update=True)
    if profile is None:
        profile = ProfileRow(user_id=principal.sub, status=DriverStatus.DRAFT, online=False)
        session.add(profile)
    elif profile.status not in EDITABLE:
        raise _conflict("Wniosku nie można już zmieniać")
    profile.region_id = data.region_id
    if profile.status == DriverStatus.REJECTED:
        profile.status = DriverStatus.DRAFT  # corrected application starts over
    await session.flush()

    vehicle = await session.get(VehicleRow, principal.sub)
    if vehicle is None:
        vehicle = VehicleRow(driver_id=principal.sub)
        session.add(vehicle)
    vehicle.make = data.vehicle.make
    vehicle.model = data.vehicle.model
    vehicle.color = data.vehicle.color
    vehicle.plate = data.vehicle.plate.upper().replace(" ", "")
    vehicle.seats = data.vehicle.seats
    await session.commit()
    return profile


async def create_upload_slot(
    session: AsyncSession,
    principal: Principal,
    data: DocumentUploadRequest,
    storage: DocumentStorage,
) -> DocumentUploadSlot:
    profile = await require_profile(session, principal.sub, for_update=True)
    if profile.status not in EDITABLE:
        raise _conflict("Dokumenty można wysyłać tylko do wniosku w przygotowaniu")
    if data.expires_on is not None and data.expires_on < date.today():
        raise _unprocessable("Dokument jest już nieważny")

    await storage.ensure_container()
    document_id = uuid.uuid4()
    path = f"drivers/{principal.sub}/{document_id}"
    upload = storage.upload_url(path, data.content_type, UPLOAD_LINK_TTL)
    # A slot that was never used is replaced by the new one.
    stale = await session.execute(
        select(DocumentRow).where(
            DocumentRow.driver_id == principal.sub,
            DocumentRow.type == data.type,
            DocumentRow.status == DocumentStatus.AWAITING_UPLOAD,
        )
    )
    for row in stale.scalars():
        await session.delete(row)
    session.add(
        DocumentRow(
            id=document_id,
            driver_id=principal.sub,
            type=data.type,
            status=DocumentStatus.AWAITING_UPLOAD,
            content_type=data.content_type,
            size_bytes=data.size_bytes,
            blob_path=path,
            expires_on=data.expires_on,
        )
    )
    await session.commit()
    return DocumentUploadSlot(
        document_id=document_id,
        upload_url=upload.url,
        required_headers=upload.headers,
        expires_at=upload.expires_at,
    )


async def complete_upload(
    session: AsyncSession, principal: Principal, document_id: uuid.UUID, storage: DocumentStorage
) -> DocumentRow:
    document = await session.get(DocumentRow, document_id)
    if document is None or document.driver_id != principal.sub:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Document not found")
    if document.status != DocumentStatus.AWAITING_UPLOAD:
        return document  # idempotent: already confirmed
    if not await storage.exists(document.blob_path):
        raise _conflict("Plik nie został jeszcze wysłany")
    now = datetime.now(UTC)
    older = await session.execute(
        select(DocumentRow).where(
            DocumentRow.driver_id == principal.sub,
            DocumentRow.type == document.type,
            DocumentRow.id != document.id,
            DocumentRow.replaced_at.is_(None),
        )
    )
    for row in older.scalars():
        row.replaced_at = now
    document.status = DocumentStatus.UPLOADED
    document.uploaded_at = now
    await session.commit()
    return document


async def submit_application(session: AsyncSession, principal: Principal) -> ProfileRow:
    profile = await require_profile(session, principal.sub, for_update=True)
    if profile.status != DriverStatus.DRAFT:
        raise _conflict("Wniosek został już wysłany")
    documents = await current_documents(session, principal.sub)
    uploaded = {
        DocumentType(d.type)
        for d in documents
        if d.status in (DocumentStatus.UPLOADED, DocumentStatus.ACCEPTED)
    }
    missing = REQUIRED_DOCUMENTS - uploaded
    if missing:
        names = ", ".join(sorted(missing))
        raise _unprocessable(f"Brakuje dokumentów: {names}")
    if await session.get(VehicleRow, principal.sub) is None:  # pragma: no cover - set on upsert
        raise _unprocessable("Brakuje danych pojazdu")
    profile.status = DriverStatus.PENDING
    profile.submitted_at = datetime.now(UTC)
    profile.status_reason = None
    await session.commit()
    return profile


# --- Admin review ---


async def approve(session: AsyncSession, user_id: str, identity: IdentityAdmin) -> ProfileRow:
    profile = await require_profile(session, user_id, for_update=True)
    if profile.status not in (DriverStatus.PENDING, DriverStatus.SUSPENDED):
        raise _conflict("Zatwierdzić można tylko wniosek oczekujący lub zawieszonego kierowcę")
    try:
        await identity.grant_realm_role(user_id, Role.DRIVER.value)
    except IdentityAdminError as exc:
        raise HTTPException(
            status.HTTP_502_BAD_GATEWAY, "Nie udało się nadać roli w Keycloaku"
        ) from exc
    now = datetime.now(UTC)
    profile.status = DriverStatus.APPROVED
    profile.approved_at = profile.approved_at or now
    profile.suspended_at = None
    profile.status_reason = None
    for document in await current_documents(session, user_id):
        if document.status == DocumentStatus.UPLOADED:
            document.status = DocumentStatus.ACCEPTED
    await session.commit()
    return profile


async def reject(session: AsyncSession, user_id: str, reason: str) -> ProfileRow:
    profile = await require_profile(session, user_id, for_update=True)
    if profile.status != DriverStatus.PENDING:
        raise _conflict("Odrzucić można tylko wniosek oczekujący")
    profile.status = DriverStatus.REJECTED
    profile.status_reason = reason
    await session.commit()
    return profile


async def suspend(session: AsyncSession, user_id: str, reason: str) -> ProfileRow:
    profile = await require_profile(session, user_id, for_update=True)
    if profile.status != DriverStatus.APPROVED:
        raise _conflict("Zawiesić można tylko zatwierdzonego kierowcę")
    profile.status = DriverStatus.SUSPENDED
    profile.status_reason = reason
    profile.suspended_at = datetime.now(UTC)
    profile.online = False
    profile.online_changed_at = profile.suspended_at
    await session.commit()
    return profile


async def document_view_url(
    session: AsyncSession, user_id: str, document_id: uuid.UUID, storage: DocumentStorage
) -> tuple[str, datetime]:
    document = await session.get(DocumentRow, document_id)
    if document is None or document.driver_id != user_id:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Document not found")
    if document.status == DocumentStatus.AWAITING_UPLOAD:
        raise _conflict("Plik nie został jeszcze wysłany")
    return storage.view_url(document.blob_path, VIEW_LINK_TTL)


# --- Approved driver check (role in token + status in DB) ---


async def require_approved_driver(session: AsyncSession, principal: Principal) -> ProfileRow:
    """Suspension works immediately: the token may still carry the `driver` role."""
    profile = await get_profile(session, principal.sub)
    if profile is None or profile.status != DriverStatus.APPROVED:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Konto kierowcy nie jest aktywne")
    return profile


async def _approved_driver(principal: DriverDep, session: SessionDep) -> ProfileRow:
    return await require_approved_driver(session, principal)


ApprovedDriverDep = Annotated[ProfileRow, Depends(_approved_driver)]


# --- Serialisation ---


async def vehicle_of(session: AsyncSession, user_id: str) -> Vehicle:
    row = await session.get(VehicleRow, user_id)
    if row is None:  # pragma: no cover - profiles are always created with a vehicle
        return Vehicle(make="-", model="-", color="-", plate="-", seats=4)
    return Vehicle(
        make=row.make, model=row.model, color=row.color, plate=row.plate, seats=row.seats
    )


async def driver_rating(session: AsyncSession, user_id: str) -> float | None:
    from app.modules.rides.service import ActorRole, average_rating

    return await average_rating(session, user_id, ActorRole.DRIVER)


def document_schema(row: DocumentRow) -> DriverDocument:
    return DriverDocument(
        id=row.id,
        type=DocumentType(row.type),
        status=DocumentStatus(row.status),
        content_type=row.content_type,
        expires_on=row.expires_on,
        uploaded_at=row.uploaded_at,
        review_comment=row.review_comment,
    )


async def to_schema(session: AsyncSession, profile: ProfileRow) -> DriverProfile:
    return DriverProfile(
        user_id=profile.user_id,
        status=DriverStatus(profile.status),
        region_id=profile.region_id,
        vehicle=await vehicle_of(session, profile.user_id),
        documents=[document_schema(d) for d in await current_documents(session, profile.user_id)],
        rejection_reason=profile.status_reason,
        rating_avg=await driver_rating(session, profile.user_id),
        online=profile.online,
        approved_at=profile.approved_at,
    )


async def ride_driver_info(
    session: AsyncSession, driver_id: str, location: GeoPoint | None = None
) -> RideDriverInfo:
    user = await session.get(User, driver_id)
    return RideDriverInfo(
        id=driver_id,
        full_name=(user.full_name if user else None) or "Kierowca",
        phone=user.phone if user else None,
        rating_avg=await driver_rating(session, driver_id),
        vehicle=await vehicle_of(session, driver_id),
        location=location,
    )

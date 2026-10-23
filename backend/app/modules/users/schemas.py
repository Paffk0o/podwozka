from enum import StrEnum
from typing import Annotated

from pydantic import Field

from app.common.schemas import ApiModel

PhoneE164 = Annotated[
    str, Field(pattern=r"^\+[1-9]\d{7,14}$", description="Numer w formacie E.164, np. +48600100200")
]


class Me(ApiModel):
    id: str = Field(description="Identyfikator użytkownika (claim `sub` z Keycloaka)")
    email: str | None
    full_name: str | None
    phone: str | None
    phone_verified: bool
    roles: list[str] = Field(description="Role realmu: passenger, driver, admin")


class MeUpsert(ApiModel):
    full_name: str | None = Field(default=None, min_length=1, max_length=200)
    phone: PhoneE164 | None = None


class PhoneVerificationRequest(ApiModel):
    phone: PhoneE164


class PhoneVerificationConfirm(ApiModel):
    code: str = Field(pattern=r"^\d{6}$")


class DevicePlatform(StrEnum):
    ANDROID = "android"
    IOS = "ios"
    WEB = "web"


class DeviceTokenIn(ApiModel):
    token: str = Field(min_length=10, max_length=4096, description="Token FCM")
    platform: DevicePlatform
    app: str = Field(pattern=r"^(passenger|driver|admin)$", description="Która aplikacja")

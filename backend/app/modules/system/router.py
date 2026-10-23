from fastapi import APIRouter
from pydantic import Field

from app.common.schemas import ApiModel
from app.core.config import get_settings

router = APIRouter(tags=["system"])


class Health(ApiModel):
    status: str = "ok"
    environment: str


class PublicConfig(ApiModel):
    """Non-secret runtime config for the apps (fetched on startup, no auth)."""

    oidc_issuer: str
    stripe_publishable_key: str | None
    min_app_version: str = Field(
        default="0.1.0", description="Starsze wersje muszą się zaktualizować"
    )
    support_phone: str | None = None


@router.get("/health", response_model=Health, summary="Healthcheck")
async def health() -> Health:
    return Health(environment=get_settings().environment)


@router.get("/config", response_model=PublicConfig, summary="Publiczna konfiguracja aplikacji")
async def get_public_config() -> PublicConfig:
    settings = get_settings()
    return PublicConfig(
        oidc_issuer=settings.oidc_issuer,
        stripe_publishable_key=settings.stripe_publishable_key,
    )

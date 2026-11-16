from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings, read from environment variables (prefix-less) and `.env`."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    environment: Literal["local", "test", "staging", "production"] = "local"

    database_url: str = "postgresql+asyncpg://podwozka:podwozka@localhost:5432/podwozka"
    redis_url: str = "redis://localhost:6379/0"

    # OIDC (Keycloak)
    # Issuer = the URL that appears in the `iss` claim (what clients use to log in).
    oidc_issuer: str = "http://localhost:8080/realms/podwozka"
    # Optional internal URL for fetching JWKS (e.g. http://keycloak:8080/... inside Docker).
    oidc_jwks_url: str | None = None
    oidc_audience: str = "podwozka-api"
    oidc_allowed_clients: list[str] = Field(
        default_factory=lambda: ["passenger-app", "driver-app", "admin-panel"]
    )

    cors_origins: list[str] = Field(
        default_factory=lambda: ["http://localhost:5173", "http://localhost:8081"]
    )

    sentry_dsn: str | None = None

    # Google Maps Platform server key (Routes, Places, Geocoding). Empty = offline fallbacks.
    google_maps_server_key: str | None = None
    quote_ttl_s: int = 300
    # Ordering requires a verified phone (zarys 5.1). Off until SMS verification (SMSAPI) exists.
    require_verified_phone: bool = False
    # Address fallback without a Google key. Nominatim's policy requires an identifying
    # User-Agent (set NOMINATIM_USER_AGENT to include a contact address) and max 1 request/s.
    nominatim_url: str = "https://nominatim.openstreetmap.org"
    nominatim_user_agent: str = "Podwozka-backend/1.0"

    # Stripe (test mode). Secret key and webhook secret are added by the payments module.
    stripe_publishable_key: str | None = None

    @property
    def jwks_url(self) -> str:
        return self.oidc_jwks_url or f"{self.oidc_issuer}/protocol/openid-connect/certs"


@lru_cache
def get_settings() -> Settings:
    return Settings()

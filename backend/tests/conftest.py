import os

os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault(
    "DATABASE_URL", "postgresql+asyncpg://podwozka:podwozka@localhost:5432/podwozka_test"
)
os.environ.setdefault("OIDC_ISSUER", "http://keycloak.test/realms/podwozka")

import time
import uuid
from collections.abc import AsyncIterator, Callable
from pathlib import Path
from typing import Any

import jwt
import pytest
from alembic import command
from alembic.config import Config
from cryptography.hazmat.primitives.asymmetric import rsa
from httpx import ASGITransport, AsyncClient
from jwt.algorithms import RSAAlgorithm
from sqlalchemy import text

from app.core import security
from app.core.config import get_settings
from app.core.db import dispose_engine, get_engine
from app.main import app

BACKEND_DIR = Path(__file__).resolve().parents[1]
KID = "test-key-1"
_private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)


def _jwks() -> dict[str, Any]:
    public_jwk = RSAAlgorithm.to_jwk(_private_key.public_key(), as_dict=True)
    public_jwk.update({"kid": KID, "use": "sig", "alg": "RS256"})
    return {"keys": [public_jwk]}


TokenFactory = Callable[..., str]


@pytest.fixture(scope="session")
def make_token() -> TokenFactory:
    settings = get_settings()

    def factory(
        *,
        sub: str | None = None,
        roles: tuple[str, ...] = ("passenger",),
        client: str = "passenger-app",
        audience: str | None = None,
        issuer: str | None = None,
        expires_in: int = 300,
        email: str | None = "jan@podwozka.test",
        name: str | None = "Jan Kowalski",
        key: Any = None,
        kid: str = KID,
    ) -> str:
        now = int(time.time())
        claims = {
            "sub": sub or str(uuid.uuid4()),
            "iss": issuer or settings.oidc_issuer,
            "aud": audience or settings.oidc_audience,
            "azp": client,
            "iat": now,
            "exp": now + expires_in,
            "realm_access": {"roles": list(roles)},
            "email": email,
            "name": name,
        }
        return jwt.encode(claims, key or _private_key, algorithm="RS256", headers={"kid": kid})

    return factory


@pytest.fixture(scope="session", autouse=True)
def _test_verifier() -> None:
    async def fetch() -> dict[str, Any]:
        return _jwks()

    security._verifier = security.TokenVerifier(get_settings(), security.JwksCache(fetch))


@pytest.fixture(scope="session", autouse=True)
def _migrate_db() -> None:
    cfg = Config(str(BACKEND_DIR / "alembic.ini"))
    command.upgrade(cfg, "head")


@pytest.fixture(autouse=True)
async def _clean_db() -> AsyncIterator[None]:
    yield
    async with get_engine().begin() as conn:
        await conn.execute(text("TRUNCATE users CASCADE"))


@pytest.fixture(scope="session", autouse=True)
async def _dispose() -> AsyncIterator[None]:
    yield
    await dispose_engine()


@pytest.fixture
async def client() -> AsyncIterator[AsyncClient]:
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as c:
        yield c


def auth(token: str) -> dict[str, str]:
    return {"Authorization": f"Bearer {token}"}

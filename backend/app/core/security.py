"""Access-token verification for tokens issued by Keycloak.

The backend never sees passwords — it only verifies JWTs (signature via JWKS, `iss`, `aud`,
`exp`, `azp`) and reads realm roles from `realm_access.roles`.
"""

import asyncio
import time
from collections.abc import Awaitable, Callable
from dataclasses import dataclass, field
from enum import StrEnum
from typing import Annotated, Any

import httpx
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import Settings, get_settings


class Role(StrEnum):
    PASSENGER = "passenger"
    DRIVER = "driver"
    ADMIN = "admin"


@dataclass(frozen=True, slots=True)
class Principal:
    """Authenticated caller, built from a verified access token."""

    sub: str
    client_id: str
    roles: frozenset[str] = field(default_factory=frozenset)
    email: str | None = None
    name: str | None = None

    def has_role(self, role: Role) -> bool:
        return role.value in self.roles


class TokenError(Exception):
    pass


JwksFetcher = Callable[[], Awaitable[dict[str, Any]]]


class JwksCache:
    """JWKS cache; refetches on an unknown `kid` (key rotation).

    Refetch happens at most every `min_refresh` seconds.
    """

    def __init__(self, fetch: JwksFetcher, ttl: float = 3600, min_refresh: float = 30) -> None:
        self._fetch = fetch
        self._ttl = ttl
        self._min_refresh = min_refresh
        self._keys: dict[str, jwt.PyJWK] = {}
        self._fetched_at = 0.0
        self._lock = asyncio.Lock()

    async def _refresh(self) -> None:
        data = await self._fetch()
        keys: dict[str, jwt.PyJWK] = {}
        for jwk in data.get("keys", []):
            if jwk.get("use", "sig") != "sig" or "kid" not in jwk:
                continue
            try:
                keys[jwk["kid"]] = jwt.PyJWK(jwk)
            except jwt.PyJWTError:
                continue  # unsupported key type (e.g. RSA-OAEP encryption key)
        self._keys = keys
        self._fetched_at = time.monotonic()

    async def get_key(self, kid: str) -> jwt.PyJWK:
        now = time.monotonic()
        if kid in self._keys and now - self._fetched_at < self._ttl:
            return self._keys[kid]
        async with self._lock:
            age = time.monotonic() - self._fetched_at
            if (kid not in self._keys and age >= self._min_refresh) or age >= self._ttl:
                await self._refresh()
        if kid not in self._keys:
            raise TokenError("unknown signing key")
        return self._keys[kid]


def http_jwks_fetcher(url: str) -> JwksFetcher:
    async def fetch() -> dict[str, Any]:
        async with httpx.AsyncClient(timeout=5) as client:
            response = await client.get(url)
            response.raise_for_status()
            result: dict[str, Any] = response.json()
            return result

    return fetch


class TokenVerifier:
    ALGORITHMS = ("RS256", "ES256", "PS256")

    def __init__(self, settings: Settings, jwks: JwksCache) -> None:
        self._settings = settings
        self._jwks = jwks

    async def verify(self, token: str) -> Principal:
        try:
            header = jwt.get_unverified_header(token)
        except jwt.PyJWTError as exc:
            raise TokenError("malformed token") from exc
        kid = header.get("kid")
        if not kid:
            raise TokenError("missing kid")
        key = await self._jwks.get_key(kid)
        try:
            claims: dict[str, Any] = jwt.decode(
                token,
                key=key,
                algorithms=list(self.ALGORITHMS),
                audience=self._settings.oidc_audience,
                issuer=self._settings.oidc_issuer,
                options={"require": ["exp", "iat", "iss", "aud", "sub"]},
                leeway=30,
            )
        except jwt.PyJWTError as exc:
            raise TokenError(str(exc)) from exc

        client_id = claims.get("azp", "")
        if client_id not in self._settings.oidc_allowed_clients:
            raise TokenError("token issued for a client that is not allowed")
        roles = claims.get("realm_access", {}).get("roles", [])
        return Principal(
            sub=claims["sub"],
            client_id=client_id,
            roles=frozenset(r for r in roles if isinstance(r, str)),
            email=claims.get("email"),
            name=claims.get("name"),
        )


_verifier: TokenVerifier | None = None


def get_token_verifier() -> TokenVerifier:
    global _verifier
    if _verifier is None:
        settings = get_settings()
        _verifier = TokenVerifier(settings, JwksCache(http_jwks_fetcher(settings.jwks_url)))
    return _verifier


_bearer = HTTPBearer(auto_error=False, description="Access token z Keycloaka (realm podwozka)")


async def get_principal(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
    verifier: Annotated[TokenVerifier, Depends(get_token_verifier)],
) -> Principal:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "Missing bearer token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        return await verifier.verify(credentials.credentials)
    except TokenError as exc:
        raise HTTPException(
            status.HTTP_401_UNAUTHORIZED,
            "Invalid token",
            headers={"WWW-Authenticate": 'Bearer error="invalid_token"'},
        ) from exc


PrincipalDep = Annotated[Principal, Depends(get_principal)]


def require_role(role: Role) -> Callable[[Principal], Awaitable[Principal]]:
    async def dependency(principal: PrincipalDep) -> Principal:
        if not principal.has_role(role):
            raise HTTPException(status.HTTP_403_FORBIDDEN, f"Role '{role.value}' required")
        return principal

    return dependency


PassengerDep = Annotated[Principal, Depends(require_role(Role.PASSENGER))]
# NOTE: endpoints for drivers must ALSO check driver_profile.status == approved in the DB
# (see AGENTS.md) — the role alone does not reflect a suspension made after token issuance.
DriverDep = Annotated[Principal, Depends(require_role(Role.DRIVER))]
AdminDep = Annotated[Principal, Depends(require_role(Role.ADMIN))]

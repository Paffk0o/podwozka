"""WebSocket endpoint `/ws` — protocol in docs/ws-protocol.md.

Each connection subscribes (Redis pub/sub) to `user:{sub}` and to the `ride:{id}` channels it
asks for, and forwards those messages to the client. Any API replica can publish an event; the
replica holding the connection delivers it. The WebSocket only notifies — REST stays the source
of truth.
"""

import asyncio
import contextlib
import json
import logging
import time
import uuid
from dataclasses import dataclass
from typing import Any

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status
from pydantic import ValidationError

from app.common.schemas import GeoPoint
from app.core import events
from app.core.db import get_sessionmaker
from app.core.redis import get_redis
from app.core.security import Principal, Role, TokenError, get_token_verifier
from app.modules.dispatch import presence
from app.modules.dispatch import service as dispatch
from app.modules.drivers.models import DriverProfile
from app.modules.drivers.schemas import DriverStatus
from app.modules.rides import service as rides
from app.modules.rides.schemas import RideStatus

router = APIRouter()
log = logging.getLogger(__name__)

AUTH_TIMEOUT_S = 10
DRIVER_CONTEXT_TTL_S = 15
LOCATION_BROADCAST_EVERY_S = 3
BEFORE_PICKUP = {RideStatus.ACCEPTED, RideStatus.DRIVER_ARRIVING, RideStatus.ARRIVED}


async def _send(ws: WebSocket, type_: str, **payload: Any) -> None:
    await ws.send_text(json.dumps({"type": type_, **payload}, default=str))


async def _authenticate(ws: WebSocket) -> Principal | None:
    try:
        raw = await asyncio.wait_for(ws.receive_text(), timeout=AUTH_TIMEOUT_S)
        message = json.loads(raw)
    except TimeoutError, json.JSONDecodeError:
        return None
    if not isinstance(message, dict) or message.get("type") != "auth":
        return None
    token = message.get("token")
    if not isinstance(token, str):
        return None
    try:
        return await get_token_verifier().verify(token)
    except TokenError:
        return None


@dataclass
class DriverContext:
    """Cached for a few seconds: the driver sends a position every 3-5 s."""

    profile_ok: bool
    region_id: uuid.UUID | None
    ride_id: uuid.UUID | None
    target: GeoPoint | None  # pickup before pickup, destination afterwards
    loaded_at: float


class Connection:
    def __init__(self, ws: WebSocket, principal: Principal) -> None:
        self.ws = ws
        self.principal = principal
        self.pubsub = get_redis().pubsub()
        self.lock = asyncio.Lock()
        self.driver_context: DriverContext | None = None

    async def forward(self) -> None:
        """Redis -> client. The lock lets (un)subscribe calls share the pub/sub connection."""
        while True:
            async with self.lock:
                message = await self.pubsub.get_message(ignore_subscribe_messages=True, timeout=0.2)
            if message is not None and message.get("type") == "message":
                await self.ws.send_text(message["data"])
            else:
                await asyncio.sleep(0.01)

    async def run(self) -> None:
        await self.pubsub.subscribe(events.user_channel(self.principal.sub))
        forwarder = asyncio.create_task(self.forward())
        try:
            await self.receive_loop()
        finally:
            forwarder.cancel()
            with contextlib.suppress(asyncio.CancelledError, Exception):
                await forwarder
            with contextlib.suppress(Exception):
                await self.pubsub.aclose()  # type: ignore[no-untyped-call]

    async def receive_loop(self) -> None:
        while True:
            remaining = (self.principal.expires_at or float("inf")) - time.time()
            try:
                raw = await asyncio.wait_for(self.ws.receive_text(), timeout=max(remaining, 0))
            except TimeoutError:
                await _send(self.ws, "token_expired")
                await self.ws.close(code=status.WS_1008_POLICY_VIOLATION)
                return
            try:
                message = json.loads(raw)
            except json.JSONDecodeError:
                await _send(self.ws, "error", code="bad_request", message="Invalid JSON")
                continue
            if not isinstance(message, dict):
                await _send(self.ws, "error", code="bad_request", message="Expected an object")
                continue
            await self.handle(message)

    async def handle(self, message: dict[str, Any]) -> None:
        match message.get("type"):
            case "ping":
                await _send(self.ws, "pong")
            case "subscribe":
                await self.subscribe(message.get("ride_id"))
            case "unsubscribe":
                ride_id = _uuid(message.get("ride_id"))
                if ride_id is not None:
                    async with self.lock:
                        await self.pubsub.unsubscribe(events.ride_channel(ride_id))
            case "driver.location":
                await self.driver_location(message)
            case other:
                await _send(self.ws, "error", code="bad_request", message=f"Unsupported: {other}")

    async def subscribe(self, raw_id: object) -> None:
        ride_id = _uuid(raw_id)
        if ride_id is None:
            await _send(self.ws, "error", code="bad_request", message="ride_id must be a UUID")
            return
        async with get_sessionmaker()() as session:
            ride = await rides.get_ride(session, ride_id)
        allowed = ride is not None and (
            self.principal.sub in (ride.passenger_id, ride.driver_id)
            or self.principal.has_role(Role.ADMIN)
        )
        if not allowed:
            await _send(self.ws, "error", code="forbidden", message="Not your ride")
            return
        async with self.lock:
            await self.pubsub.subscribe(events.ride_channel(ride_id))
        await _send(self.ws, "subscribed", ride_id=str(ride_id))

    async def _driver_context(self) -> DriverContext:
        ctx = self.driver_context
        if ctx is not None and time.monotonic() - ctx.loaded_at < DRIVER_CONTEXT_TTL_S:
            return ctx
        async with get_sessionmaker()() as session:
            profile = await session.get(DriverProfile, self.principal.sub)
            ok = profile is not None and profile.status == DriverStatus.APPROVED and profile.online
            ride = await dispatch.active_ride_of(session, self.principal.sub) if ok else None
            target = None
            if ride is not None:
                target = (
                    rides.pickup_point(ride)
                    if ride.status in BEFORE_PICKUP
                    else rides.destination_point(ride)
                )
            ctx = DriverContext(
                profile_ok=ok,
                region_id=profile.region_id if profile else None,
                ride_id=ride.id if ride else None,
                target=target,
                loaded_at=time.monotonic(),
            )
        self.driver_context = ctx
        return ctx

    async def driver_location(self, message: dict[str, Any]) -> None:
        if not self.principal.has_role(Role.DRIVER):
            await _send(self.ws, "error", code="forbidden", message="Drivers only")
            return
        try:
            point = GeoPoint.model_validate(message.get("location"))
        except ValidationError:
            await _send(self.ws, "error", code="bad_request", message="Invalid location")
            return
        heading = message.get("heading")
        heading = float(heading) if isinstance(heading, int | float) else None
        ctx = await self._driver_context()
        if not ctx.profile_ok or ctx.region_id is None:
            await _send(self.ws, "error", code="forbidden", message="Go online first")
            return
        await presence.update_location(ctx.region_id, self.principal.sub, point, heading)
        if ctx.ride_id is not None and await presence.throttle(
            f"ride-location:{ctx.ride_id}", LOCATION_BROADCAST_EVERY_S
        ):
            eta = None
            if ctx.target is not None:
                eta = dispatch.eta_from_distance(rides.distance_m(point, ctx.target))
            await events.publish(
                events.ride_channel(ctx.ride_id),
                {
                    "type": "ride.driver_location",
                    "ride_id": str(ctx.ride_id),
                    "location": point.model_dump(),
                    "heading": heading,
                    "eta_s": eta,
                    "at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                },
            )


def _uuid(value: object) -> uuid.UUID | None:
    try:
        return uuid.UUID(str(value))
    except ValueError:
        return None


@router.websocket("/ws")
async def websocket_endpoint(ws: WebSocket) -> None:
    await ws.accept()
    principal = await _authenticate(ws)
    if principal is None:
        await _send(ws, "error", code="unauthorized", message="Send {type: auth, token} first")
        await ws.close(code=status.WS_1008_POLICY_VIOLATION)
        return
    await _send(ws, "auth_ok", user_id=principal.sub, roles=sorted(principal.roles))
    try:
        await Connection(ws, principal).run()
    except WebSocketDisconnect:
        return

"""WebSocket endpoint `/ws` — protocol described in docs/ws-protocol.md.

Implemented now: authentication handshake and ping/pong.
To do (Backend agent): subscribe/unsubscribe to `ride:{id}`, driver location updates,
offers, Redis pub/sub fan-out between API replicas.
"""

import asyncio
import json
from typing import Any

from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status

from app.core.security import Principal, TokenError, get_token_verifier

router = APIRouter()

AUTH_TIMEOUT_S = 10


async def _send(ws: WebSocket, type_: str, **payload: Any) -> None:
    await ws.send_text(json.dumps({"type": type_, **payload}))


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
        while True:
            raw = await ws.receive_text()
            try:
                message = json.loads(raw)
            except json.JSONDecodeError:
                await _send(ws, "error", code="bad_request", message="Invalid JSON")
                continue
            msg_type = message.get("type") if isinstance(message, dict) else None
            if msg_type == "ping":
                await _send(ws, "pong")
            else:
                await _send(ws, "error", code="not_implemented", message=f"Unsupported: {msg_type}")
    except WebSocketDisconnect:
        return

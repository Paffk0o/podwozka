import pytest
from starlette.testclient import TestClient
from starlette.websockets import WebSocketDisconnect

from app.main import app
from tests.conftest import TokenFactory


def test_ws_auth_handshake_and_ping(make_token: TokenFactory) -> None:
    with TestClient(app) as tc, tc.websocket_connect("/ws") as ws:
        ws.send_json({"type": "auth", "token": make_token(sub="ws-user")})
        assert ws.receive_json() == {
            "type": "auth_ok",
            "user_id": "ws-user",
            "roles": ["passenger"],
        }
        ws.send_json({"type": "ping"})
        assert ws.receive_json() == {"type": "pong"}


def test_ws_rejects_missing_auth() -> None:
    with TestClient(app) as tc, tc.websocket_connect("/ws") as ws:
        ws.send_json({"type": "ping"})
        assert ws.receive_json()["code"] == "unauthorized"
        with pytest.raises(WebSocketDisconnect) as exc:
            ws.receive_json()
        assert exc.value.code == 1008


def test_ws_rejects_invalid_token(make_token: TokenFactory) -> None:
    with TestClient(app) as tc, tc.websocket_connect("/ws") as ws:
        ws.send_json({"type": "auth", "token": make_token(audience="other")})
        assert ws.receive_json()["code"] == "unauthorized"

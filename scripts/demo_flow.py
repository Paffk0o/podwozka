"""End-to-end demo of a cash ride through the real API (no shortcuts into the database).

    docker compose up -d
    uv run --project backend python scripts/demo_flow.py

Uses local test users and the `dev-cli` Keycloak client (password grant, local only):
1. driver application in gmina Wieliczka: vehicle, 4 documents uploaded to Azurite via SAS,
   submit -> admin approves (driver role via Keycloak Admin API) — only on the first run;
2. driver goes online and sends positions over the WebSocket (Redis GEO);
3. passenger: quote -> cash order -> follows the ride over the WebSocket;
4. driver: offer -> accept -> depart / arrived / start / complete -> cash collected;
5. ratings both ways -> driver's earnings for today.

Re-runnable: leftovers of an interrupted run are finished or cancelled first.
Exit code 0 = the whole scenario passed.
"""

import asyncio
import io
import json
import os
import sys
import time
from datetime import date
from typing import Any

import httpx
from websockets.asyncio.client import ClientConnection, connect

API = os.environ.get("DEMO_API", "http://localhost:8000")
WS = API.replace("http", "ws", 1) + "/ws"
KEYCLOAK = os.environ.get("DEMO_KEYCLOAK", "http://localhost:8080")
# Password of the local test users from infra/keycloak (README) — not a secret.
PASSWORD = os.environ.get("DEMO_PASSWORD", "Test1234!")

PICKUP = {"location": {"lat": 49.9837, "lng": 20.0553}, "address": "Rynek Górny 1, Wieliczka"}
DESTINATION = {"location": {"lat": 50.0617, "lng": 19.9373}, "address": "Rynek Główny, Kraków"}
DRIVER_START = {"lat": 49.9905, "lng": 20.0640}  # ~1 km from the pickup, inside Wieliczka
DOCUMENTS = ("driving_license", "vehicle_registration", "insurance_oc", "driver_photo")
FINAL = {"completed", "cancelled_by_passenger", "cancelled_by_driver", "no_driver"}


class DemoError(Exception):
    pass


def zl(grosze: int) -> str:
    return f"{grosze / 100:.2f} zł"


def step(text: str) -> None:
    print(f"\n▶ {text}", flush=True)


def ok(text: str) -> None:
    print(f"  ✓ {text}", flush=True)


def expect(condition: bool, message: str) -> None:
    if not condition:
        raise DemoError(message)


def token(username: str) -> str:
    response = httpx.post(
        f"{KEYCLOAK}/realms/podwozka/protocol/openid-connect/token",
        data={
            "grant_type": "password",
            "client_id": "dev-cli",
            "username": username,
            "password": PASSWORD,
        },
    )
    if response.status_code != 200:
        raise DemoError(f"Keycloak login {username}: {response.status_code} {response.text}")
    access: str = response.json()["access_token"]
    return access


class User:
    def __init__(self, name: str, username: str) -> None:
        self.name = name
        self.username = username
        self.refresh()

    def refresh(self) -> None:
        """Access tokens live 5 min; the driver gets a fresh one after approval (new role)."""
        self.token = token(self.username)
        self.http = httpx.Client(
            base_url=API, headers={"Authorization": f"Bearer {self.token}"}, timeout=20
        )

    def call(self, method: str, path: str, expected: int | tuple[int, ...] = 200, **kw: Any) -> Any:
        response = self.http.request(method, path, **kw)
        codes = (expected,) if isinstance(expected, int) else expected
        if response.status_code not in codes:
            raise DemoError(
                f"{self.name}: {method} {path} -> {response.status_code} {response.text[:300]}"
            )
        return response.json() if response.content else None


async def ws_open(user: User) -> ClientConnection:
    ws = await connect(WS, proxy=None, open_timeout=10)
    await ws.send(json.dumps({"type": "auth", "token": user.token}))
    reply = json.loads(await asyncio.wait_for(ws.recv(), 10))
    expect(reply.get("type") == "auth_ok", f"{user.name}: WebSocket auth failed: {reply}")
    return ws


async def collect(ws: ClientConnection, into: list[dict[str, Any]]) -> None:
    """Background reader: keeps every message the server pushes."""
    try:
        async for raw in ws:
            into.append(json.loads(raw))
    except Exception:  # connection closed at the end of the demo
        return


async def wait_for(
    messages: list[dict[str, Any]], predicate: Any, what: str, seconds: float = 15
) -> dict[str, Any]:
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        for message in messages:
            if predicate(message):
                return message
        await asyncio.sleep(0.2)
    raise DemoError(f"Timed out waiting for {what}")


# --- steps ---


def profiles(passenger: User, driver: User, admin: User) -> None:
    step("Profile użytkowników (PUT /me)")
    passenger.call("PUT", "/me", json={"full_name": "Anna Pasażerka", "phone": "+48600100200"})
    driver.call("PUT", "/me", json={"full_name": "Jan Kierowca", "phone": "+48600100300"})
    admin.call("PUT", "/me", json={"full_name": "Admin Gminy"})
    ok("pasażer, kierowca i admin mają profile")


def region_id(user: User, name: str) -> str:
    regions = user.call("GET", "/regions")
    for region in regions:
        if region["name"] == name:
            return str(region["id"])
    raise DemoError(f"Region {name} not found — did the seed run? ({[r['name'] for r in regions]})")


def driver_onboarding(driver: User, admin: User, wieliczka: str) -> None:
    step("Kierowca: wniosek, dokumenty, zatwierdzenie")
    me = driver.http.get("/drivers/me")
    status = me.json()["status"] if me.status_code == 200 else None
    if status == "approved":
        ok("kierowca już zatwierdzony (poprzedni bieg) — pomijam wniosek")
        return
    if status in (None, "draft", "rejected"):
        driver.call(
            "PUT",
            "/drivers/me/application",
            json={
                "region_id": wieliczka,
                "vehicle": {
                    "make": "Skoda",
                    "model": "Octavia",
                    "color": "szary",
                    "plate": "KWI 12345",
                    "seats": 4,
                },
            },
        )
        ok("wniosek: Gmina Wieliczka, Skoda Octavia KWI12345")
        for doc_type in DOCUMENTS:
            content = f"demo {doc_type}".encode()
            slot = driver.call(
                "POST",
                "/drivers/me/documents",
                201,
                json={"type": doc_type, "content_type": "image/jpeg", "size_bytes": len(content)},
            )
            upload = httpx.put(
                slot["upload_url"], content=content, headers=slot["required_headers"]
            )
            expect(upload.status_code == 201, f"Azurite upload {doc_type}: {upload.status_code}")
            driver.call("POST", f"/drivers/me/documents/{slot['document_id']}/complete")
        ok("4 dokumenty wysłane bezpośrednio do Blob Storage (Azurite) linkami SAS")
        submitted = driver.call("POST", "/drivers/me/application/submit")
        expect(submitted["status"] == "pending", f"submit -> {submitted['status']}")
        ok("wniosek wysłany do weryfikacji (pending)")

    sub = driver.call("GET", "/me")["id"]
    pending = admin.call("GET", "/admin/drivers", params={"status": "pending"})
    if any(d["user_id"] == sub for d in pending["items"]):
        doc = admin.call("GET", f"/admin/drivers/{sub}")["documents"][0]
        view = admin.call("GET", f"/admin/drivers/{sub}/documents/{doc['id']}/view-url")
        expect(httpx.get(view["url"]).status_code == 200, "admin cannot open the document")
        ok("admin otwiera dokument linkiem tylko do odczytu")
    approved = admin.call("POST", f"/admin/drivers/{sub}/approve")
    expect(approved["status"] == "approved", f"approve -> {approved['status']}")
    driver.refresh()  # the token now carries the `driver` role from Keycloak
    ok("admin zatwierdził kierowcę — rola driver nadana w Keycloaku")


def clean_leftovers(passenger: User, driver: User) -> None:
    """A previous run may have stopped half-way: finish or cancel what is still open."""
    state = driver.call("GET", "/drivers/me/current")
    ride = state["active_ride"]
    if ride:
        actions = {
            "accepted": ["depart", "arrived", "start", "complete"],
            "driver_arriving": ["arrived", "start", "complete"],
            "arrived": ["start", "complete"],
            "in_progress": ["complete"],
        }[ride["status"]]
        for action in actions:
            driver.call("POST", f"/drivers/me/rides/{ride['id']}/actions", json={"action": action})
        ok(f"dokończono kurs z poprzedniego biegu ({ride['id'][:8]}…)")
    if state["pending_offer"]:
        driver.call("POST", f"/drivers/me/offers/{state['pending_offer']['id']}/decline", 204)
    active = passenger.call("GET", "/rides", params={"active": "true", "limit": 100})["items"]
    for leftover in active:
        if leftover["scheduled_at"] is None:
            passenger.call("POST", f"/rides/{leftover['id']}/cancel", (200, 409), json={})
            ok(f"anulowano niedokończone zamówienie pasażera ({leftover['id'][:8]}…)")


async def send_position(ws: ClientConnection, lat: float, lng: float) -> None:
    await ws.send(
        json.dumps(
            {
                "type": "driver.location",
                "location": {"lat": lat, "lng": lng},
                "heading": 270,
                "speed_mps": 11.0,
                "accuracy_m": 5,
            }
        )
    )


async def ride(passenger: User, driver: User) -> None:
    step("Kierowca online")
    driver.call("PUT", "/drivers/me/availability", json={"online": True})
    driver_ws = await ws_open(driver)
    driver_events: list[dict[str, Any]] = []
    driver_reader = asyncio.create_task(collect(driver_ws, driver_events))
    await send_position(driver_ws, **DRIVER_START)
    await asyncio.sleep(1)  # let the API store the position (Redis GEO)
    ok("online, pozycja wysłana przez WebSocket (~1 km od punktu odbioru)")

    step("Pasażer: wycena i zamówienie za gotówkę")
    quote = passenger.call(
        "POST", "/quotes", 201, json={"pickup": PICKUP, "destination": DESTINATION}
    )
    ok(
        f"wycena {quote['price'] / 100:.2f} zł · {quote['distance_m'] / 1000:.1f} km · "
        f"{quote['duration_s'] // 60} min · {quote['region_name']} (ważna 5 min)"
    )
    created = passenger.call(
        "POST",
        "/rides",
        201,
        json={"quote_id": quote["id"], "payment_method": "cash", "passenger_note": "Demo"},
    )
    ride_id = created["ride"]["id"]
    expect(
        created["ride"]["status"] == "dispatching",
        f"ride status {created['ride']['status']} — no driver found (is the worker running?)",
    )
    ok(f"zamówiono kurs {ride_id[:8]}… — dyspozycja szuka kierowcy")

    passenger_ws = await ws_open(passenger)
    passenger_events: list[dict[str, Any]] = []
    passenger_reader = asyncio.create_task(collect(passenger_ws, passenger_events))
    await passenger_ws.send(json.dumps({"type": "subscribe", "ride_id": ride_id}))
    await wait_for(passenger_events, lambda m: m["type"] == "subscribed", "subscription")
    ok("pasażer śledzi kurs przez WebSocket")

    step("Kierowca: oferta i przyjęcie")
    offer_event = await wait_for(
        driver_events,
        lambda m: m["type"] == "offer.new" and m["ride_id"] == ride_id,
        "offer.new",
    )
    offer = driver.call("GET", "/drivers/me/current")["pending_offer"]
    expect(offer is not None and offer["id"] == offer_event["offer_id"], "offer not in /current")
    ok(
        f"oferta przez WebSocket: odbiór za ~{offer['pickup_eta_s'] // 60 + 1} min, "
        f"pasażer {offer['ride']['passenger']['full_name']}"
    )
    accepted = driver.call("POST", f"/drivers/me/offers/{offer['id']}/accept")
    expect(accepted["status"] == "accepted", f"accept -> {accepted['status']}")
    await wait_for(
        passenger_events, lambda m: m["type"] == "ride.driver_assigned", "driver_assigned"
    )
    seen = passenger.call("GET", f"/rides/{ride_id}")
    ok(
        f"przyjęte — pasażer widzi: {seen['driver']['full_name']}, "
        f"{seen['driver']['vehicle']['make']} {seen['driver']['vehicle']['plate']}"
    )

    step("Kurs: dojazd, na miejscu, start, koniec")
    await driver_ws.send(json.dumps({"type": "subscribe", "ride_id": ride_id}))
    driver.call("POST", f"/drivers/me/rides/{ride_id}/actions", json={"action": "depart"})
    await asyncio.sleep(3.2)  # location broadcasts are throttled to one per 3 s
    await send_position(driver_ws, 49.9860, 20.0590)
    location = await wait_for(
        passenger_events, lambda m: m["type"] == "ride.driver_location", "driver location"
    )
    ok(f"pasażer widzi kierowcę na mapie, ETA {location['eta_s']} s")
    for action, label in (
        ("arrived", "na miejscu"),
        ("start", "w trasie"),
        ("complete", "zakończony"),
    ):
        updated = driver.call(
            "POST", f"/drivers/me/rides/{ride_id}/actions", json={"action": action}
        )
        ok(f"{label} ({updated['status']})")

    step("Gotówka i oceny")
    paid = driver.call("POST", f"/drivers/me/rides/{ride_id}/cash-collected")
    expect(paid["payment_status"] == "cash_collected", "cash not confirmed")
    ok(f"kierowca potwierdził gotówkę: {paid['price'] / 100:.2f} zł")
    driver.call("POST", f"/drivers/me/rides/{ride_id}/rating", 204, json={"stars": 5})
    passenger.call(
        "POST", f"/rides/{ride_id}/rating", 204, json={"stars": 5, "comment": "Punktualnie"}
    )
    ok("oceny wystawione w obie strony")

    try:
        await wait_for(
            passenger_events,
            lambda m: m["type"] == "ride.status" and m["status"] == "completed",
            "status completed over WebSocket",
            seconds=10,
        )
    finally:
        statuses = [m["status"] for m in passenger_events if m["type"] == "ride.status"]
        print(f"  · statusy odebrane przez pasażera: {statuses}", flush=True)
    ok("statusy na żywo u pasażera: " + " → ".join(statuses))
    await wait_for(passenger_events, lambda m: m["type"] == "ride.payment", "ride.payment")

    step("Zarobki kierowcy (dziś)")
    today = date.today().isoformat()
    earnings = driver.call(
        "GET", "/drivers/me/earnings", params={"date_from": today, "date_to": today}
    )
    expect(any(i["ride_id"] == ride_id for i in earnings["items"]), "ride missing in earnings")
    entry = next(i for i in earnings["items"] if i["ride_id"] == ride_id)
    ok(
        f"ten kurs: brutto {zl(entry['gross'])}, prowizja {zl(entry['commission'])}, "
        f"netto {zl(entry['net'])}"
    )
    ok(
        f"dziś razem: {earnings['rides_count']} kurs(y), gotówka {zl(earnings['cash_collected'])}, "
        f"prowizja do rozliczenia {zl(earnings['commission_due_from_cash'])}"
    )

    final = passenger.call("GET", f"/rides/{ride_id}")
    expect(
        final["status"] == "completed" and final["payment_status"] == "cash_collected",
        f"final ride: {final['status']} / {final['payment_status']}",
    )
    driver.call("PUT", "/drivers/me/availability", json={"online": False})
    for ws, reader in ((driver_ws, driver_reader), (passenger_ws, passenger_reader)):
        await ws.close()
        await reader


def main() -> int:
    started = time.monotonic()
    try:
        health = httpx.get(f"{API}/health", timeout=5)
        expect(health.status_code == 200, f"API {API} not healthy")
        passenger = User("pasażer", "pasazer@podwozka.test")
        driver = User("kierowca", "kierowca@podwozka.test")
        admin = User("admin", "admin@podwozka.test")
        profiles(passenger, driver, admin)
        driver_onboarding(driver, admin, region_id(passenger, "Gmina Wieliczka"))
        clean_leftovers(passenger, driver)
        asyncio.run(ride(passenger, driver))
    except (DemoError, httpx.HTTPError, OSError, TimeoutError) as exc:
        print(f"\n✗ DEMO NIEUDANE: {exc}", file=sys.stderr)
        print(
            "  Czy działa `docker compose up -d` (api, worker, keycloak, azurite)?", file=sys.stderr
        )
        return 1
    print(f"\n✔ Demo zakończone powodzeniem w {time.monotonic() - started:.0f} s")
    return 0


if __name__ == "__main__":
    if isinstance(sys.stdout, io.TextIOWrapper):
        sys.stdout.reconfigure(encoding="utf-8")  # Windows consoles default to cp1250
        sys.stderr.reconfigure(encoding="utf-8")  # type: ignore[union-attr]
    sys.exit(main())

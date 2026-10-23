# Protokół WebSocket `/ws` (v1)

Kanał na żywo między aplikacjami a API: pozycja kierowcy, statusy kursu, oferty. REST (`openapi/openapi.json`) pozostaje źródłem prawdy — WebSocket tylko **powiadamia**. Po ponownym połączeniu aplikacja odświeża stan przez REST (`GET /rides/{id}`, `GET /drivers/me/current`).

- Adres: `wss://<api>/ws` (lokalnie `ws://localhost:8000/ws`)
- Format: JSON, każda wiadomość ma pole `type`.
- Czasy: ISO 8601 UTC. Współrzędne: `{"lat": .., "lng": ..}`.

Legenda: ✅ zaimplementowane · 🔜 do zrobienia (Agent Backend)

## 1. Uwierzytelnienie ✅

Token **nie** idzie w URL (trafiłby do logów). Pierwsza wiadomość po połączeniu, w ciągu 10 s:

```json
→ {"type": "auth", "token": "<access token z Keycloaka>"}
← {"type": "auth_ok", "user_id": "<sub>", "roles": ["passenger"]}
```

Błąd: `← {"type": "error", "code": "unauthorized", ...}` i zamknięcie z kodem **1008**.

Po wygaśnięciu tokenu serwer wysyła `{"type": "token_expired"}` i zamyka połączenie (🔜). Aplikacja odświeża token i łączy się ponownie.

## 2. Utrzymanie połączenia ✅

```json
→ {"type": "ping"}
← {"type": "pong"}
```

Aplikacja wysyła `ping` co 25 s. Brak `pong` przez 10 s → ponowne połączenie z backoffem (1, 2, 5, 10, 30 s).

## 3. Pasażer — śledzenie kursu 🔜

```json
→ {"type": "subscribe", "ride_id": "<uuid>"}
← {"type": "subscribed", "ride_id": "<uuid>"}
→ {"type": "unsubscribe", "ride_id": "<uuid>"}
```

Serwer sprawdza, że kurs należy do użytkownika (pasażer lub przypisany kierowca), inaczej `error` z kodem `forbidden`.

Zdarzenia:

```json
← {"type": "ride.status", "ride_id": "...", "status": "driver_arriving", "at": "2026-10-24T10:00:00Z"}
← {"type": "ride.driver_location", "ride_id": "...", "location": {"lat": 50.1, "lng": 19.9},
   "heading": 90, "eta_s": 240, "at": "..."}
← {"type": "ride.driver_assigned", "ride_id": "..."}      // pobierz szczegóły: GET /rides/{id}
← {"type": "ride.payment", "ride_id": "...", "payment_status": "paid"}
```

`ride.driver_location` najwyżej co 3 s.

## 4. Kierowca 🔜

Pozycja (tylko gdy online; co 3–5 s w ruchu, co 15–30 s na postoju):

```json
→ {"type": "driver.location", "location": {"lat": 50.1, "lng": 19.9}, "heading": 90,
   "speed_mps": 12.5, "accuracy_m": 8, "at": "..."}
```

Serwer: `GEOADD drivers:online:{region_id}`, a jeśli kierowca ma aktywny kurs — publikacja `ride.driver_location` na kanale `ride:{id}`.

Oferty i zmiany:

```json
← {"type": "offer.new", "offer_id": "...", "ride_id": "...", "expires_at": "..."}   // szczegóły: GET /drivers/me/current
← {"type": "offer.expired", "offer_id": "..."}
← {"type": "ride.status", "ride_id": "...", "status": "cancelled_by_passenger", "at": "..."}
← {"type": "board.updated", "region_id": "..."}   // giełda rezerwacji się zmieniła
```

Akceptacja/odrzucenie oferty zawsze przez REST (`POST /drivers/me/offers/{id}/accept`).

## 5. Błędy

```json
← {"type": "error", "code": "bad_request | unauthorized | forbidden | not_found | not_implemented", "message": "..."}
```

## 6. Skalowanie (backend)

Każda replika API trzyma własne połączenia. Zdarzenia idą przez Redis pub/sub (`ride:{id}`, `user:{sub}`), a każda replika przekazuje je do swoich połączeń. Push FCM jest wysyłany równolegle dla zdarzeń ważnych przy zamkniętej aplikacji (`offer.new`, `ride.driver_assigned`, `arrived`).

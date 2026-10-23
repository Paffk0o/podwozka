# AGENTS.md — Backend (FastAPI)

Przeczytaj najpierw `/AGENTS.md`. Pracujesz tylko w `backend/` (+ eksport do `openapi/`).

## Komendy

```bash
uv sync                                   # zależności
docker compose up -d db redis keycloak    # z katalogu głównego repo
uv run alembic upgrade head
uv run fastapi dev app/main.py            # http://localhost:8000/docs
uv run pytest                             # testy (wymagają Postgresa z PostGIS na localhost:5432)
uv run ruff check . && uv run ruff format --check . && uv run mypy app
uv run python scripts/export_openapi.py   # po zmianie kontraktu (potem ../scripts/gen-api-client.sh)
```

Testy używają bazy `podwozka_test` (`DATABASE_URL` w `tests/conftest.py`). Lokalnie: `createdb -h localhost -U podwozka podwozka_test` albo `docker compose exec db createdb -U podwozka podwozka_test`.

Token do ręcznych testów (tylko lokalnie, klient `dev-cli`):

```bash
curl -s -X POST http://localhost:8080/realms/podwozka/protocol/openid-connect/token \
  -d grant_type=password -d client_id=dev-cli \
  -d username=kierowca@podwozka.test -d 'password=Test1234!' | jq -r .access_token
```

## Architektura: modularny monolit

```
app/
  core/        config, db (async SQLAlchemy), security (JWT/role), errors
  common/      wspólne schematy (GeoPoint, Place, Page, MoneyGrosze)
  modules/
    users/     profil, telefon, tokeny push        ✅ /me (GET, PUT) zaimplementowane
    regions/   gminy (PostGIS)                      🔜
    pricing/   cenniki, wyceny                      🔜
    places/    proxy do Google Places/Geocoding     🔜
    rides/     kursy pasażera, maszyna stanów       🔜
    drivers/   wnioski, dokumenty, praca kierowcy   🔜
    admin/     endpointy panelu                     🔜
    payments/  Stripe, webhooki                     🔜
    realtime/  WebSocket /ws                        ✅ auth + ping; reszta 🔜
  models.py    rejestr modeli dla Alembica (dopisuj nowe!)
```

Każdy moduł: `router.py` (HTTP, cienki) → `service.py` (logika, testowalna) → `models.py` (ORM). `schemas.py` = kontrakt API. Moduły rozmawiają przez funkcje serwisów, nie przez cudze tabele.

Endpointy z kontraktu v1 już istnieją jako stuby (`not_implemented()` → 501). Implementując: zastąp ciało, NIE zmieniaj sygnatury/schematu bez PR kontraktu.

## Zasady domenowe (nie łam ich)

- **Pieniądze**: zawsze `int` w groszach. Nigdy float.
- **Geometria**: PostGIS, SRID 4326. Punkt odbioru → region przez `ST_Contains(region.area, point)`. W API zawsze `{"lat", "lng"}`; uwaga — PostGIS/GeoJSON mają kolejność `lng, lat`.
- **Statusy kursu**: przejścia tylko przez jedną funkcję w `rides/service.py` z tabelą dozwolonych przejść; każde przejście zapisuje wiersz w `ride_events`. Testy jednostkowe dla każdego przejścia (dozwolonego i niedozwolonego).
- **Współbieżność**: przyjęcie oferty/rezerwacji przez dwóch kierowców naraz → tylko jeden wygrywa (`SELECT ... FOR UPDATE` albo warunkowy `UPDATE ... WHERE status = ...`). Test na to.
- **Kierowca**: rola `driver` w tokenie + `driver_profile.status == approved` w bazie (zawieszenie działa od razu).
- **Płatności**: stan płatności zmienia wyłącznie webhook Stripe (weryfikacja podpisu, idempotencja po `event.id`). Karta: `capture_method=manual`, capture po zakończeniu. BLIK: brak manual capture → pobranie przy zamówieniu, zwrot przy anulowaniu bez winy pasażera.
- **Wycena**: ważna 5 min, kurs zapamiętuje `tariff_id`. Cena liczona wyłącznie na serwerze.
- **Integracje** (Google, Stripe, FCM, SMSAPI, Blob) za interfejsami (`typing.Protocol`) w module; w testach fake, nigdy prawdziwe wywołania sieciowe.
- **Redis** = dane ulotne (pozycje online, pub/sub, kolejka). Stan kursu zawsze w PostgreSQL.
- **Czas**: `datetime` zawsze z timezone (UTC w bazie).

## Migracje

`uv run alembic revision --autogenerate -m "opis"` → PRZECZYTAJ wygenerowany plik (autogenerate myli się przy typach PostGIS i enumach) → `uv run alembic upgrade head` → `uv run alembic check` (brak różnic).

## Testy

- pytest + httpx `AsyncClient`, tokeny podpisywane lokalnym kluczem (`make_token` w `conftest.py`).
- Testuj reguły biznesowe i uprawnienia (kto może co), nie tylko „200 OK”.
- Quality Gate: pokrycie nowego kodu ≥ 80%.

## Zależności do dodania przy implementacji (z zarysu)

celery 5.6, stripe 16, firebase-admin 7.7, azure-storage-blob 12.31. Dodawaj przez `uv add`, w PR z funkcją, która ich używa.

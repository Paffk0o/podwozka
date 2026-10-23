# AGENTS.md — zasady dla agentów AI (cały projekt)

Czytaj ten plik i plik `AGENTS.md` w katalogu, w którym pracujesz, ZANIM cokolwiek zmienisz.

## Projekt

Podwózka — przewozy na żądanie dla małych gmin (pasażer, kierowca, admin). Zarys: `docs/zarys-projektu.md`. Plan: `docs/plan-tygodnia.md`.

## Obszary i właściciele (nie wychodź poza swój obszar)

| Obszar | Katalogi | Agent |
|---|---|---|
| Backend | `backend/`, `openapi/` (generowany z backendu) | Agent Backend |
| Mobile | `mobile/apps/passenger`, `mobile/apps/driver`, `mobile/packages/core`, `mobile/packages/api_client` (generowany) | Agent Mobile |
| DevOps + panel admina | `infra/`, `.github/`, `docker-compose.yml`, `sonar-project.properties`, `mobile/apps/admin_web` | Agent DevOps |

Jeśli zadanie wymaga zmiany w cudzym obszarze — NIE rób jej. Opisz potrzebną zmianę w opisie PR w sekcji „Potrzebne od innych”.

## Kontrakt API (najważniejsza zasada)

- Źródło prawdy: `openapi/openapi.json`, generowany z kodu FastAPI (`backend/scripts/export_openapi.py`).
- Protokół WebSocket: `docs/ws-protocol.md`.
- Zmiana kontraktu = osobny, mały PR, który: zmienia schematy w backendzie, eksportuje `openapi.json`, regeneruje `mobile/packages/api_client` (`scripts/gen-api-client.sh`). CI odrzuca PR, w którym te trzy rzeczy się rozjeżdżają.
- Nie zmieniaj nazw istniejących pól ani ścieżek bez uzgodnienia — dodawaj nowe, stare oznaczaj jako `deprecated`.

## Wersje (nie zmieniaj bez powodu, nie zgaduj API z pamięci)

Twoja wiedza o tych bibliotekach może być starsza niż te wersje. Jeśli nie znasz API danej wersji — sprawdź dokumentację/changelog, nie zgaduj.

- Python 3.14, FastAPI 0.143, Pydantic 2.14, SQLAlchemy 2.1 (async), Alembic 1.20, Celery 5.6, redis-py 8.1, PyJWT 2.15, uv 0.13, ruff 0.17, pytest 9.1
- PostgreSQL 18 + PostGIS 3.6, Redis 8.10, Keycloak 26.8
- Flutter 3.47.1 / Dart 3.13, flutter_riverpod 3.4, go_router 18, dio 5.11, flutter_appauth 12.1, flutter_secure_storage 11.2, google_maps_flutter 2.18, geolocator 14.1, flutter_stripe 14.1, firebase_messaging 16.7, web_socket_channel 3.0

Nowa zależność: sprawdź, że istnieje na PyPI / pub.dev i jest stabilna (bez beta/rc), napisz w PR, po co jest.

## Definicja „gotowe” dla każdego PR

1. Mały zakres (jedna funkcja), opis: co, dlaczego, jak przetestować.
2. Testy dla logiki biznesowej (nie pisz testów „pod pokrycie”, które niczego nie sprawdzają).
3. Lint i testy przechodzą lokalnie (komendy w `AGENTS.md` obszaru).
4. Brak sekretów w kodzie (klucze tylko przez zmienne środowiskowe / GitHub Secrets).
5. Wpis w `docs/ai-log.md` przy większych funkcjach (co zrobił agent, co poprawił człowiek).

## Rzeczy zakazane

- Wyłączanie weryfikacji tokenów, TLS lub testów „żeby działało”.
- Ufanie aplikacji w sprawie płatności — stan płatności ustala wyłącznie webhook Stripe.
- Commitowanie plików `.env`, kluczy, `google-services.json`, `GoogleService-Info.plist`.
- Edytowanie wygenerowanego kodu (`mobile/packages/api_client`, `*.g.dart`) ręcznie.

## Język

Kod, nazwy, komentarze: angielski. Teksty w UI, dokumentacja, opisy PR: polski.

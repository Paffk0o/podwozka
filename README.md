# Podwózka

Mobilna platforma przewozów na żądanie dla małych miejscowości i gmin (projekt na przedmiot *Technologie Usługowe i Mobilne*).

- **Mobile:** Flutter 3.47 — aplikacje Pasażer, Kierowca i panel admina (Flutter Web) — katalog `mobile/`
- **Backend:** Python 3.14, FastAPI, SQLAlchemy 2.1, PostgreSQL 18 + PostGIS, Redis, Celery — katalog `backend/`
- **Tożsamość:** Keycloak 26.8 (OIDC + PKCE), administratorzy przez Microsoft Entra ID — katalog `infra/keycloak/`
- **DevOps:** Docker Compose, GitHub Actions, SonarQube Cloud, Azure Container Apps — katalogi `infra/` i `.github/`

Pełny zarys: [`docs/zarys-projektu.md`](docs/zarys-projektu.md) · Plan tygodnia: [`docs/plan-tygodnia.md`](docs/plan-tygodnia.md)

## Szybki start (lokalnie)

Wymagane: Git, Docker Desktop (lub Docker Engine + Compose v2). Dla backendu: [uv](https://docs.astral.sh/uv/). Dla aplikacji: Flutter 3.47.1.

```bash
cp .env.example .env          # Windows (cmd): copy .env.example .env
docker compose up -d
```

To wszystko — bez kluczy i ręcznych kroków. Pierwszy start trwa ok. 1,5 min (budowa obrazu, start Keycloaka). `docker compose up -d` stawia i przygotowuje:

- **db** — PostgreSQL 18 + PostGIS (bazy `podwozka`, `keycloak`, `podwozka_test`),
- **redis**, **keycloak** (realm `podwozka` importowany z `infra/keycloak/`), **mailpit**, **azurite** (emulator Azure Blob Storage na dokumenty kierowców),
- **migrate** — przy każdym starcie: migracje Alembica, potem dane demo (gminy Wieliczka i Niepołomice z różnymi cennikami). Seed jest idempotentny — kolejne starty niczego nie duplikują,
- **api** (FastAPI), **worker** i **beat** (Celery: limit 20 s na ofertę, rezerwacje, push).

| Usługa | Adres | Dane logowania |
|---|---|---|
| API (Swagger) | http://localhost:8000/docs | — |
| Keycloak | http://localhost:8080 | konsola: `admin` / `admin` |
| Mailpit (podgląd maili) | http://localhost:8025 | — |
| Azurite (Blob) | http://localhost:10000 | konto deweloperskie `devstoreaccount1` |

Bez kluczy Google adresy idą przez Nominatim, a wycena liczy trasę po prostej. Push FCM bez klucza jest tylko logowany przez workera. Opcjonalne klucze: `.env.example`, `secrets/README.md`.

Reset do stanu „po sklonowaniu” (baza, realm, pliki): `docker compose down -v`.

**Token do Swaggera** (przycisk *Authorize*), tylko lokalnie:

```bash
curl -s -X POST http://localhost:8080/realms/podwozka/protocol/openid-connect/token   -d grant_type=password -d client_id=dev-cli   -d username=pasazer@podwozka.test -d 'password=Test1234!'
```

Użytkownicy testowi w realmie `podwozka` (hasło dla wszystkich: `Test1234!`):

| Login | Role |
|---|---|
| `pasazer@podwozka.test` | passenger |
| `kierowca@podwozka.test` | passenger, driver |
| `admin@podwozka.test` | admin |

### Demo end-to-end (kurs za gotówkę)

Po `docker compose up -d`:

```bash
uv run --project backend python scripts/demo_flow.py
```

Skrypt przechodzi cały scenariusz przez prawdziwe API (tokeny z klienta `dev-cli`, bez skrótów do bazy):

1. kierowca składa wniosek w gminie Wieliczka i wysyła 4 dokumenty do Azurite linkami SAS;
2. admin podgląda dokument i zatwierdza kierowcę (rola `driver` nadana przez Keycloak Admin API);
3. kierowca przechodzi online i wysyła pozycję przez WebSocket;
4. pasażer robi wycenę i zamawia kurs za gotówkę, a potem śledzi go przez WebSocket;
5. kierowca dostaje ofertę, przyjmuje ją, wykonuje dojazd → na miejscu → start → koniec i potwierdza gotówkę;
6. obie strony wystawiają oceny, a na końcu skrypt sprawdza zarobki kierowcy.

Trwa ok. 10 s. Można go uruchamiać wielokrotnie: wniosek kierowcy idzie tylko przy pierwszym biegu, a niedokończony kurs z przerwanego biegu jest domykany. Kod wyjścia 0 oznacza, że cały scenariusz przeszedł.

### Backend bez Dockera

```bash
docker compose up -d db redis keycloak azurite
cd backend
uv sync
uv run alembic upgrade head && uv run python scripts/seed.py
uv run fastapi dev app/main.py
uv run pytest                 # baza podwozka_test istnieje od pierwszego startu db
```

### Aplikacje Flutter

Patrz [`mobile/README.md`](mobile/README.md) — przy pierwszym uruchomieniu trzeba jednorazowo wygenerować katalogi platform (`flutter create`).

## Struktura

```
backend/        FastAPI (modularny monolit), Alembic, testy
mobile/         Flutter pub workspace: apps/passenger, apps/driver, apps/admin_web, packages/core, packages/api_client
infra/          Keycloak (realm jako kod), Azure
openapi/        openapi.json — kontrakt API (źródło prawdy dla klienta Dart)
docs/           zarys, plan, specyfikacje funkcji, protokół WebSocket, dziennik pracy z AI
.github/        CI/CD
```

## Zasady pracy

1. Każda zmiana przez PR do `main`, wymagane zielone CI i 1 review.
2. Kontrakt API zmieniamy tylko przez PR, który aktualizuje `openapi/openapi.json` i regeneruje `mobile/packages/api_client`.
3. Kod pisany z AI — zasady dla agentów są w plikach `AGENTS.md` (root i każdy obszar).

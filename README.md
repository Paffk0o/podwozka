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
cp .env.example .env
docker compose up -d          # Postgres+PostGIS, Redis, Keycloak, Mailpit, API
```

| Usługa | Adres | Dane logowania |
|---|---|---|
| API (Swagger) | http://localhost:8000/docs | — |
| Keycloak | http://localhost:8080 | konsola: `admin` / `admin` |
| Mailpit (podgląd maili) | http://localhost:8025 | — |

Użytkownicy testowi w realmie `podwozka` (hasło dla wszystkich: `Test1234!`):

| Login | Role |
|---|---|
| `pasazer@podwozka.test` | passenger |
| `kierowca@podwozka.test` | passenger, driver |
| `admin@podwozka.test` | admin |

### Backend bez Dockera

```bash
docker compose up -d db redis keycloak
cd backend
uv sync
uv run alembic upgrade head
uv run fastapi dev app/main.py
uv run pytest
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

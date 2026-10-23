# AGENTS.md — DevOps (infra, CI/CD, Keycloak, panel admina)

Przeczytaj najpierw `/AGENTS.md`. Twój obszar: `infra/`, `.github/`, `docker-compose.yml`, `sonar-project.properties`, `mobile/apps/admin_web`.

## Keycloak

- Realm jako kod: `infra/keycloak/realm-podwozka.json` (import przy starcie `--import-realm`, strategia IGNORE_EXISTING → po zmianie pliku: `docker compose down -v && docker compose up -d`).
- Zawartość: role `passenger` (domyślna), `driver`, `admin`; klienci publiczni z PKCE `passenger-app`, `driver-app`, `admin-panel`; poufny `podwozka-backend` (konto serwisowe: manage/view/query-users); mapper audience `podwozka-api`.
- **Tylko lokalnie** (usuń/podmień przy staging): klient `dev-cli` (password grant), użytkownicy testowi, sekret `dev-backend-secret`, SMTP `mailpit`. Na staging przygotuj osobny wariant realmu (np. skrypt, który wycina te elementy i wstawia sekrety z env) — nie commituj prawdziwych sekretów.
- Entra ID (do zrobienia): Identity Provider `entra` (OIDC, tenant z Azure for Students), mapper grupa `Podwozka-Admins` → rola `admin`, dla klienta `admin-panel` browser flow z samym „Identity Provider Redirector” → `entra`. Szczegóły: `docs/zarys-projektu.md` §5.3.
- Na Azure: obraz z `kc.sh build` (postgres, health), start `--optimized`, min. 1 replika, ~1,25 GB RAM.

## Lokalne środowisko

`docker compose up -d` → db (PostGIS 18), redis 8.10, keycloak 26.8, mailpit, migrate (Alembic), api. Healthchecki muszą przechodzić; `docker compose ps` bez `unhealthy`.

## CI/CD (GitHub Actions)

- `backend.yml`: ruff, mypy, pytest z usługami Postgres+PostGIS i Redis, pokrycie XML.
- `mobile.yml`: format, analyze, test z pokryciem (lcov) dla pakietów i aplikacji.
- `contract.yml`: eksport OpenAPI + porównanie z commitem (rozjazd = błąd).
- `sonar.yml`: analiza SonarQube Cloud (Python + Dart), Quality Gate jako wymagany status.
- Do zrobienia: deploy staging na Azure Container Apps (logowanie OIDC, bez haseł), ACA Job z migracjami, Fastlane → Firebase App Distribution / TestFlight.

Sekrety wyłącznie w GitHub Secrets / Azure. Akcje przypinaj do wersji głównej (`@v4`) lub SHA.

## Panel admina (`mobile/apps/admin_web`, Flutter Web)

Używa `packages/core` (logowanie PKCE przez klienta `admin-panel`) i `packages/api_client` (tag `admin`). Ekrany: wnioski kierowców (podgląd dokumentów przez `view-url`, zatwierdź/odrzuć), regiony (import GeoJSON granicy gminy), cenniki (wersje), kursy (filtry). Zasady Fluttera: `mobile/AGENTS.md`.

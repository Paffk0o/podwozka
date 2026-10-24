# Podwózka — aplikacje Flutter

Pub workspace: jedno `flutter pub get` w tym katalogu rozwiązuje zależności dla wszystkich pakietów.

```
apps/passenger      aplikacja pasażera (Android/iOS)
apps/driver         aplikacja kierowcy (Android/iOS)
apps/admin_web      panel admina (Flutter Web) — dodaje Agent DevOps
packages/core       logowanie (Keycloak, PKCE), Dio z tokenem, router, motyw
packages/api_client klient API GENEROWANY z openapi/openapi.json (nie edytować ręcznie)
```

## Pierwsze uruchomienie (jednorazowo)

Wymagane: Flutter **3.47.1**, Android Studio, na Macu Xcode. Sprawdź: `flutter doctor`.

```bash
cd mobile
./scripts/setup_platforms.sh      # generuje android/ i ios/ + konfiguruje logowanie
cd .. && ./scripts/gen-api-client.sh   # generuje packages/api_client (wymaga Dockera)
```

Oba wyniki commitujemy (to jednorazowa konfiguracja, potem zwykła praca).

**Bez lokalnego Fluttera/Dockera:** wypchnij gałąź o nazwie `regen/<coś>` — workflow „Regeneracja klienta API” wygeneruje klienta, uruchomi `dart format`, zacommituje wynik na tę gałąź i pokaże błędy `dart analyze` / `flutter test` jako adnotacje w zakładce Actions. Uwaga: commit bota nie uruchamia CI — po nim wypchnij dowolny commit albo otwórz PR.

## Uruchomienie na emulatorze / telefonie

1. Backend lokalnie: `docker compose up -d` w katalogu głównym.
2. **Android** (emulator lub telefon po USB) — przekieruj porty, żeby `localhost` w telefonie trafiał do komputera:
   ```bash
   adb reverse tcp:8000 tcp:8000 && adb reverse tcp:8080 tcp:8080
   ```
   **iOS Simulator** widzi `localhost` komputera bez dodatkowych kroków.
3. Uruchom:
   ```bash
   cd apps/passenger && flutter run
   cd apps/driver && flutter run
   ```
4. Zaloguj się: `pasazer@podwozka.test` / `Test1234!` (kierowca: `kierowca@podwozka.test`). Można też założyć konto — mail weryfikacyjny zobaczysz w Mailpit: http://localhost:8025.

Inny backend (np. staging):

```bash
flutter run --dart-define=API_BASE_URL=https://... --dart-define=OIDC_ISSUER=https://.../realms/podwozka --dart-define=ALLOW_INSECURE_HTTP=false
```

## Testy i analiza

```bash
cd mobile
dart format --set-exit-if-changed .
flutter analyze
(cd packages/core && flutter test)
(cd apps/passenger && flutter test)
(cd apps/driver && flutter test)
```

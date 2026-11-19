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
# Windows (Git Bash): PYTHON=python ./scripts/setup_platforms.sh
# (foldery android/ i ios/ są już w repo — skrypt potrzebny tylko przy ich odtwarzaniu)
cd .. && ./scripts/gen-api-client.sh   # generuje packages/api_client (wymaga Dockera)
```

Oba wyniki commitujemy (to jednorazowa konfiguracja, potem zwykła praca).

**Bez lokalnego Fluttera/Dockera:** wypchnij gałąź o nazwie `regen/<coś>` — workflow „Regeneracja klienta API” wygeneruje klienta, uruchomi `dart format`, zacommituje wynik na tę gałąź i pokaże błędy `dart analyze` / `flutter test` jako adnotacje w zakładce Actions. Uwaga: commit bota nie uruchamia CI — po nim wypchnij dowolny commit albo otwórz PR.

## Uruchomienie na emulatorze / telefonie

1. Backend lokalnie: `docker compose up -d` w katalogu głównym.
   **Emulator:** używaj obrazu **Android 16 (API 36)**, np. `Pixel_API_36` (Google Play, x86_64). Na podglądzie
   Androida 17 (API 37) logowanie nie wraca do aplikacji (`AppAuth: No stored state` w logcat) — system otwiera
   przekierowanie z Chrome'a w nowym zadaniu. Pierwszy build pobiera NDK; na Windows z nowym Android CLI:
   `"%LOCALAPPDATA%\Android\sdk\cmdline-tools\latest\bin\android.exe" sdk install ndk/28.2.13676358`.
   Na świeżym emulatorze najpierw otwórz raz Chrome i zamknij jego kreator powitalny — inaczej przerwie pierwsze logowanie.
2. **Android** (emulator lub telefon po USB) — przekieruj porty, żeby `localhost` w telefonie trafiał do komputera:
   ```bash
   adb reverse tcp:8000 tcp:8000 && adb reverse tcp:8080 tcp:8080
   adb reverse tcp:10000 tcp:10000   # Azurite — zdjęcia dokumentów we wniosku kierowcy
   ```
   Pozycję emulatora ustawisz poleceniem `adb emu geo fix 20.0553 49.9837` (Wieliczka, gmina z seeda).
   Na świeżym emulatorze włącz też *Ustawienia → Lokalizacja → Usługi lokalizacyjne → Dokładność lokalizacji
   Google*. Bez tej opcji usługi Google zgłaszają lokalizację jako wyłączoną i kierowca nie przejdzie online
   (aplikacja pokaże „Lokalizacja w telefonie jest wyłączona”). Na prawdziwych telefonach jest zwykle włączona.
   Dwa urządzenia naraz (test pasażer ↔ kierowca): przy każdym `adb` podawaj `-s emulator-5554` / `-s emulator-5556`,
   a `adb reverse` ustaw dla każdego osobno. Przebieg testu: [`docs/screenshots/README.md`](../docs/screenshots/README.md).
   **iOS Simulator** widzi `localhost` komputera bez dodatkowych kroków.
3. Uruchom:
   ```bash
   cd apps/passenger && flutter run
   cd apps/driver && flutter run
   ```
4. Zaloguj się: `pasazer@podwozka.test` / `Test1234!` (kierowca: `kierowca@podwozka.test` — już zatwierdzony; wniosek kierowcy sprawdzisz na nowym koncie). Można też założyć konto — mail weryfikacyjny zobaczysz w Mailpit: http://localhost:8025.

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

### Co sprawdzają testy

Bez prawdziwych pluginów i sieci — mapy, lokalizacja, WebSocket, Keycloak i API są za interfejsami, w testach fake'i. Testy widgetów używają motywu aplikacji (`podwozkaTheme`) i rozmiaru telefonu, żeby łapać błędy układu.

| Pakiet | Logika (jednostkowe) | Ekrany (widgetowe) |
|---|---|---|
| `packages/core` | klient WebSocket (auth, ping/pong, backoff 1–30 s, resubskrypcje, `token_expired`, wygasła sesja), parser zdarzeń, `driver.location`, formatowanie zł/czasu/odległości/dat, błędy API po polsku, telefon E.164, dekoder polyline, sesja OIDC | `ProfileGate` + formularz profilu, mapa (znaczniki, atrybucja, tap) |
| `apps/passenger` | zamawianie (pozycja/pinezka/wyszukiwarka, wycena, nieaktualne odpowiedzi, rezerwacje 30 min–14 dni, wygasła wycena), wyszukiwarka (debounce, token sesji), etapy kursu, kontroler kursu (restart, WS → REST, reconnect, rezerwacja przejmuje ekran, anulowanie, ocena), historia z paginacją | zamawianie z wyceną i „wkrótce” dla karty/BLIK, kurs po restarcie, anulowanie z powodem, szczegóły rezerwacji |
| `apps/driver` | reguły wniosku, wysyłka dokumentu przez SAS bez tokenu API, etapy kursu i nawigacja, odliczanie oferty, `LocationPublisher` (throttling, heartbeat), kontroler pracy (online, oferta → kurs → gotówka → ocena, anulowanie przez pasażera, reconnect), giełda, okresy zarobków | wniosek, oferta i panel kursu, przełącznik online z wyjaśnieniem, giełda, zarobki, wybór ekranu (wniosek / praca / zawieszony) |

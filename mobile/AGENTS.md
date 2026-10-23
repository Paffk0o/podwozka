# AGENTS.md — Mobile (Flutter)

Przeczytaj najpierw `/AGENTS.md`. Agent Mobile pracuje w `apps/passenger`, `apps/driver`, `packages/core`. Agent DevOps w `apps/admin_web`. `packages/api_client` jest generowany — nie edytuj.

## Komendy

```bash
cd mobile && flutter pub get
dart format --set-exit-if-changed . && flutter analyze
(cd packages/core && flutter test) ; (cd apps/passenger && flutter test) ; (cd apps/driver && flutter test)
../scripts/gen-api-client.sh   # z katalogu głównego: po zmianie openapi/openapi.json
```

## Wersje (SPRAWDZAJ API, nie zgaduj z pamięci)

Flutter 3.47.1 / Dart 3.13 · flutter_riverpod 3.4 · go_router 18 · dio 5.11 · flutter_appauth 12.1 · flutter_secure_storage 11.2 · google_maps_flutter 2.18 · geolocator 14.1 · url_launcher 6.3 · web_socket_channel 3.0 · flutter_stripe 14.1 · firebase_messaging 16.7 · sentry_flutter 10.0

Riverpod 3: `Notifier`/`AsyncNotifier` + `NotifierProvider`/`AsyncNotifierProvider`; jeden typ `Ref`; `AsyncValue.value` zwraca `null` zamiast rzucać; `StateProvider`/`StateNotifierProvider` tylko z `package:flutter_riverpod/legacy.dart` — NIE używaj ich w nowym kodzie. Bez code-gen (`riverpod_generator`) — piszemy providery ręcznie.

## Architektura

- **Wspólne rzeczy → `packages/core`**: logowanie, Dio, router (`createAuthRouter`), motyw, wspólne widgety (mapa, wybór adresu, karta kursu), klient WebSocket (`docs/ws-protocol.md`). Aplikacja = ekrany + nawigacja.
- **API**: wyłącznie przez wygenerowany `PodwozkaApi(dio: ref.watch(dioProvider))` z `podwozka_api`. Token dokłada `AuthInterceptor` — nie dodawaj nagłówków ręcznie. Kwoty z API są w groszach → formatuj `NumberFormat.currency(locale: 'pl_PL', symbol: 'zł')` po podzieleniu przez 100 (dodaj `intl`).
- **Stan**: Riverpod. Logika (np. walidacja zamówienia, maszyna stanów ekranu kursu) w providerach/klasach testowalnych bez widgetów. Widgety cienkie.
- **Struktura aplikacji**: `lib/features/<feature>/{data,providers,ui}` (np. `ordering`, `ride_tracking`, `history` w pasażerze; `availability`, `offers`, `active_ride`, `board`, `earnings`, `onboarding` u kierowcy).
- **Ekran po restarcie**: przy starcie stan z REST (`GET /rides?active=true`, `GET /drivers/me/current`), potem aktualizacje z WebSocket.

## Rzeczy łatwe do zepsucia

- `Profile`/`myProfileProvider` w `core/lib/src/api/profile.dart` to tymczasowy kod z dnia 1 — po wygenerowaniu klienta zastąp go `MeApi`.
- Lokalizacja kierowcy w tle: Android foreground service z powiadomieniem tylko gdy „online”; uprawnienia w `AndroidManifest.xml` i `Info.plist` (opisy po polsku). Testuj na prawdziwym telefonie.
- Klucz Google Maps dla SDK mobilnego w `AndroidManifest.xml` / `AppDelegate` — z ograniczeniem do pakietu/bundle ID. Klucz serwerowy (Places/Routes) NIGDY w aplikacji.
- Stripe: `Stripe.publishableKey` z `GET /config`; PaymentSheet dostaje `client_secret` z `POST /rides`. Aplikacja NIE ustala, czy płatność się udała — czeka na `ride.payment` z WebSocket / stan z `GET /rides/{id}`.
- Push (FCM): token rejestruj przez `PUT /me/device-tokens` po zalogowaniu i przy `onTokenRefresh`.
- Teksty UI po polsku; formaty dat `pl_PL`.

## Testy

- `packages/core`: testy jednostkowe (fakes zamiast pluginów — patrz `test/auth_service_test.dart`).
- Aplikacje: testy widgetów z `ProviderScope(overrides: [...])` i fałszywym `OidcClient`/`TokenStorage` (patrz `apps/*/test/app_test.dart`). Pluginy (mapy, lokalizacja) za interfejsami w `core`, w testach fake.

# Postęp etapów

Pamięć między sesjami agenta. Po każdym zmergowanym PR: odhacz zadanie i dopisz numer PR.

## Etap 1 — kompletny backend MVP

### Krok 0: porządek w repo
- [x] PR #10 (klient API + zielone CI) zmergowany, #9 zamknięty
- [x] PR-y Dependabota: zielone zmergowane (#1–#4, #19, #20, #22, #24, #25, #27); Python 3.15 (#11) i flutter_appauth 13 (#17) zamknięte z komentarzem; #5 (upload-artifact 7) i #14 (FastAPI <0.163) wykonane ręcznie w #39
- [x] `ignore` dla aktualizacji major w `.github/dependabot.yml` (#23)
- [x] Ochrona `main` (ruleset): statusy Backend, Mobile, Kontrakt API; zakaz force-push; PR wymagany, 0 zatwierdzeń
- [x] Ten plik (#23)

### Zakres
- [x] 1. Regiony i cenniki: modele + migracja (PostGIS, wersjonowane cenniki), GET /regions, admin CRUD regionów (GeoJSON) i cenników, seed dwóch gmin — #26
- [x] 2. Wycena: POST /quotes, RoutingProvider (Google Routes / fallback po prostej × 1,3, 40 km/h), ST_Contains, nocny mnożnik, minimum, ważność 5 min — #28
- [x] 3. Adresy: /places/autocomplete, /places/{id}, /places/reverse — Google Places / fallback Nominatim (User-Agent, 1 zapytanie/s, cache) — #29
- [x] 4. Kursy pasażera (gotówka): maszyna stanów + ride_events, POST /rides (card/blik → 422), GET /rides, GET /rides/{id}, anulowanie, ocena — #30
- [x] 5. Kierowcy: wniosek, dokumenty przez SAS (Azurite w docker-compose), admin: lista/szczegóły/view-url/approve (rola w Keycloaku)/reject/suspend — #31
- [x] 6. Dyspozycja na żywo: availability, pozycja przez WS → Redis GEO, oferta najbliższemu, timeout 20 s (Celery worker + beat), accept odporny na wyścig, decline, no_driver, WS + Redis pub/sub — #32
- [x] 7. Kurs w toku: /drivers/me/current, depart/arrived/start/complete, cash-collected, anulowanie przez kierowcę, ocena pasażera, rejestr zarobków, GET /earnings — #33
- [x] 8. Rezerwacje: scheduled_at, giełda (scheduled-board, claim), beat: przypomnienie T−60, dyspozycja T−30 — #34
- [x] 9. Push: PushSender (FCM / logujący fallback), PUT /me/device-tokens — #35
- [x] 10. Admin — kursy: GET /admin/rides z filtrami — #36
- [x] 11. `docker compose up -d` stawia wszystko (migracje → seed idempotentny → API, worker, beat, Keycloak, Azurite) — #37
- [x] 12. `scripts/demo_flow.py` — scenariusz end-to-end przez prawdziwe API — #38

### Koniec etapu
- [x] `docker compose up -d` + `demo_flow.py` przechodzi (od zera po `down -v`, 11 s; kolejne biegi 8 s) — #38
- [x] Raport dla właściciela (w rozmowie, 17.11.2026)

## Etap 2 — aplikacje Pasażer i Kierowca (Flutter, Android)

### Krok 0: środowisko
- [x] Flutter 3.47.1, Android SDK 36/37, NDK 28.2 (nowe Android CLI: `android sdk install ndk/28.2.13676358`, akceptacja licencji niepotrzebna); emulator `Pixel_API_36` (na API 37 logowanie nie wraca do aplikacji — znany problem); backend: `docker compose up -d` + `demo_flow.py` ✔

### Zakres
- [x] 1. Platformy: `setup_platforms.sh` (UTF-8 na Windows, bez `taskAffinity=""`), android/ios w repo, obie aplikacje na emulatorze, logowanie przez Keycloak (`adb reverse` 8000/8080), `Profile` → wygenerowany `MeApi` — #43
- [x] 2. Fundamenty w `core`: klient WebSocket (auth, ping, reconnect z backoffem, subskrypcje), serwis lokalizacji, formatowanie złotówek, błędy API po polsku, ekran uzupełnienia profilu, polska lokalizacja Material — #44
- [x] 3. Mapy: flutter_map 8.3.2 + latlong2 0.10.1 + kafelki OSM zamiast google_maps_flutter (zarys + AGENTS.md), `PodwozkaMap` w `core`, dekoder polyline, uprawnienie INTERNET w release — #45
- [x] 4. Pasażer: skąd/dokąd (GPS, pinezka, wyszukiwarka) → wycena → teraz/później → gotówka (karta/BLIK „wkrótce”) → oczekiwanie → śledzenie z ETA (WS) → podsumowanie i ocena; historia, anulowanie, rezerwacje, powrót do aktywnego kursu po restarcie — #46
- [x] 5. Kierowca — wniosek: pojazd, gmina, 4 zdjęcia dokumentów (image_picker: aparat/galeria) wysyłane bezpośrednio do Blob Storage linkiem SAS (bez tokenu API), status wniosku, po zatwierdzeniu odświeżenie tokenu i tryb pracy — #47
- [x] 6. Kierowca — praca: online (foreground service), oferta 20 s, aktywny kurs + „Nawiguj”, gotówka, ocena pasażera, giełda, zarobki, historia — #48, #49
  - [x] 6a. online (foreground service z powiadomieniem tylko online, uprawnienia z wyjaśnieniem), oferta z odliczaniem 20 s, aktywny kurs z akcjami, „Nawiguj” (Google Maps/Waze), gotówka, ocena pasażera — #48
  - [x] 6b. giełda rezerwacji (przyjęcie, oddanie, odświeżanie po `board.updated`), zarobki (dziś / 7 dni / miesiąc, prowizja z gotówki), historia — #49
- [ ] 7. Testy: jednostkowe (WebSocket, stany kursu), widgetowe kluczowych ekranów z fake'ami; `dart format`, `flutter analyze` czyste
- [ ] 8. Test akceptacyjny: pełny kurs za gotówkę na dwóch emulatorach, zrzuty w `docs/screenshots/`

### Koniec etapu
- [ ] Raport dla właściciela (co działa, uruchomienie od zera, znane problemy, etap 3)

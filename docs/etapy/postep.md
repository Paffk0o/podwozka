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

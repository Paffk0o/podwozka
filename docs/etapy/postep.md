# Postęp etapów

Pamięć między sesjami agenta. Po każdym zmergowanym PR: odhacz zadanie i dopisz numer PR.

## Etap 1 — kompletny backend MVP

### Krok 0: porządek w repo
- [x] PR #10 (klient API + zielone CI) zmergowany, #9 zamknięty
- [ ] PR-y Dependabota: zielone zmergowane; Python 3.15 (#11) i flutter_appauth 13 (#17) zamknięte z komentarzem
- [x] `ignore` dla aktualizacji major w `.github/dependabot.yml` (#23)
- [x] Ochrona `main` (ruleset): statusy Backend, Mobile, Kontrakt API; zakaz force-push; PR wymagany, 0 zatwierdzeń
- [x] Ten plik (#23)

### Zakres
- [x] 1. Regiony i cenniki: modele + migracja (PostGIS, wersjonowane cenniki), GET /regions, admin CRUD regionów (GeoJSON) i cenników, seed dwóch gmin — #26
- [x] 2. Wycena: POST /quotes, RoutingProvider (Google Routes / fallback po prostej × 1,3, 40 km/h), ST_Contains, nocny mnożnik, minimum, ważność 5 min — #28
- [ ] 3. Adresy: /places/autocomplete, /places/{id}, /places/reverse — Google Places / fallback Nominatim (User-Agent, 1 zapytanie/s, cache)
- [ ] 4. Kursy pasażera (gotówka): maszyna stanów + ride_events, POST /rides (card/blik → 422), GET /rides, GET /rides/{id}, anulowanie, ocena
- [ ] 5. Kierowcy: wniosek, dokumenty przez SAS (Azurite w docker-compose), admin: lista/szczegóły/view-url/approve (rola w Keycloaku)/reject/suspend
- [ ] 6. Dyspozycja na żywo: availability, pozycja przez WS → Redis GEO, oferta najbliższemu, timeout 20 s (Celery worker + beat), accept odporny na wyścig, decline, no_driver, WS + Redis pub/sub
- [ ] 7. Kurs w toku: /drivers/me/current, depart/arrived/start/complete, cash-collected, anulowanie przez kierowcę, ocena pasażera, rejestr zarobków, GET /earnings
- [ ] 8. Rezerwacje: scheduled_at, giełda (scheduled-board, claim), beat: przypomnienie T−60, dyspozycja T−30
- [ ] 9. Push: PushSender (FCM / logujący fallback), PUT /me/device-tokens
- [ ] 10. Admin — kursy: GET /admin/rides z filtrami
- [ ] 11. `docker compose up -d` stawia wszystko (migracje → seed idempotentny → API, worker, beat, Keycloak, Azurite)
- [ ] 12. `scripts/demo_flow.py` — scenariusz end-to-end przez prawdziwe API

### Koniec etapu
- [ ] `docker compose up -d` + `demo_flow.py` przechodzi
- [ ] Raport dla właściciela

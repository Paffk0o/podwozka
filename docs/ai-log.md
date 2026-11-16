# Dziennik pracy z AI

Projekt powstaje w trybie „vibe coding” — kod pisany głównie przez agentów AI, prowadzony i przeglądany przez ludzi. Ten dziennik pokazuje proces (dla prowadzącego i na obronę).

Format wpisu: data · obszar · narzędzie/model · co zrobił agent · co poprawił/zdecydował człowiek · link do PR.

| Data | Obszar | Narzędzie | Co zrobił agent | Decyzje i poprawki człowieka | PR |
|---|---|---|---|---|---|
| 2026-10-24 | Wszystkie | Claude (claude-opus-5-5) | Fundament: monorepo, AGENTS.md, docker compose, realm Keycloak, backend (JWT, /me, kontrakt v1 jako stuby, testy), core Flutter (PKCE, odświeżanie tokenu), CI | Wybór stosu i zakresu MVP, termin 6.12, podział na 3 agentów | — |
| 2026-11-16 | Backend | Claude Code (claude-opus-5-5) | Regiony (PostGIS MultiPolygon), wersjonowane cenniki, admin CRUD, seed dwóch gmin; wykryta i naprawiona usterka eksportu OpenAPI na Windowsie (cp1250) | Właściciel: zakres etapu i wybór gmin pozostawiony agentowi (Wieliczka, Niepołomice) | #26 |
| 2026-11-16 | Backend | Claude Code (claude-opus-5-5) | POST /quotes: RoutingProvider (Google Routes + offline po prostej x1,3, 40 km/h), cena całkowitoliczbowa w groszach z nocnym mnożnikiem w strefie regionu, wycena 5 min | — | #28 |
| 2026-11-16 | Backend | Claude Code (claude-opus-5-5) | Adresy: PlacesProvider (Google Places New + Geocoding / Nominatim z User-Agent, 1 zapytanie/s, cache 24 h); wykryty błąd odczytu openapi.json w cp1250 | — | #29 |
| 2026-11-16 | Backend | Claude Code (claude-opus-5-5) | Kursy pasażera: maszyna stanów (tabela przejść + ride_events, test każdej pary statusów), POST /rides gotówka, lista/szczegóły/anulowanie/ocena, outbox zdarzeń do Redis pub/sub po commicie; silnik DB i Redis per pętla zdarzeń | Decyzja agenta: weryfikacja telefonu wyłączona flagą REQUIRE_VERIFIED_PHONE do czasu SMSAPI | #30 |

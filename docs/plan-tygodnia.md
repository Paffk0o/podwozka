# Plan tygodnia: MVP w 7 dni (24–30.10.2026)

Oddanie: **6.12.2026**. Tydzień 24–30.10 = MVP. Potem ponad miesiąc zapasu: testy na telefonach, TestFlight, poprawki, dokumentacja i **przygotowanie do obrony** (każdy musi umieć wytłumaczyć swój obszar).

## Dzień 1 (sob 24.10) — fundament ✅ gotowe

Zrobione w repo (szczegóły: `README.md`):

- monorepo + `AGENTS.md` dla każdego obszaru,
- `docker compose up`: PostGIS 18, Redis 8.10, Keycloak 26.8 z realmem jako kod (role, klienci PKCE, użytkownicy testowi), Mailpit, API,
- backend: weryfikacja JWT z Keycloaka, role, `/me`, migracje Alembic, WebSocket (auth + ping), **kontrakt v1 całego MVP** (43 ścieżki, stuby 501), 23 testy,
- Flutter: workspace, `core` (logowanie PKCE, odświeżanie tokenu, Dio z tokenem, router), szkielety aplikacji Pasażer i Kierowca z ekranem logowania i profilem,
- CI: backend, kontrakt, mobile, SonarQube Cloud.

**Ludzie, dziś:** konta Apple Developer (weryfikacja trwa dni!), Azure for Students, Stripe (test), Google Cloud + Firebase (alert budżetu), SonarQube Cloud. Narzędzia na laptopach.

## Dzień 2 — rozruch (każdy u siebie, rano)

1. `docker compose up -d` → http://localhost:8000/docs działa, logowanie `pasazer@podwozka.test` / `Test1234!` w Keycloaku działa.
2. **Mobile (pierwsze zadanie dnia):** klient API jest już wygenerowany, a kod sformatowany i sprawdzony przez CI (workflow „Regeneracja klienta API”). Zainstaluj Fluttera, uruchom `mobile/scripts/setup_platforms.sh`, odpal obie aplikacje na emulatorze i zaloguj się. Zastąp tymczasowy `Profile` wygenerowanym `MeApi`. PR „platformy Android/iOS”.
3. **DevOps (pierwsze zadanie dnia):** repo na GitHubie, ochrona `main`, sekret `SONAR_TOKEN`, projekt w SonarQube Cloud (uzupełnij `sonar-project.properties`), pierwszy zielony CI.

Od tego momentu trzy agenty pracują równolegle.

## Dni 2–5 — trzy tory równolegle

| | Agent Backend | Agent Mobile | Agent DevOps |
|---|---|---|---|
| **Dni 2–3** | regiony (PostGIS, seed 2 gmin), cenniki, `POST /quotes` (adapter Google Routes + fake), maszyna stanów kursu, `POST /rides` (gotówka), dyspozycja (Redis GEO + Celery: oferta 20 s), WebSocket: subscribe, pozycja kierowcy | Pasażer: mapa, wybór adresów (`/places`), wycena, zamówienie, ekran śledzenia (WS). Kierowca: online/offline, lokalizacja w tle, oferta (akceptuj/odrzuć), akcje kursu, gotówka | staging na Azure Container Apps (API, migracje jako Job, Keycloak, Redis, Postgres Flexible + PostGIS), deploy z `main` przez OIDC, Entra ID w Keycloaku, Sentry |
| **Koniec dnia 3** | 🎯 **kurs za gotówkę działa od zamówienia do zakończenia (lokalnie)** | | |
| **Dni 4–5** | Stripe: PaymentIntent (karta manual capture, BLIK), webhooki; wnioski kierowców (Blob SAS, nadawanie roli w Keycloaku); rezerwacje + giełda (Celery beat); FCM; zarobki; oceny | PaymentSheet (karta, BLIK, Google Pay); onboarding kierowcy z uploadem dokumentów; giełda rezerwacji; push; historia; zarobki; oceny | panel admina (Flutter Web): wnioski kierowców, regiony (GeoJSON), cenniki, kursy; Fastlane → Firebase App Distribution (+ TestFlight, jeśli jest konto Apple) |

## Dzień 6 — integracja

Wszystko na staging, aplikacje na prawdziwych telefonach (Android przez App Distribution). Lista błędów → poprawki. Najczęstsze: lokalizacja w tle, push, webhooki Stripe, adresy w Keycloaku (issuer).

## Dzień 7 — domknięcie

Quality Gate zielony, scenariusz demo na dwóch gminach (zamówienie teraz, rezerwacja, karta, gotówka, weryfikacja kierowcy), README, nagranie demo, wpisy w `docs/ai-log.md`.

**Poza tygodniem (do 6.12):** SMS (SMSAPI), Apple Pay, federacja AD, testy na iOS, poprawki z testów, przygotowanie do obrony.

## Zasady pracy trzech agentów

1. Każdy agent tylko w swoim obszarze (tabela w `/AGENTS.md`). Potrzebna zmiana u innych → sekcja „Potrzebne od innych” w PR.
2. Kontrakt API zmienia się wyłącznie osobnym PR (`openapi.json` + wygenerowany klient). Mobile pracuje na wygenerowanym kliencie od pierwszej chwili — endpointy zwracające 501 obsłuż w UI mockiem w `core`, dopóki backend ich nie wdroży.
3. Małe PR-y, merge do `main` min. raz dziennie, tylko przy zielonym CI. Każdy PR przegląda człowiek z innego obszaru.
4. Synchronizacja 2× dziennie (15 min): co zmergowane, co blokuje, czy kontrakt się zmienia.
5. Przy każdej większej funkcji wpis w `docs/ai-log.md`.

## Prompty startowe dla agentów

Wklej jako pierwszą wiadomość w sesji agenta (np. Claude Code) uruchomionej w katalogu repo. Na kolejne dni: „Kontynuuj według `docs/plan-tygodnia.md`, dni X–Y, swój tor”.

### Agent Backend

```
Jesteś Agentem Backend w projekcie Podwózka. Przeczytaj /AGENTS.md, backend/AGENTS.md,
docs/zarys-projektu.md (sekcje 4–6), docs/ws-protocol.md i docs/plan-tygodnia.md.
Pracujesz tylko w backend/ (i eksportujesz openapi/). Kontrakt v1 już istnieje jako stuby 501 —
implementuj endpointy bez zmiany schematów; jeśli zmiana kontraktu jest konieczna, zrób osobny PR.
Zadanie na dni 2–3: regiony (PostGIS) z seedem dwóch gmin, cenniki, POST /quotes z adapterem
Google Routes (+ fake w testach), maszyna stanów kursu z ride_events, POST /rides dla gotówki,
dyspozycja (Redis GEO + Celery, oferta 20 s, następny kierowca), WebSocket wg docs/ws-protocol.md.
Pracuj małymi krokami: plan → testy → implementacja → ruff/mypy/pytest → osobny PR na każdą
funkcję. Zanim użyjesz API biblioteki w nowej wersji, sprawdź jej dokumentację.
```

### Agent Mobile

```
Jesteś Agentem Mobile w projekcie Podwózka. Przeczytaj /AGENTS.md, mobile/AGENTS.md,
mobile/README.md, docs/zarys-projektu.md (sekcje 2, 4.3, 5), docs/ws-protocol.md
i docs/plan-tygodnia.md. Pracujesz tylko w mobile/apps/passenger, mobile/apps/driver,
mobile/packages/core. Pierwsze zadanie: uruchom mobile/scripts/setup_platforms.sh
i ./scripts/gen-api-client.sh, potem dart format . i flutter analyze — szkielet powstał bez
kompilatora, popraw błędy. Zastąp tymczasowy Profile wygenerowanym MeApi.
Potem dni 2–3: pasażer (mapa, adresy przez /places, wycena, zamówienie, śledzenie przez WS)
i kierowca (online/offline, lokalizacja w tle, oferty, akcje kursu, gotówka).
Wspólne rzeczy do packages/core. Riverpod 3 bez code-gen. Testy logiki w core.
Małe PR-y, każdy z dart format + flutter analyze + flutter test na zielono.
```

### Agent DevOps

```
Jesteś Agentem DevOps w projekcie Podwózka. Przeczytaj /AGENTS.md, infra/AGENTS.md,
docs/zarys-projektu.md (sekcje 3.7, 5.3, 7) i docs/plan-tygodnia.md. Twój obszar: infra/,
.github/, docker-compose.yml, sonar-project.properties, mobile/apps/admin_web.
Pierwsze zadanie: zielone CI na GitHubie (sekret SONAR_TOKEN, projekt SonarQube Cloud,
ochrona gałęzi main z wymaganymi statusami). Dni 2–3: staging na Azure Container Apps
(API, ACA Job z migracjami, Keycloak z kc.sh build, Redis; Postgres Flexible Server z PostGIS),
deploy z main przez OIDC (bez haseł), wariant realmu na staging bez dev-cli i użytkowników
testowych, Identity Provider Entra ID dla admin-panel, Sentry. Dni 4–5: panel admina
we Flutter Web (logowanie OIDC na web — flutter_appauth nie wspiera web, dobierz pakiet
i sprawdź jego dokumentację), Fastlane → Firebase App Distribution. Infrastruktura jako kod
(Bicep lub skrypty az w infra/azure), sekrety tylko w GitHub/Azure.
```

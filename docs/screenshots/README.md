# Test akceptacyjny etapu 2: kurs za gotówkę pasażer ↔ kierowca

**Data:** 19.11.2026 · **Urządzenia:** dwa emulatory Android 16 (API 36, Pixel, Google Play) na jednym komputerze:
`emulator-5554` z aplikacją **Pasażer** (Anna, `pasazer@podwozka.test`) i `emulator-5556` z aplikacją **Kierowca**
(Karol, `kandydat@podwozka.test`, zatwierdzony w gminie Wieliczka). Backend lokalnie (`docker compose up -d`),
kafelki map z OpenStreetMap, trasa bez klucza Google (linia przerywana).

**Wynik: zaliczony.** W bazie kurs ma `status = completed`, `payment_status = cash_collected`, cenę 6693 gr i dwie
oceny (pasażera i kierowcy). W zarobkach kierowcy: brutto 66,93 zł, prowizja 6,69 zł, na rękę 60,24 zł.

## Przebieg

| # | Kto | Krok | Zrzut |
|---|---|---|---|
| 1 | Kierowca | Przełącza na „Jesteś online” (wyjaśnienie, zgoda na lokalizację i powiadomienia). Na mapie jego pozycja | [01](01-kierowca-online.jpg) |
| 2 | Pasażer | Ekran startowy: miejsce odbioru ustawione z GPS (adres z odwrotnego geokodowania) | [02](02-pasazer-start.jpg) |
| 3 | Pasażer | Wyszukiwanie celu „Rynek Główny Kraków” | [03](03-pasazer-wybor-celu.jpg) |
| 4 | Pasażer | Wycena: 66,93 zł, 15,7 km, 24 min, cena stała. Gotówka wybrana, karta i BLIK „wkrótce” | [04](04-pasazer-wycena.jpg) |
| 5 | Pasażer | „Zamów przejazd” → „Szukamy kierowcy…” | [05](05-pasazer-szukamy-kierowcy.jpg) |
| 6 | Kierowca | Oferta z odliczaniem 20 s: odległość do odbioru, cena, trasa → „Przyjmij” | [06](06-kierowca-oferta.jpg) |
| 7 | Pasażer | „Kierowca przyjął kurs”: imię, auto, tablica, telefon | [07](07-pasazer-kierowca-przyjal.jpg) |
| 8 | Kierowca | „Jadę po pasażera” → „Jedziesz po pasażera”, przyciski „Nawiguj” i „Jestem na miejscu” | [08](08-kierowca-jedzie-po-pasazera.jpg) |
| 9 | Pasażer | Pozycja kierowcy na żywo (WebSocket) i „Kierowca będzie za ok. 1 min” | [09](09-pasazer-eta-kierowcy.jpg) |
| 10 | Kierowca | „Jestem na miejscu” → „Czekasz na pasażera” | [10](10-kierowca-na-miejscu.jpg) |
| 11 | Pasażer | „Kierowca czeka na miejscu. Wyjdź do kierowcy” | [11](11-pasazer-kierowca-czeka.jpg) |
| 12 | Kierowca | „Pasażer wsiadł — ruszamy” → „Kurs w trakcie”, nawigacja do celu | [12](12-kierowca-kurs-w-trakcie.jpg) |
| 13 | Pasażer | „Jesteś w drodze”, „Do celu ok. 5 min”, auto na mapie | [13](13-pasazer-w-drodze.jpg) |
| 14 | Kierowca | „Zakończ kurs” → „Pobierz od pasażera gotówką: 66,93 zł” | [14](14-kierowca-pobierz-gotowke.jpg) |
| 15 | Pasażer | „Dojechaliśmy! Do zapłaty: 66,93 zł” i ocena kierowcy | [15](15-pasazer-podsumowanie.jpg) |
| 16 | Pasażer | 5 gwiazdek, opcjonalny komentarz → „Wyślij ocenę” → „Dziękujemy za ocenę!” | [16](16-pasazer-ocena-kierowcy.jpg) |
| 17 | Kierowca | „Potwierdzam odbiór gotówki” → ocena pasażera → powrót do „Jesteś online” | [17](17-kierowca-ocena-pasazera.jpg) |
| 18 | Kierowca | Zarobki „Dziś”: 1 kurs, brutto, prowizja do rozliczenia z gotówki, na rękę | [18](18-kierowca-zarobki.jpg) |

Ruch kierowcy symulowany poleceniami `adb -s emulator-5556 emu geo fix <lng> <lat>` (kilka punktów Wieliczka → Kraków).

## Uwagi z testu

- **Znaleziony i poprawiony błąd (#51):** na świeżym emulatorze bez „Dokładności lokalizacji Google” strumień
  pozycji kończył się błędem, a aplikacja kierowcy dalej pokazywała „Jesteś online” bez wysyłania pozycji. Teraz
  kierowca przechodzi offline z komunikatem „Lokalizacja w telefonie jest wyłączona…”.
- **Przeterminowana rezerwacja:** rezerwacja Anny z rana (10:46), przyjęta z giełdy i niewykonana, wieczorem dalej
  była „przyjęta” i aplikacja pasażera pokazała ją jako aktywny kurs. Anulowana ręcznie przed testem. Do etapu 3:
  backend powinien sam zamykać rezerwacje po czasie (np. `no_show` / anulowanie przez system).
- Kafelki OSM czasem doładowują się z opóźnieniem (szare pola na zrzucie 04). Produkcja potrzebuje własnego dostawcy kafelków.

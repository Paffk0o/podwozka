# Specyfikacje funkcji

Przed większą funkcją (np. „dyspozycja”, „rezerwacje”, „płatność BLIK”) człowiek albo agent pisze krótką specyfikację tutaj: `NN-nazwa.md`. Agent implementuje na jej podstawie, PR linkuje do specyfikacji.

## Szablon

```markdown
# NN. Nazwa funkcji

## Cel
Jedno zdanie: co użytkownik może zrobić.

## Zachowanie
- Kroki / reguły biznesowe (np. „oferta wygasa po 20 s, potem następny kierowca w promieniu 10 km”).

## API
- Endpointy z openapi.json, których dotyczy; zdarzenia WebSocket.

## Przypadki brzegowe
- Co gdy ... (brak kierowców, anulowanie w trakcie, podwójne kliknięcie, brak sieci).

## Kryteria akceptacji
- [ ] Sprawdzalne punkty (testy je pokrywają).
```

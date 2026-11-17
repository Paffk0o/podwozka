# secrets/ — klucze montowane do kontenerów (lokalnie)

Wszystko w tym katalogu poza tym plikiem jest w `.gitignore` i **nigdy** nie trafia do repo.
Katalog jest montowany do workera Celery jako `/run/secrets` (tylko do odczytu).

| Plik | Do czego | Skąd |
|---|---|---|
| `firebase-service-account.json` | Push FCM (opcjonalnie; bez niego pushe są tylko logowane) | Konsola Firebase → Ustawienia projektu → Konta usługi → Wygeneruj nowy klucz prywatny |

Po dodaniu pliku ustaw w `.env`:

```
FIREBASE_CREDENTIALS_FILE=/run/secrets/firebase-service-account.json
```

i zrestartuj workera: `docker compose up -d worker`.

# Chefify

[Українська](#ukrainian) | [English](#english)

## Table of Contents

- [Ukrainian](#ukrainian)
- [UA Scope](#ua-scope)
- [UA Flutter SDK Setup](#ua-flutter-sdk-setup)
- [UA Flutter Commands](#ua-flutter-commands)
- [UA Docker Full Stack](#ua-docker-full-stack)
- [UA Docker Frontend Only](#ua-docker-frontend-only)
- [UA Troubleshooting](#ua-troubleshooting)
- [UA Key Files](#ua-key-files)
- [English](#english)
- [EN Scope](#en-scope)
- [EN Flutter SDK Setup](#en-flutter-sdk-setup)
- [EN Flutter Commands](#en-flutter-commands)
- [EN Docker Full Stack](#en-docker-full-stack)
- [EN Docker Frontend Only](#en-docker-frontend-only)
- [EN Troubleshooting](#en-troubleshooting)
- [EN Key Files](#en-key-files)

---

## Ukrainian

### UA Scope

- `frontend/` - Flutter web клієнт.
- `backend/` - .NET 9 API.
- `docker-compose.yml` - єдиний compose для БД, API та frontend.

### UA Flutter SDK Setup

Запусти один раз:

```powershell
.\tools\setup-flutter.ps1
```

```bash
./tools/setup-flutter.sh
```

Що робить setup:

1. Шукає SDK автоматично: `CHEFIFY_FLUTTER_SDK` -> `.tooling/flutter-sdk-path.txt` -> `./.flutter-sdk` -> `flutter` у `PATH`.
2. Якщо SDK не знайдено, пропонує два варіанти: ввести шлях вручну або встановити локально в `./.flutter-sdk`.
3. Зберігає робочий шлях у `.tooling/flutter-sdk-path.txt` для наступних запусків.

### UA Flutter Commands

Запуск через обгортки з кореня репозиторію:

```powershell
.\flutterw.ps1 --version
cd .\frontend
..\flutterw.ps1 pub get
..\flutterw.ps1 run -d chrome
```

`flutterw` сам викличе setup-логіку, якщо шлях до SDK ще не налаштований.

### UA Docker Full Stack

Повний запуск (db + api + frontend-web):

```powershell
docker compose --profile frontend up --build
```

Сервіси і порти:

- `db` (PostgreSQL): `localhost:5432`
- `api` (.NET): `http://localhost:8080`
- `frontend-web` (nginx + Flutter web): `http://localhost:8088`

Тільки backend (db + api):

```powershell
docker compose up --build
```

Зупинка:

```powershell
docker compose --profile frontend down --remove-orphans
```

### UA Docker Frontend Only

Frontend only (через build у Docker):

```powershell
docker compose --profile frontend up --build frontend-web
```

Перший build може довго качати Flutter SDK. Після нього `frontend-web`
експортує BuildKit cache у `.docker-cache/frontend-web`, тому наступні build-и
мають брати Flutter SDK шар із cache. Якщо знову довго висить на `RUN curl ...
flutter.tar.xz`, перевір, що не запускався `--no-cache`, `docker builder prune`
або очищення Docker Desktop build cache.

Frontend preview з локального `flutter build web`:

```powershell
cd .\frontend
..\flutterw.ps1 build web
cd ..
docker compose --profile frontend-local-build up --build frontend-preview
```

### UA Troubleshooting

- Порт `8088` зайнятий:

```powershell
$env:FRONTEND_HTTP_PORT='8090'; docker compose --profile frontend up --build
```

- Помилка `unknown directive "﻿server"` у nginx: перевір, що використовується актуальний образ, і перебілдь frontend:

```powershell
docker compose --profile frontend build --no-cache frontend-web
docker compose --profile frontend up -d frontend-web
```

- `api` віддає `500` через відсутні таблиці: у поточній версії міграції застосовуються автоматично при старті API контейнера.

### UA Key Files

- `tools/setup-flutter.ps1`
- `tools/setup-flutter.sh`
- `flutterw.ps1`
- `flutterw.bat`
- `backend/Program.cs`
- `frontend/Dockerfile.web`
- `frontend/docker/nginx.conf`
- `docker-compose.yml`
- `.env.frontend.example`

---

## English

### EN Scope

- `frontend/` - Flutter web client.
- `backend/` - .NET 9 API.
- `docker-compose.yml` - single compose file for DB, API, and frontend.

### EN Flutter SDK Setup

Run once:

```powershell
.\tools\setup-flutter.ps1
```

```bash
./tools/setup-flutter.sh
```

Setup behavior:

1. Auto-detects SDK in this order: `CHEFIFY_FLUTTER_SDK` -> `.tooling/flutter-sdk-path.txt` -> `./.flutter-sdk` -> `flutter` in `PATH`.
2. If not found, shows two choices: enter SDK path manually or install local SDK into `./.flutter-sdk`.
3. Saves the chosen SDK path to `.tooling/flutter-sdk-path.txt`.

### EN Flutter Commands

Use wrappers from repository root:

```powershell
.\flutterw.ps1 --version
cd .\frontend
..\flutterw.ps1 pub get
..\flutterw.ps1 run -d chrome
```

`flutterw` automatically triggers setup if SDK path is not configured yet.

### EN Docker Full Stack

Full run (db + api + frontend-web):

```powershell
docker compose --profile frontend up --build
```

Services and ports:

- `db` (PostgreSQL): `localhost:5432`
- `api` (.NET): `http://localhost:8080`
- `frontend-web` (nginx + Flutter web): `http://localhost:8088`

Backend only (db + api):

```powershell
docker compose up --build
```

Stop:

```powershell
docker compose --profile frontend down --remove-orphans
```

### EN Docker Frontend Only

Frontend only (Docker build):

```powershell
docker compose --profile frontend up --build frontend-web
```

The first build can spend a while downloading the Flutter SDK. After that,
`frontend-web` exports BuildKit cache into `.docker-cache/frontend-web`, so
later builds should reuse the Flutter SDK layer. If it hangs again on `RUN curl
... flutter.tar.xz`, check that nobody used `--no-cache`, `docker builder prune`,
or Docker Desktop build-cache cleanup.

Frontend preview from local `flutter build web`:

```powershell
cd .\frontend
..\flutterw.ps1 build web
cd ..
docker compose --profile frontend-local-build up --build frontend-preview
```

### EN Troubleshooting

- Port `8088` is already in use:

```powershell
$env:FRONTEND_HTTP_PORT='8090'; docker compose --profile frontend up --build
```

- `unknown directive "﻿server"` from nginx: rebuild frontend image without cache:

```powershell
docker compose --profile frontend build --no-cache frontend-web
docker compose --profile frontend up -d frontend-web
```

- API returns `500` due to missing tables: current setup applies EF Core migrations automatically on API startup.

### EN Key Files

- `tools/setup-flutter.ps1`
- `tools/setup-flutter.sh`
- `flutterw.ps1`
- `flutterw.bat`
- `backend/Program.cs`
- `frontend/Dockerfile.web`
- `frontend/docker/nginx.conf`
- `docker-compose.yml`
- `.env.frontend.example`

# Chefify

[Українська](#ukrainian) | [English](#english)

## Table of Contents

- [Ukrainian](#ukrainian)
- [UA Scope](#ua-scope)
- [UA Flutter SDK Setup](#ua-flutter-sdk-setup)
- [UA Flutter Commands](#ua-flutter-commands)
- [UA Docker Frontend](#ua-docker-frontend)
- [UA Key Files](#ua-key-files)
- [English](#english)
- [EN Scope](#en-scope)
- [EN Flutter SDK Setup](#en-flutter-sdk-setup)
- [EN Flutter Commands](#en-flutter-commands)
- [EN Docker Frontend](#en-docker-frontend)
- [EN Key Files](#en-key-files)

---

## Ukrainian

### UA Scope

- `frontend/` - Flutter клієнт.
- `backend/` - .NET API.

Цей документ покриває тільки frontend/tooling. Бекенд у цьому кроці не змінюється.

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

### UA Docker Frontend

Файл: `docker-compose.frontend.yml`
Шаблон змінних: `.env.frontend.example`

Варіант 1: зібрати Flutter Web повністю в Docker і запустити nginx:

```bash
docker compose -f docker-compose.frontend.yml --profile frontend up --build
```

- Порт за замовчуванням: `8088`.
- Змінити порт: `FRONTEND_HTTP_PORT=8090`.
- Змінити Flutter у build-контейнері: `FLUTTER_VERSION=3.41.9`.
- Можна створити `.env` з `.env.frontend.example` і запускати без інлайн-змінних.

Варіант 2: зібрати web локально своїм SDK і віддати через контейнер nginx:

```powershell
cd .\frontend
..\flutterw.ps1 build web
cd ..
docker compose -f docker-compose.frontend.yml --profile frontend-local-build up
```

- Порт за замовчуванням: `8089`.
- Змінити порт: `FRONTEND_PREVIEW_PORT=8091`.

### UA Key Files

- `tools/setup-flutter.ps1`
- `tools/setup-flutter.sh`
- `flutterw.ps1`
- `flutterw.bat`
- `frontend/Dockerfile.web`
- `frontend/docker/nginx.conf`
- `docker-compose.frontend.yml`
- `.env.frontend.example`

---

## English

### EN Scope

- `frontend/` - Flutter client.
- `backend/` - .NET API.

This document covers frontend/tooling only. Backend is intentionally untouched in this step.

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

### EN Docker Frontend

File: `docker-compose.frontend.yml`
Variables template: `.env.frontend.example`

Option 1: build Flutter Web inside Docker and serve via nginx:

```bash
docker compose -f docker-compose.frontend.yml --profile frontend up --build
```

- Default port: `8088`.
- Override port: `FRONTEND_HTTP_PORT=8090`.
- Override Flutter version for container build: `FLUTTER_VERSION=3.41.9`.
- You can copy `.env.frontend.example` to `.env` and run without inline variables.

Option 2: build web locally with your SDK and serve via nginx container:

```powershell
cd .\frontend
..\flutterw.ps1 build web
cd ..
docker compose -f docker-compose.frontend.yml --profile frontend-local-build up
```

- Default port: `8089`.
- Override port: `FRONTEND_PREVIEW_PORT=8091`.

### EN Key Files

- `tools/setup-flutter.ps1`
- `tools/setup-flutter.sh`
- `flutterw.ps1`
- `flutterw.bat`
- `frontend/Dockerfile.web`
- `frontend/docker/nginx.conf`
- `docker-compose.frontend.yml`
- `.env.frontend.example`

# Sādhak Backend (Express)

Minimal backend to receive PDF report uploads and test results from the Flutter app.

## Features
- POST /upload — multipart file upload (field: `file`), saves to `uploads/` and returns a URL
- GET /results — list stored results (JSON file store for demo)
- POST /results — upsert a test result entry into a simple JSON file store
- GET /health — health check

## Quick Start (Windows PowerShell)

```powershell
# From repo root
cd server
npm install
# optional: copy .env.example to .env and edit
npm start
```

Server starts at http://localhost:4000 by default.

## Configure Flutter base URL
When testing on a device/emulator, `localhost` differs by platform:
- Android emulator: http://10.0.2.2:4000
- Android device on same LAN: use your PC IP, e.g. http://192.168.1.23:4000
- iOS simulator: http://127.0.0.1:4000

Update the app configuration to point to the backend (see `lib/services/app_config.dart`).

## API

- POST /upload
  - Content-Type: multipart/form-data
  - Fields: `file` (required), optional text: `title`, `generatedAt`
  - Response: `{ ok, file: { filename, size, url }, meta }

- POST /results (demo storage)
  - Content-Type: application/json
  - Body: `{ testTitle, resultValue, date, videoPath?, wrongRepCount?, formCorrect?, feedback? }`
  - Response: `{ ok: true }`

- GET /results
  - Response: `{ ok, count, data: [...] }`

## Notes
- This backend is for demo/prototype purposes. For production, replace the JSON store with a real database (PostgreSQL/MySQL/SQLite) and add authentication.
- CORS is wide open for ease of development; restrict as needed.

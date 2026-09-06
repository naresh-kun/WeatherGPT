# WeatherGPT

A conversational weather intelligence prototype providing real-time weather data, forecasts, smart alerts, weather-based advisories, historical climate trends, multilingual support, and voice interaction.

---

## Project Status

| Phase | Status | Description |
|---|---|---|
| Phase 1 | **Complete** | Project scaffold, API contract, backend structure |
| Phase 2 | **Complete** | Flutter UI with mock data (no backend integration) |
| Phase 3+ | Planned | Backend API integration, real weather data, AI |

### Phase 2 — Frontend Status

The Flutter application (`frontend/weathergpt_app/`) now includes a **polished UI prototype** with:

- **Screens implemented**: Splash, Home, WeatherGPT Chat, Forecast, Alerts, Advisory, Climate, Settings
- **Navigation**: Bottom navigation bar (Home, WeatherGPT, Alerts, Advisory, Climate) + Settings from Home
- **Data source**: Centralized **mock/dummy data** in `lib/data/mock_data.dart`
- **Charts**: Temperature and rainfall trends using `fl_chart`

**Not yet implemented** (deferred to later phases):

- Weather API integration
- FastAPI backend calls
- LLM / AI chat backend
- Real alerts engine
- Real advisory calculations
- Real climate backend processing
- Tamil localization
- Speech-to-text / text-to-speech
- Real GPS / location services

---

## Architecture

```
Flutter App (frontend/weathergpt_app/)
        ↓  REST / JSON  [Phase 3+ — not connected yet]
FastAPI Backend (backend/weathergpt_api/)
        ├── Weather Service
        ├── AI Service
        ├── Alert Engine
        ├── Advisory Service
        ├── Climate Service
        └── Localization Service
              ↓
        External Weather Provider
        LLM Provider
        Historical Dataset
```

The Flutter frontend communicates **only** with the FastAPI backend (once integrated).  
The frontend must **never** call the weather provider or LLM provider directly.

**Current Phase 2 behaviour**: The Flutter UI renders mock data locally. No HTTP calls are made to the backend.

---

## Developer Ownership

### Frontend Developer owns:
```
frontend/
```

### Backend Developer owns:
```
backend/
```

### Shared (both developers maintain):
```
docs/
README.md
```

### Restrictions:
- The **Frontend Developer** must **not** modify any backend implementation.
- The **Backend Developer** must **not** modify any Flutter implementation.
- Both developers must treat `docs/api/API_CONTRACT.md` as the integration boundary.  
  Any change to the API contract must be agreed upon by both developers before implementation.

---

## Project Structure

```
WeatherGPT/
├── frontend/
│   └── weathergpt_app/        # Flutter application (Phase 2 UI complete)
├── backend/
│   └── weathergpt_api/        # FastAPI application (Phase 1 scaffold)
├── docs/
│   ├── architecture/
│   │   └── ARCHITECTURE.md    # System design & data flows
│   └── api/
│       ├── API_CONTRACT.md    # REST API specification
│       └── DATA_MODELS.md     # Conceptual data models
├── data/
│   ├── historical/            # Historical climate datasets (gitignored)
│   └── sample/                # Sample data for development
├── .gitignore
├── README.md
└── LICENSE
```

---

## Getting Started

### Backend
```bash
cd backend/weathergpt_api
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt
cp .env.example .env            # Fill in real values — never commit .env
uvicorn app.main:app --reload
```
API available at: `http://localhost:8000`  
Docs available at: `http://localhost:8000/docs`

### Frontend
```bash
cd frontend/weathergpt_app
flutter pub get
flutter run
```

The Flutter app launches with mock data. No backend connection is required for Phase 2.

---

## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, production-ready code |
| `develop` | Integration branch for both developers |
| `feature/frontend-*` | Frontend feature branches |
| `feature/backend-*` | Backend feature branches |

Frontend and backend feature branches must remain isolated. Both merge into `develop` after code review. `develop` merges into `main` for releases.

---

## API Reference

See [`docs/api/API_CONTRACT.md`](docs/api/API_CONTRACT.md) for the full REST API specification.  
See [`docs/api/DATA_MODELS.md`](docs/api/DATA_MODELS.md) for conceptual data models.  
See [`docs/architecture/ARCHITECTURE.md`](docs/architecture/ARCHITECTURE.md) for the system architecture.

---

## Security

- API keys and secrets are **never** hardcoded.
- All secrets are loaded from environment variables via `.env` (excluded from git).
- See `backend/weathergpt_api/.env.example` for required variables.

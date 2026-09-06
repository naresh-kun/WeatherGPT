# WeatherGPT — System Architecture

**Version**: 0.2.0  
**Project Type**: SIH (Smart India Hackathon) Prototype  
**Developers**: 2 (Frontend, Backend)  
**Current Phase**: Phase 2 — Flutter UI (mock data)

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────┐
│            Flutter Application           │
│         (frontend/weathergpt_app/)       │
│                                          │
│  Screens → Providers → Repositories     │
│       → Services → API Client           │
└──────────────────┬──────────────────────┘
                   │
              REST / JSON
           (HTTP over HTTPS)
                   │
┌──────────────────▼──────────────────────┐
│            FastAPI Backend               │
│         (backend/weathergpt_api/)        │
│                                          │
│  Routes → Services → Repositories       │
│  ├── Weather Service                     │
│  ├── AI Service                          │
│  ├── Alert Engine                        │
│  ├── Advisory Service                    │
│  ├── Climate Service                     │
│  └── Localization Service               │
└─────────────────────────────────────────┘
          │              │
          ▼              ▼
  External Weather    LLM Provider
     Provider         (e.g., Gemini)
          │
          ▼
    Historical
      Dataset
```

**Critical Rule**: The Flutter frontend must **never** call the External Weather Provider or LLM Provider directly. All external API calls go through the FastAPI backend.

**Phase 2 Note**: The Flutter UI is implemented and currently consumes **local mock data** from `frontend/weathergpt_app/lib/data/mock_data.dart`. No HTTP requests are made to the FastAPI backend yet. The backend remains at the Phase 1 scaffold state.

---

## 1.1 Phase 2 Frontend Architecture (Current)

```
SplashScreen
     ↓ (2s transition)
MainShell (Bottom Navigation — IndexedStack)
     ├── HomeScreen          → MockData (weather, forecast preview, alerts preview)
     ├── ChatScreen          → MockData.simulateChatResponse() (local keyword matching)
     ├── AlertsScreen        → MockData.alerts
     ├── AdvisoryScreen      → MockData.advisories
     └── ClimateScreen       → MockData.climateDatasets (5/10/20 year mock datasets)

Secondary routes (Navigator.push):
     ├── ForecastScreen      → MockData.forecast
     └── SettingsScreen      → Local state only (toggles, language UI)

Widget layers:
     Screens → Reusable Widgets (widgets/) → MockData / Models (models/)
```

| Component | Phase 2 Status |
|---|---|
| Screens & navigation | **Implemented** |
| Reusable widgets | **Implemented** |
| Dart data models | **Implemented** (aligned with API contract) |
| Mock data layer | **Implemented** (`lib/data/mock_data.dart`) |
| API service / repositories | **Placeholder** (Phase 1 scaffold, not wired) |
| Backend HTTP calls | **Not implemented** |
| Real weather / AI / alerts / climate | **Not implemented** |

---

## 2. Component Responsibilities

### Flutter Frontend (`frontend/weathergpt_app/`)

| Layer | Responsibility |
|---|---|
| **Screens** | UI rendering only — no business logic |
| **Providers** | State management (reactive layer) |
| **Repositories** | Abstract data sources; call the API service |
| **Services / API** | HTTP client — calls FastAPI endpoints |
| **Services / Location** | Device GPS / geocoding |
| **Services / Voice** | Speech-to-text and text-to-speech |
| **Services / Storage** | Local persistence (preferences, cache) |
| **Models** | Dart representations of the API contract models |

### FastAPI Backend (`backend/weathergpt_api/`)

| Layer | Responsibility |
|---|---|
| **Routes** | HTTP endpoints — validates input, returns responses |
| **Services / Weather** | Fetches and normalises data from weather provider |
| **Services / AI** | Interfaces with the LLM provider |
| **Services / Alerts** | Rule engine that generates weather alerts |
| **Services / Advisory** | Generates context-aware advisories |
| **Services / Climate** | Calculates trends from historical datasets |
| **Services / Localization** | Translates / localises AI responses |
| **Repositories** | Data access abstraction |
| **Schemas** | Pydantic models for request/response validation |
| **Core / Config** | Environment-variable-based configuration |

---

## 3. Data Flows

### 3.1 Flow 1: Current Weather & Forecast

**User action**: Opens the app / refreshes home screen.

1. **Flutter**: `HomeScreen` requests data from `WeatherRepository`.
2. **Flutter**: `WeatherRepository` calls `ApiService.getForecast()`.
3. **Backend**: `GET /api/v1/weather/forecast` receives the request.
4. **Backend**: `WeatherService` formats the query and calls `WeatherAPIClient`.
5. **External**: `WeatherAPIClient` requests `forecast.json` from **WeatherAPI.com**.
6. **Backend**: `WeatherService` parses the raw WeatherAPI JSON into `WeatherForecast` Pydantic models.
7. **Flutter**: `WeatherRepository` parses the backend JSON into Dart `WeatherForecast` models.
8. **Flutter**: `WeatherProvider` notifies the UI to rebuild.

*(Phase 2 Note: The Flutter app currently returns mock data directly from `WeatherRepository` and skips steps 2-7. This will be connected in Phase 4).*

### 3.2 Chat Flow

```
Flutter → POST /api/v1/chat { message, language, location }
       → FastAPI AI Service
       → Intent Understanding (classify query)
       → Weather Tool / Data Retrieval (fetch relevant weather data)
       → LLM Provider (e.g., Gemini) generates response
       → FastAPI returns ChatResponse
       → Flutter renders AI message in chat UI
```

### 3.3 Alerts Flow

**User action**: Navigates to the Alerts tab.

1. **Flutter**: `AlertsScreen` requests data from `AlertsRepository`.
2. **Flutter**: `AlertsRepository` calls `ApiService.getAlerts()`.
3. **Backend**: `GET /api/v1/alerts` receives the request.
4. **Backend**: `WeatherService` formats the query and calls `WeatherAPIClient`.
5. **External**: `WeatherAPIClient` requests `forecast.json` (with `alerts=yes`) from **WeatherAPI.com**.
6. **Backend**: `WeatherService` parses raw alerts into `Alert` Pydantic models.
7. **Flutter**: `AlertsRepository` parses JSON into Dart models.
8. **Flutter**: UI renders severity-colored alert cards.

*(Phase 2 Note: The Flutter app currently returns mock data directly from `AlertsRepository` and skips steps 2-7. This will be connected in Phase 4).*

### 3.4 Advisory Flow

```
Weather Data
       → FastAPI Advisory Service (rule/parameter-based evaluation)
       → Generates Advisory objects per category
       → GET /api/v1/advisory returns advisories
       → Flutter displays advisory cards
```

### 3.5 Climate Flow

```
Historical Dataset (local CSV / database)
       → FastAPI Climate Service
       → Calculates trend statistics and anomalies
       → GET /api/v1/climate/trends returns trend data
       → Flutter renders time-series charts
```

### 3.6 Voice Flow

```
User speaks → Flutter STT (Speech-to-Text)
           → Text → POST /api/v1/chat { message, voice: true }
           → FastAPI returns ChatResponse optimised for TTS
           → Flutter TTS (Text-to-Speech) speaks response
```

### 3.7 Multilingual Flow

```
User selects language in Flutter settings
           → language parameter included in all API requests
           → FastAPI Localization Service localises AI-generated text
           → Response returned in user's chosen language
           → Flutter renders localised text
```

---

## 4. API Contract

All frontend–backend communication uses the REST API defined in [`../api/API_CONTRACT.md`](../api/API_CONTRACT.md).

- **Protocol**: HTTP/HTTPS
- **Format**: JSON (`application/json`)
- **Base path**: `/api/v1/`
- **Documentation**: Auto-generated Swagger UI at `/docs`

---

## 5. Security Architecture

- All secrets (API keys) are stored in environment variables, never in source code.
- The backend reads secrets from `.env` via Pydantic Settings.
- The frontend never has access to backend secrets.
- The `.env` file is excluded from version control via `.gitignore`.
- The `.env.example` file documents required variables with empty values.

---

## 6. Developer Ownership

| Directory | Owner | Rule |
|---|---|---|
| `frontend/` | Frontend Developer | Backend Developer must not modify |
| `backend/` | Backend Developer | Frontend Developer must not modify |
| `docs/` | Shared | Both developers maintain |
| `README.md` | Shared | Both developers maintain |

The API contract in `docs/api/API_CONTRACT.md` is the **only** integration boundary. Changes to the contract require agreement from both developers before implementation.

---

## 7. Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable, production-ready code |
| `develop` | Integration branch |
| `feature/frontend-*` | Frontend feature branches |
| `feature/backend-*` | Backend feature branches |

**Isolation Rule**: Frontend and backend feature branches must remain isolated. Neither developer should commit to the other's feature branches.

---

## 8. Non-Goals (Current Phase)

The following are **not** implemented:

- Authentication / JWT / OAuth
- Database infrastructure (PostgreSQL, Redis, etc.)
- MQTT / real-time messaging
- WIS2 / WMO data protocols
- Kubernetes / container orchestration
- NWP / WRF / GFS numerical weather prediction
- Satellite data processing
- **Backend API integration from Flutter** (Phase 3+)
- **Real weather, AI, alerts, advisory, or climate data** (Phase 3+)
- **Tamil localization and STT/TTS** (later phases)

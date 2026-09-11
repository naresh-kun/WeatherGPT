# WeatherGPT — System Architecture

**Version**: 0.5.0  
**Project Type**: SIH (Smart India Hackathon) Prototype  
**Developers**: 2 (Frontend, Backend)  
**Current Phase**: Phase 5 — AI Chat Integration (Gemini 3.7 Flash)

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────┐
│            Flutter Application           │
│         (frontend/weathergpt_app/)       │
│                                          │
│  Screens → Providers → Repositories     │
│       → Services → API Client           │
└──────────────────┼──────────────────────┘
                   │
              REST / JSON
           (HTTP over HTTPS)
                   │
┌──────────────────▼──────────────────────┐
│            FastAPI Backend               │
│         (backend/weathergpt_api/)        │
│                                          │
│  Routes → Services → Repositories       │
│  ├── Weather Service   [REAL — Phase 3]  │
│  ├── AI Service        [REAL — Phase 5]  │
│  ├── Alert Engine      [REAL — Phase 6]  │
│  ├── Advisory Service  [REAL — Phase 6]  │
│  ├── Climate Service   [REAL — Phase 7]  │
│  └── Localization      [PLANNED — Ph.8]  │
└─────────────────────────────────────────┘
          │              │
          ▼              ▼
  External Weather   Gemini 3.7 Flash
     Provider        (google-genai SDK)
  [REAL — Phase 3]  [REAL — Phase 5]
          │
          ▼
    Historical
      Dataset
  [REAL — Reference CSV]
```

**Critical Rule**: The Flutter frontend must **never** call the External Weather Provider or LLM Provider directly. All external API calls go through the FastAPI backend.

**Phase 7 Note**: The ClimateScreen now uses `ClimateProvider` → `ApiService.getClimate` → `GET /api/v1/climate` → `ClimateService` → `historical_weather.csv` (2000–2023 monthly reference dataset). Calculations (trends, baseline comparisons, anomalies, seasonal analysis, insights) are 100% deterministic without LLM involvement.

---

## 1.1 Phase 7 Architecture (Current)

```
SplashScreen
     ↓ (2s transition)
MainShell (Bottom Navigation — IndexedStack)
     ├── HomeScreen          → WeatherProvider & LocationProvider (Real API Data)
     ├── ChatScreen          → ChatProvider → POST /api/v1/chat (Gemini AI) [REAL — Phase 5]
     ├── AlertsScreen        → WeatherProvider.alerts (Real Smart Alerts) [REAL — Phase 6]
     ├── AdvisoryScreen      → WeatherProvider.advisories (Real Advisory Data) [REAL — Phase 6]
     └── ClimateScreen       → ClimateProvider → GET /api/v1/climate (Real Reference Data) [REAL — Phase 7]

Secondary routes (Navigator.push):
     ├── ForecastScreen      → WeatherProvider.forecast (Real API Data)
     ├── LocationSearchScreen→ LocationProvider (Real API Data)
     └── SettingsScreen      → Local state only (toggles, language UI)

Widget layers:
     Screens → Reusable Widgets (widgets/) → Providers (providers/) → API Service
```

| Component | Status |
|---|---|
| Screens & navigation | **Implemented** |
| Reusable widgets | **Implemented** |
| Dart data models | **Implemented** (aligned with API contract) |
| API service / providers | **Implemented** (wired to backend; ChatProvider, WeatherProvider, ClimateProvider) |
| Backend HTTP calls | **Implemented** (Weather/Alerts/Advisory/Location/Chat/Climate) |
| Real AI chat (Gemini) | **Implemented [Phase 5]** |
| Real Smart Alert Engine | **Implemented [Phase 6]** (Deterministic, rule-based) |
| Real Advisory Service | **Implemented [Phase 6]** (Rule-based templates, category filters) |
| Real Climate Intelligence | **Implemented [Phase 7]** (Deterministic calculations, reference CSV) |

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
| **Services / AI** | Interfaces with the LLM provider (Gemini 3.7 Flash) |
| **Services / Alerts** | Deterministic Smart Alert Engine with configurable thresholds |
| **Services / Advisory** | Generates rule-based contextual advisories |
| **Services / Climate** | Calculates trends from historical datasets [PLANNED] |
| **Services / Localization** | Translates / localises AI responses [PLANNED] |
| **Repositories** | Data access abstraction |
| **Schemas** | Pydantic models for request/response validation |
| **Core / Config** | Environment-variable-based configuration |

---

## 3. Data Flows

### 3.1 Flow 1: Current Weather & Forecast

**User action**: Opens the app / refreshes home screen.

1. **Flutter**: `HomeScreen` reads from `WeatherProvider`.
2. **Flutter**: `WeatherProvider` calls `ApiService.getForecast()`.
3. **Backend**: `GET /api/v1/weather/forecast` receives the request.
4. **Backend**: `WeatherService` formats the query and calls `WeatherAPIClient`.
5. **External**: `WeatherAPIClient` requests `forecast.json` from **WeatherAPI.com**.
6. **Backend**: `WeatherService` parses the raw WeatherAPI JSON into `WeatherForecast` Pydantic models.
7. **Flutter**: `ApiService` parses the backend JSON into Dart `WeatherForecast` models.
8. **Flutter**: `WeatherProvider` updates state and notifies UI to rebuild.

### 3.2 Chat Flow (Phase 5)

```
Flutter → POST /api/v1/chat { message, language, location }
       → FastAPI AI Service
       → Weather Tool / Data Retrieval (fetch current weather context)
       → LLM Provider (Google Gemini 3.7 Flash) generates response
       → FastAPI returns ChatResponse
       → Flutter renders AI message in chat UI
```

### 3.3 Alerts Flow (Phase 6)

**User action**: Navigates to the Alerts tab.

1. **Flutter**: `AlertsScreen` reads from `WeatherProvider`.
2. **Flutter**: `WeatherProvider.loadWeather()` calls `ApiService.getAlerts()`.
3. **Backend**: `GET /api/v1/alerts` receives the request.
4. **Backend**: `WeatherService.get_alerts_smart()` concurrently fetches current weather, forecast, and native WeatherAPI alerts.
5. **Backend**: Deterministic `AlertEngine` evaluates current & forecast data against configurable thresholds (heat, rain, wind, UV, thunderstorm).
6. **Backend**: Smart alerts are merged with native WeatherAPI alerts, deduplicated by alert type.
7. **Flutter**: `ApiService` parses JSON into Dart `WeatherAlert` models with `relevantValue` and `threshold`.
8. **Flutter**: UI renders severity-colored `AlertCard` widgets with observed sensor values and thresholds.

### 3.4 Advisory Flow (Phase 6)

**User action**: Navigates to the Advisory tab.

1. **Flutter**: `AdvisoryScreen` reads from `WeatherProvider`.
2. **Flutter**: `WeatherProvider.loadWeather()` calls `ApiService.getAdvisories()`.
3. **Backend**: `GET /api/v1/advisory` receives the request.
4. **Backend**: Evaluates live weather data against deterministic rule templates (no LLM).
5. **Backend**: Generates `Advisory` objects categorized by general, health, outdoor, travel, or agriculture.
6. **Flutter**: `ApiService` parses JSON into Dart `WeatherAdvisory` models.
7. **Flutter**: UI renders interactive category filter chips and `AdvisoryCard` widgets with recommendations.

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

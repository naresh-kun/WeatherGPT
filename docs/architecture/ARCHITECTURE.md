# WeatherGPT — System Architecture

**Version**: 0.10.0  
**Project Type**: SIH (Smart India Hackathon) Prototype  
**Developers**: 2 (Frontend, Backend)  
**Current Phase**: Phase 10 — Interactive Chat, AI Fallback & Reliability

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
│  ├── AI Service        [REAL — Phase 10] │
│  ├── Alert Engine      [REAL — Phase 6]  │
│  ├── Advisory Service  [REAL — Phase 6]  │
│  ├── Climate Service   [REAL — Phase 7]  │
│  └── Localization      [REAL — Phase 8]  │
└──────────────────┬──────────────────────┘
          │        │
          ▼        ▼
  External Weather ├── Primary: Gemini 3.7 Flash  [REAL — Phase 10]
     Provider      └── Fallback: Gemini 3.6 Flash [REAL — Phase 10]
  [REAL — Phase 3]
          │
          ▼
    Historical
      Dataset
  [REAL — Reference CSV]
```

**Critical Rule**: The Flutter frontend must **never** call the External Weather Provider or LLM Provider directly. All external API calls go through the FastAPI backend.

**Phase 8 Note**: Full bilingual capability (English & Tamil) is implemented across the Flutter frontend and FastAPI backend. The Flutter app uses `LanguageProvider` with `SharedPreferences` persistence and `flutter_localizations` / ARB dictionaries. The backend evaluates Smart Alerts, Advisories, Climate Insights, and Gemini AI Chat in the requested language while strictly preserving meteorological facts and numeric precision.

**Phase 9 Note**: Voice Interaction (STT & TTS) is integrated directly into the chat flow using `speech_to_text: ^7.4.0` and `flutter_tts: ^4.2.5`. Spoken input populates the chat input for user verification, and assistant responses can be spoken aloud in English (`en-US`) or Tamil (`ta-IN`) with graceful fallback.

**Phase 10 Note**: Interactive Chat and Reliability additions:
- Client-side interactive cards: `WeatherChatCard` and `ForecastChatCard` render structured grounded weather data inside chat bubbles.
- Contextual quick-action chips (localized English & Tamil) enable one-tap weather questions.
- Active location indicator in AppBar with tap-to-switch capability.
- Thinking state indicator ("WeatherGPT is checking the weather...").
- Duplicate-send prevention: inputs, buttons, and chips disabled while request is pending.
- Backend Dual-Model AI Fallback: `gemini-3.7-flash` (primary) with bounded 1-retry backoff (1.0s); automatically falls back to `gemini-3.6-flash` on persistent 503, 429, or timeout using identical grounded context.
- API Deduplication: Coordinate normalization (4 decimals) and forecast cache reuse across endpoints.

---

## 1.1 Phase 10 Architecture (Current)

```
SplashScreen
     ↓ (2s transition)
MainShell (Bottom Navigation — IndexedStack)
     ├── HomeScreen          → WeatherProvider & LocationProvider (Real API Data, Localized)
     ├── ChatScreen          → ChatProvider → POST /api/v1/chat [REAL — Phase 10]
     │                       │    ├── WeatherChatCard & ForecastChatCard
     │                       │    ├── Contextual Quick Actions (EN / TA)
     │                       │    ├── Active Location Badge (Tap → LocationSearchScreen)
     │                       │    └── Duplicate Send Guard & Thinking State
     │                       → VoiceProvider (SpeechService STT & TtsService TTS) [REAL — Phase 9]
     ├── AlertsScreen        → WeatherProvider.alerts (Bilingual Smart Alerts) [REAL — Phase 6 & 8]
     ├── AdvisoryScreen      → WeatherProvider.advisories (Bilingual Advisory Data) [REAL — Phase 6 & 8]
     └── ClimateScreen       → ClimateProvider → GET /api/v1/climate (Bilingual Reference Data) [REAL — Phase 7 & 8]

Secondary routes (Navigator.push):
     ├── ForecastScreen      → WeatherProvider.forecast (Real API Data, Localized)
     ├── LocationSearchScreen→ LocationProvider (Real API Data)
     └── SettingsScreen      → LanguageProvider (Persistent English/Tamil toggle)

Reliable AI Flow (Phase 10):
     ChatScreen TextField / Chip
              │
              ▼
         ChatProvider (Guards against duplicate sends)
              │
              ▼ POST /api/v1/chat (Client timeout: 60s)
         FastAPI Backend
              │
              ├─► WeatherAPIClient (Coordinate normalization & cross-cache reuse)
              │
              ├─► Gemini Primary: gemini-3.7-flash (Bounded 1 retry, 1.0s delay)
              │       │
              │       ▼ (if 503 / 429 / timeout fails)
              └─► Gemini Fallback: gemini-3.6-flash (Identical weather context)
                      │
                      ▼
         ChatResponse { message, weather_summary, forecast_summary }
              │
              ▼
         ChatBubble with WeatherChatCard / ForecastChatCard + Voice Speak
```

| Component | Status |
|---|---|
| Screens & navigation | **Implemented** |
| Reusable widgets | **Implemented** |
| Dart data models | **Implemented** (aligned with API contract) |
| API service / providers | **Implemented** (wired to backend; ChatProvider, WeatherProvider, ClimateProvider, LanguageProvider, VoiceProvider) |
| Backend HTTP calls | **Implemented** (Weather/Alerts/Advisory/Location/Chat/Climate) |
| Real AI chat (Gemini) | **Implemented [Phase 5 & 8 & 10]** (Bilingual, weather-grounded, dual-model fallback) |
| Real Smart Alert Engine | **Implemented [Phase 6 & 8]** (Deterministic, English & Tamil) |
| Real Advisory Service | **Implemented [Phase 6 & 8]** (Deterministic templates, English & Tamil) |
| Real Climate Intelligence | **Implemented [Phase 7 & 8]** (Deterministic calculations, English & Tamil) |
| Multilingual (Tamil) | **Implemented [Phase 8]** (Full UI + Backend + AI) |
| Voice Interaction (STT / TTS) | **Implemented [Phase 9]** (`speech_to_text: 7.4.0`, `flutter_tts: 4.2.5`, English & Tamil) |
| Interactive Chat Cards & Reliability | **Implemented [Phase 10]** (Quick actions, cards, dual-model AI fallback, 60s timeout) |

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

## 5. Security & Reliability Architecture

- **Credential Isolation**: All secrets (WeatherAPI key, Gemini API key) are loaded from `.env` via Pydantic Settings on the backend. The frontend never receives, stores, or handles provider credentials.
- **Log Sanitization**: `SensitiveDataFilter` is installed on root handlers and the `httpx` logger. Dynamically fetches configured secret tokens and sanitizes query parameters (`?key=...`, `&key=...`, `api_key=...`), `x-goog-api-key`, and `Authorization: Bearer ...` headers to `***` before emission.
- **Dedicated Chat Timeout**: General API requests enforce a 15-second timeout (`AppConfig.apiTimeout`). `/chat` requests enforce a dedicated 60-second timeout (`AppConfig.chatApiTimeout`) to comfortably handle LLM generation latency without stalling the UI.
- **Dual-Model Gemini Fallback & Bounded Retry**:
  - Primary model: `gemini-3.7-flash` (configurable via `GEMINI_MODEL`).
  - Fallback model: `gemini-3.6-flash` (configurable via `GEMINI_FALLBACK_MODEL`).
  - On transient errors (503 busy, 429 rate-limited, timeout), 1 bounded retry is executed after a 1.0s delay.
  - If the primary model continues to fail, the request automatically falls back to `gemini-3.6-flash` using the exact same weather grounding context.
  - Permanent authentication errors (401/403) fail immediately without retry or fallback.
- **Error Distinction**: Backend produces differentiated HTTP status codes and detail messages so the Flutter client can distinguish between:
  - Gemini temporary busy (`503`, `"WeatherGPT is temporarily busy. Please try again."`)
  - Gemini rate limit (`429`, `"WeatherGPT is temporarily rate-limited. Please try again later."`)
  - Weather provider outage (`503`, `"We're unable to retrieve current weather right now. Please try again."`)
  - Chat gateway timeout (`504`, `"WeatherGPT is taking longer than expected. Please try again."`)
  - Generic server errors (`500`)
- **API Call Deduplication & Cache Reuse**:
  - Coordinate normalization: Latitude and longitude are rounded to 4 decimal places (~11m precision).
  - Cross-endpoint cache reuse: Cached forecast data (30-second TTL) is reused to satisfy current weather and shorter-day forecast requests without duplicate external calls.
- **Version Control Exclusions**: `.env` is strictly excluded via `.gitignore`. `.env.example` documents variable names without secrets.

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

The following are **not** in scope for Phase 10:

- Authentication / JWT / OAuth (Phase 11+)
- Distributed database / caching infrastructure (PostgreSQL, Redis)
- Native mobile push notifications
- NWP / WRF / GFS numerical weather prediction simulations
- Direct satellite / radar imagery raster processing
- Modifying deterministic logic of Smart Alerts (Phase 6), Advisories (Phase 6), Climate Intelligence (Phase 7), or Multilingual (Phase 8)

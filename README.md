# WeatherGPT

A conversational weather intelligence prototype providing real-time weather data, forecasts, smart alerts, weather-based advisories, historical climate trends, multilingual support, and voice interaction.

---

## Project Status

| Phase | Status | Description |
|---|---|---|
| Phase 1 | **Complete** | Project scaffold, API contract, backend structure |
| Phase 2 | **Complete** | Flutter UI with mock data |
| Phase 3 | **Complete** | FastAPI backend with real Weather API integration |
| Phase 4 | **Complete** | Flutter frontend connected to real backend data |
| Phase 5 | **Complete** | AI Chat Integration (Gemini 3.7 Flash + real weather grounding) |
| Phase 6 | **Complete** | Smart Alerts & Advisories Engine (Deterministic, rule-based) |
| Phase 7 | **Complete** | Climate Intelligence (Deterministic trends, baselines, anomalies, reference data) |
| Phase 8 | **Complete** | Multilingual Support (English & Tamil across UI, Backend, Alerts, Advisories, Climate, Gemini Chat) |
| Phase 9 | **Complete** | Voice Interaction (Speech-to-Text via `speech_to_text`, Text-to-Speech via `flutter_tts`, English & Tamil) |
| Phase 10 | **Complete** | Interactive Chat, AI Fallback & Reliability (Weather cards, Quick Actions, Dual-Model Gemini Fallback, 60s Timeout) |
| Phase 11 | **Complete** | Backend Deployment (Railway HTTPS deployment, containerized Docker, live public API, AppConfig connection) |
| Phase 12 | **Complete** | Android APK & Production Mobile Release (Release APK build, Railway HTTPS backend integration, clean security) |

### Phase 12 — Android APK & Production Mobile Release [REAL — Phase 12]

WeatherGPT is packaged and verified as a standalone Android production release APK connected to the live Railway HTTPS FastAPI backend:
- **Application ID**: `com.weathergpt.weathergpt_app`
- **Application Label**: `WeatherGPT`
- **Release APK Output**: `frontend/weathergpt_app/build/app/outputs/flutter-apk/app-release.apk`
- **APK Size**: ~51.8 MB (54,287,554 bytes)
- **SHA-256 Checksum**: `609656555B7EF1DAEEF3F3837262A045B156D01E49534E2F2F5DA260DBF0CCA4`
- **Production Backend Endpoint**: `https://weathergpt-production-84b3.up.railway.app/api/v1`

#### Build Command
```bash
cd frontend/weathergpt_app
flutter build apk --release --dart-define=API_BASE_URL=https://weathergpt-production-84b3.up.railway.app/api/v1
```

#### Android Permissions Verified
- `android.permission.INTERNET`: Backend API connectivity over HTTPS.
- `android.permission.ACCESS_FINE_LOCATION` & `android.permission.ACCESS_COARSE_LOCATION`: GPS-based weather positioning.
- `android.permission.RECORD_AUDIO`: Voice speech-to-text input (Phase 9), requested on demand.
- Cleartext traffic is disabled globally in production (`main/AndroidManifest.xml`) and strictly segregated to `debug/AndroidManifest.xml` for local development.

#### Verified Features on Android Emulator / Physical Device
- **Live Home Dashboard**: Current weather conditions, feels-like temperature, humidity, wind, and UV index fetched from Railway API.
- **Hourly & 7-Day Forecast**: Visual forecasting cards powered by live WeatherAPI via backend proxy.
- **AI Chat with Gemini**: Real-time Gemini 3.7 Flash responses with 3.6 Flash fallback, rendering interactive weather cards and quick action chips.
- **Smart Weather Alerts**: Deterministic rule-based alerts evaluated from live weather observations.
- **Weather Advisories**: Contextual guidance across health, outdoor, travel, and general categories.
- **Climate Intelligence**: Historical temperature/rainfall baselines and anomaly calculations from the bundled dataset.
- **Multilingual UI (Tamil)**: Full dynamic switching to Tamil (`ta-IN`) across UI labels, weather descriptions, advisories, and chat.
- **Voice Capabilities**: Speech-to-text recognition and text-to-speech engine binding with graceful fallback.
- **Zero Startup/Navigation Crashes**: Verified in Android release mode.

### Phase 11 — Backend Deployment (Railway Live Status)

WeatherGPT backend is deployed and live in production on **Railway**:
- **Live Production Base URL**: `https://weathergpt-production-84b3.up.railway.app/api/v1`
- **Liveness / Health Probe**: `https://weathergpt-production-84b3.up.railway.app/api/v1/health`
- **Interactive Documentation**: `https://weathergpt-production-84b3.up.railway.app/docs`

#### Deployment Highlights [REAL — Phase 11]:
- **Containerized Execution**: Packaged via Python 3.11-slim `Dockerfile`, executing production Uvicorn without `--reload`, dynamically binding to `0.0.0.0:$PORT`.
- **Packaged Climate Reference Dataset**: Historical climatological dataset (`historical_weather.csv`, 528 records) bundled directly into the container image and verified at startup.
- **Strict Server-Side Secret Isolation**: WeatherAPI key and Gemini API key reside exclusively in Railway environment variables—never packaged into client binaries or exposed in headers.
- **Dual-Model Gemini AI in Production**: Primary model `gemini-3.7-flash` with automatic fallback to `gemini-3.6-flash`, operating behind the live HTTPS proxy with bounded retry.
- **CORS & Environment Configurations**: Configured regex allowing local Flutter Web development, Android emulator (`10.0.2.2`), and production web/mobile origins.
- **Centralized Flutter Configuration**: Flutter client uses `AppConfig` (`String.fromEnvironment('API_BASE_URL')`) which points to local development in debug mode and the live Railway HTTPS endpoint in release mode.

#### Feature Implementation Status Matrix:
- **Android Production Release APK**: **[REAL — Phase 12]** (`app-release.apk`, HTTPS Railway backend)
- **Live Backend HTTPS Deployment**: **[REAL — Phase 11]** (`https://weathergpt-production-84b3.up.railway.app`)
- **Real-time Weather & Forecast**: **[REAL — Phase 3 & 4]** (Live WeatherAPI.com)
- **Location Search & GPS**: **[REAL — Phase 4]** (Single source of truth via LocationProvider)
- **AI Conversational Chat**: **[REAL — Phase 5, 8, 10 & 11]** (Google Gemini 3.7 Flash + 3.6 Flash fallback, Bilingual)
- **Smart Alert Engine**: **[REAL — Phase 6 & 8]** (Deterministic rules, English & Tamil)
- **Weather Advisory System**: **[REAL — Phase 6 & 8]** (Rule-based templates, English & Tamil)
- **Climate Historical Trends**: **[REAL — Phase 7 & 8]** (Deterministic analysis from bundled dataset)
- **Tamil Localization**: **[REAL — Phase 8]** (Full UI and backend support)
- **Speech-to-Text / Voice (STT & TTS)**: **[REAL — Phase 9]** (English & Tamil voice interaction)
- **Interactive Chat & Reliability**: **[REAL — Phase 10]** (Cards, Quick Actions, Dual-Model Fallback, Deduplication)
- **User Authentication / Accounts**: **[PLANNED / FUTURE]**
- **Production APK / App Store Build**: **[PLANNED — Phase 12]**


WeatherGPT Phase 10 delivers rich interactive chat components, dual-model AI reliability, and enterprise-grade resilience:

- **Interactive Weather Cards [REAL — Phase 10]**:
  - `WeatherChatCard`: Compact summary card showing city, temperature, feels-like, condition, humidity, and wind.
  - `ForecastChatCard`: Structured hourly forecast strip showing time, temperature, condition icon, and rain probability.
  - Cards embedded directly into assistant chat bubbles when grounded weather data is available.
- **Contextual Quick Actions [REAL — Phase 10]**:
  - One-tap quick question chips for common queries ("Will it rain?", "What's the temperature?", etc.).
  - Full English and Tamil localization support.
  - Disabled during request processing to prevent accidental concurrent queries.
- **Active Location Indicator [REAL — Phase 10]**:
  - App bar badge displaying current active location with direct navigation to `LocationSearchScreen`.
- **Duplicate-Send Guard & Thinking State [REAL — Phase 10]**:
  - Dedicated thinking indicator ("WeatherGPT is checking the weather...").
  - Send button and input field disabled while a query is in-flight.
- **Dual-Model AI Fallback & Bounded Retry [REAL — Phase 10]**:
  - Primary model: `gemini-3.7-flash`, Fallback model: `gemini-3.6-flash`.
  - 1 bounded retry with 1.0s backoff on transient errors (503, 429, timeout).
  - Automatically switches to fallback model with identical grounded weather context if primary fails.
  - Differentiated error messages (busy, rate-limited, weather provider error, timeout).
- **API Deduplication & Query Normalization [REAL — Phase 10]**:
  - Coordinates rounded to 4 decimal places (~11m precision).
  - Cached forecast responses (30s TTL) cross-reused to fulfill current weather requests without extra API calls.

### Phase 9 — Voice Interaction (English & Tamil STT / TTS) Status

WeatherGPT features full voice interaction integrated directly into the conversational chat pipeline without changing prior phase behavior:

- **Speech-to-Text (STT) [REAL — Phase 9]**:
  - Powered by `speech_to_text: ^7.4.0`.
  - Mic button in chat input bar activates listening mode with live text population in the input field.
  - User can review/edit recognized text before sending (no forced auto-send).
  - Explicit stop and cancel controls.
- **Text-to-Speech (TTS) [REAL — Phase 9]**:
  - Powered by `flutter_tts: ^4.2.5`.
  - Each assistant chat bubble provides a clean `[🔊 Speak]` / `[Stop]` toggle button.
  - Automatically cleans Markdown syntax (asterisks, headings, links) for conversational audio clarity.
  - Automatically stops TTS when navigating away or initiating new voice input.
- **English & Tamil Voice Support [REAL — Phase 9]**:
  - Automatically aligns with the Phase 8 active language state (`en` → `en-US`, `ta` → `ta-IN`).
  - Fallback handling: If a device lacks Tamil voice recognition or synthesis, a clear banner/SnackBar is displayed while Tamil text chat remains 100% operational.
- **Android Permissions [REAL — Phase 9]**:
  - Added `android.permission.RECORD_AUDIO` and `RecognitionService` queries in `AndroidManifest.xml`.
  - Permission is requested only when the user explicitly taps the microphone button.

### Phase 8 — Multilingual (English & Tamil) Support Status

The Flutter application (`frontend/weathergpt_app/`) and FastAPI backend (`backend/weathergpt_api/`) now feature full bilingual capability supporting English (default, `en`) and Tamil (`ta`):

- **Persistent Language Selection [REAL — Phase 8]**:
  - Settings screen provides a dedicated Language section with immediate toggle between English and தமிழ்.
  - Persisted using `SharedPreferences` (`app_language_code`) and initialized at startup.
- **Flutter UI Localization [REAL — Phase 8]**:
  - Built with official `flutter_localizations` and ARB dictionaries (`lib/l10n/app_en.arb`, `lib/l10n/app_ta.arb`).
  - Human-authored translations for navigation, weather cards, alerts, advisories, climate intelligence, chat, and settings.
- **Bilingual Deterministic Engines [REAL — Phase 8]**:
  - Smart Alert Engine produces localized alerts (English & Tamil) based on requested language without using LLMs.
  - Advisory Service generates human-authored bilingual advisories and actionable recommendations.
  - Climate Intelligence computes deterministic insights with localized season names and summary templates.
  - Numerical values, thresholds, and units (`°C`, `%`, `km/h`, `mm`) strictly preserved across languages.
- **Language-Aware AI Chat [REAL — Phase 8]**:
  - Chat endpoint accepts `language` param (`en` or `ta`).
  - Gemini 3.7 Flash prompted in Tamil when selected, preserving strict factual weather grounding and numeric accuracy.

**Implementation Status Matrix**:

- **Real-time Weather & Forecast**: **[REAL — Phase 3 & 4]**
- **Location Search & GPS**: **[REAL — Phase 4]**
- **AI Conversational Chat**: **[REAL — Phase 5, 8 & 10]** (Google Gemini 3.7 Flash + 3.6 Flash fallback, Bilingual)
- **Smart Alert Engine**: **[REAL — Phase 6 & 8]** (Deterministic rules, English & Tamil)
- **Weather Advisory System**: **[REAL — Phase 6 & 8]** (Rule-based templates, English & Tamil)
- **Climate Historical Trends**: **[REAL — Phase 7 & 8]** (Deterministic calculations, English & Tamil)
- **Tamil Localization**: **[REAL — Phase 8]**
- **Speech-to-Text / Voice (STT & TTS)**: **[REAL — Phase 9]** (English & Tamil with graceful fallback)
- **Interactive Chat & Reliability**: **[REAL — Phase 10]** (Cards, Quick Actions, Dual-Model Fallback, Deduplication)

---

## Architecture

```
Flutter App (frontend/weathergpt_app/)
        ↓  REST / JSON
FastAPI Backend (backend/weathergpt_api/)
        ├── Weather Service      [REAL — Phase 3+]
        ├── AI Service (Gemini)  [REAL — Phase 10: 3.7 Flash + 3.6 Flash fallback]
        ├── Alert Engine         [REAL — Phase 6]
        ├── Advisory Service     [REAL — Phase 6]
        ├── Climate Service      [REAL — Phase 7]
        └── Localization Service [REAL — Phase 8]
              ↓
        External Weather Provider  [REAL]
        Gemini 3.7 Flash & 3.6 Flash [REAL — Phase 10]
        Historical Dataset (CSV)   [REAL — Reference]
```

The Flutter frontend communicates **only** with the FastAPI backend.  
The frontend must **never** call the weather provider or LLM provider directly.

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
│   └── weathergpt_app/        # Flutter application (Phase 4 integrated)
├── backend/
│   └── weathergpt_api/        # FastAPI application (Phase 3 complete)
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

The Flutter app requires the backend to be running to fetch live weather data.

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

## Implementation Status (Post-Phase 10)

| Component | Status |
|---|---|
| FastAPI Backend Core | ✅ Implemented |
| WeatherAPI.com Integration | ✅ Implemented (Current, Forecast, Hourly, Search, Alerts) |
| Flutter UI | ✅ Implemented |
| Flutter ↔ Backend Integration | ✅ Implemented (Phase 4 Complete) |
| WeatherGPT AI Chat (Gemini) | ✅ **REAL** — Phase 5, 8 & 10 Complete (Bilingual, Dual-Model Fallback) |
| Smart Alert Rule Engine | ✅ **REAL** — Phase 6 Complete (Bilingual in Phase 8) |
| Weather Advisories Engine | ✅ **REAL** — Phase 6 Complete (Bilingual in Phase 8) |
| Climate Intelligence & Reference Data | ✅ **REAL** — Phase 7 Complete (Bilingual in Phase 8) |
| Localization (Tamil) | ✅ **REAL** — Phase 8 Complete |
| Voice Interaction (STT & TTS) | ✅ **REAL** — Phase 9 Complete (`speech_to_text: 7.4.0`, `flutter_tts: 4.2.5`) |
| Interactive Chat & Reliability | ✅ **REAL** — Phase 10 Complete (Weather & Forecast Cards, Quick Actions, Dual-Model Fallback, Deduplication) |

**Important Note**: Weather, Forecast, Alerts, Advisories, AI Chat with Dual-Model Fallback, Climate Intelligence, Multilingual Support (English/Tamil), Voice Interaction (STT & TTS), and Interactive Weather Cards are fully implemented and verified.

---

## Security & Reliability

- API keys and secrets are **never** hardcoded.
- All secrets are loaded from environment variables via `.env` (strictly excluded from git).
- See `backend/weathergpt_api/.env.example` for required variables.
- **Dynamic Log Sanitization**: `SensitiveDataFilter` actively sanitizes all logs (including `httpx` and uvicorn output), replacing `?key=...`, `&key=...`, `api_key=...`, `x-goog-api-key`, and `Authorization: Bearer ...` headers with `***` to guarantee credentials never leak.
- **Dedicated Chat Timeout**: Flutter chat requests enforce a 60-second timeout (`AppConfig.chatApiTimeout`) to safely accommodate LLM generation latency, while standard endpoints maintain a 15-second timeout (`AppConfig.apiTimeout`).
- **Dual-Model Gemini Fallback**: Backend attempts primary `gemini-3.7-flash` with 1 bounded retry (1.0s backoff). On persistent transient failure, it falls back to `gemini-3.6-flash` using identical grounded weather context. Clean, distinct error messages are surfaced to the user.
- **API Deduplication & Query Normalization**: Coordinates are normalized to 4 decimal places, and cached forecast data (30s TTL) is reused across endpoints to fulfill current weather requests without extra API calls.
- **Phase 5 & 10**: `GEMINI_API_KEY` is exclusively stored in backend `.env`. Flutter never sends or receives it.
- The Flutter app only communicates with the FastAPI backend — never directly with Gemini or WeatherAPI.

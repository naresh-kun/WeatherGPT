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
| Phase 9 | Planned | Voice (STT/TTS) |

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
- **AI Conversational Chat**: **[REAL — Phase 5 & 8]** (Google Gemini 3.7 Flash in English & Tamil)
- **Smart Alert Engine**: **[REAL — Phase 6 & 8]** (Deterministic rules, English & Tamil)
- **Weather Advisory System**: **[REAL — Phase 6 & 8]** (Rule-based templates, English & Tamil)
- **Climate Historical Trends**: **[REAL — Phase 7 & 8]** (Deterministic calculations, English & Tamil)
- **Tamil Localization**: **[REAL — Phase 8]**
- **Speech-to-Text / Voice**: **[PLANNED — Phase 9]**

---

## Architecture

```
Flutter App (frontend/weathergpt_app/)
        ↓  REST / JSON
FastAPI Backend (backend/weathergpt_api/)
        ├── Weather Service      [REAL — Phase 3+]
        ├── AI Service (Gemini)  [REAL — Phase 5]
        ├── Alert Engine         [REAL — Phase 6]
        ├── Advisory Service     [REAL — Phase 6]
        ├── Climate Service      [REAL — Phase 7]
        └── Localization Service [PLANNED — Phase 8]
              ↓
        External Weather Provider  [REAL]
        Gemini 3.7 Flash           [REAL — Phase 5]
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

## Implementation Status (Post-Phase 8)

| Component | Status |
|---|---|
| FastAPI Backend Core | ✅ Implemented |
| WeatherAPI.com Integration | ✅ Implemented (Current, Forecast, Hourly, Search, Alerts) |
| Flutter UI | ✅ Implemented |
| Flutter ↔ Backend Integration | ✅ Implemented (Phase 4 Complete) |
| WeatherGPT AI Chat (Gemini) | ✅ **REAL** — Phase 5 Complete (Bilingual in Phase 8) |
| Smart Alert Rule Engine | ✅ **REAL** — Phase 6 Complete (Bilingual in Phase 8) |
| Weather Advisories Engine | ✅ **REAL** — Phase 6 Complete (Bilingual in Phase 8) |
| Climate Intelligence & Reference Data | ✅ **REAL** — Phase 7 Complete (Bilingual in Phase 8) |
| Localization (Tamil) | ✅ **REAL** — Phase 8 Complete |
| Voice Interaction | 🚧 Planned — Phase 9 |

**Important Note**: Weather, Forecast, Alerts, Advisories, AI Chat, Climate Intelligence, and Multilingual Support (English/Tamil) are fully integrated with live backend and reference data. Future phase will introduce voice interaction (Phase 9).

---

## Security & Reliability

- API keys and secrets are **never** hardcoded.
- All secrets are loaded from environment variables via `.env` (strictly excluded from git).
- See `backend/weathergpt_api/.env.example` for required variables.
- **Log Sanitization**: `SensitiveDataFilter` actively sanitizes all logs (including `httpx` and uvicorn output), replacing `?key=...`, `&key=...`, and secret values with `***` to guarantee credentials never leak.
- **Dedicated Chat Timeout**: Flutter chat requests use a 60-second timeout (`AppConfig.chatApiTimeout`) to safely accommodate LLM generation latency, while standard endpoints maintain a 15-second timeout (`AppConfig.apiTimeout`).
- **Gemini 503 Retry Strategy**: Backend handles transient Gemini 503 high-demand errors with 1 automatic retry (1.5s backoff), surfacing clean, distinct messages (`"WeatherGPT is temporarily busy. Please try again."`) to the user.
- **Deduplication Cache**: An in-memory 30-second TTL cache in `WeatherAPIClient` eliminates duplicate WeatherAPI calls during composite screen loads.
- **Phase 5**: `GEMINI_API_KEY` is exclusively stored in backend `.env`. Flutter never sends or receives it.
- The Flutter app only communicates with the FastAPI backend — never directly with Gemini or WeatherAPI.

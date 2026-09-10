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
| Phase 7+ | Planned | Climate Intelligence, Multilingual, Voice |

### Phase 6 — Smart Alerts & Advisories Status

The Flutter application (`frontend/weathergpt_app/`) and FastAPI backend (`backend/weathergpt_api/`) now feature a deterministic Smart Alert Engine and rule-based advisory system:

- **Smart Alert Engine [REAL — Phase 6]**:
  - Deterministic evaluation of current and forecast weather against configurable thresholds.
  - No LLM dependency for alert or advisory decisions.
  - Rules: Extreme Heat, Heavy Rain, Strong Wind, High UV, Thunderstorm (using structured WeatherAPI condition codes).
  - Merged with native WeatherAPI authority alerts without duplication.
- **Rule-Based Advisories [REAL — Phase 6]**:
  - Practical, contextual recommendations categorized by `general`, `health`, `outdoor`, `travel`, and `agriculture`.
  - Filter chips and detailed bottom sheet recommendations in Flutter UI.
- **Alerts & Advisory UI [REAL — Phase 6]**:
  - Flutter AlertsScreen and AdvisoryScreen display live backend data.
  - Observed weather metrics, thresholds, category badges, loading, empty, and retry states.

**Implementation Status Matrix**:

- **Real-time Weather & Forecast**: **[REAL — Phase 3 & 4]**
- **Location Search & GPS**: **[REAL — Phase 4]**
- **AI Conversational Chat**: **[REAL — Phase 5]** (Google Gemini 3.7 Flash)
- **Smart Alert Engine**: **[REAL — Phase 6]** (Deterministic rules & thresholds)
- **Weather Advisory System**: **[REAL — Phase 6]** (Rule-based templates & filters)
- **Climate Historical Trends**: **[MOCK — Phase 7 PLANNED]**
- **Tamil Localization**: **[PLANNED — Phase 8]**
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
        ├── Climate Service      [PLANNED — Phase 7]
        └── Localization Service  [PLANNED — Phase 8]
              ↓
        External Weather Provider  [REAL]
        Gemini 3.7 Flash           [REAL — Phase 5]
        Historical Dataset         [PLANNED]
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

## Implementation Status (Post-Phase 4)

| Component | Status |
|---|---|
| FastAPI Backend Core | ✅ Implemented |
| WeatherAPI.com Integration | ✅ Implemented (Current, Forecast, Hourly, Search, Alerts) |
| Flutter UI | ✅ Implemented |
| Flutter ↔ Backend Integration | ✅ Implemented (Phase 4 Complete) |
| WeatherGPT AI Chat (Gemini) | ✅ **REAL** — Phase 5 Complete |
| Smart Alert Rule Engine | 🚧 Planned — Phase 6 |
| Climate Analytics | 🚧 Planned — Phase 7 |
| Localization (Tamil) | 🚧 Planned — Phase 8 |
| Voice Interaction | 🚧 Planned — Phase 9 |

**Important Note**: The core weather features (Home, Forecast, Alerts, Search) are fully integrated with the real backend. Advanced features (Chat, Advisory, Climate) are currently mocked pending future phases.

---

## Security

- API keys and secrets are **never** hardcoded.
- All secrets are loaded from environment variables via `.env` (excluded from git).
- See `backend/weathergpt_api/.env.example` for required variables.
- **Phase 5**: `GEMINI_API_KEY` is exclusively stored in backend `.env`. Flutter never sends or receives it.
- The Flutter app only communicates with the FastAPI backend — never directly with Gemini or WeatherAPI.

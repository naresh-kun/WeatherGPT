# WeatherGPT API — Backend

FastAPI backend for the WeatherGPT conversational weather intelligence application.

---

## Setup

### Prerequisites
- Python 3.11+

### Install & Run

```bash
# 1. Create virtual environment
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS / Linux
source .venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment
cp .env.example .env
# Edit .env with your real values (do NOT commit this file)

# 4. Start the development server
uvicorn app.main:app --reload
```

The API will be available at:
- **Base URL**: `http://localhost:8000`
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **Health**: `http://localhost:8000/api/v1/health`

---

## Production Deployment (Railway) [Phase 11]

The backend is deployed to production on **Railway**:
- **Live Base URL**: `https://weathergpt-production-84b3.up.railway.app`
- **Live API Base**: `https://weathergpt-production-84b3.up.railway.app/api/v1`
- **Health Endpoint**: `https://weathergpt-production-84b3.up.railway.app/api/v1/health`
- **API Documentation**: `https://weathergpt-production-84b3.up.railway.app/docs`

### Production Architecture & Docker Setup
- **Base Image**: `python:3.11-slim`
- **Port Binding**: Dynamically binds to `0.0.0.0:${PORT}` provided by Railway (default `8080`).
- **Command**: `uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 2` (no `--reload`).
- **Packaged Data**: `data/climate/historical_weather.csv` (528 records) is copied into the image and verified at startup.

### Deploying via Railway CLI
```bash
# 1. Login to Railway
npx -y @railway/cli login

# 2. Link or create project
npx -y @railway/cli link e456a073-4f36-429d-b32d-afba91fd56ee

# 3. Configure environment variables (see below)
npx -y @railway/cli variable set WEATHER_API_KEY="..." GEMINI_API_KEY="..."

# 4. Deploy service
npx -y @railway/cli up -y
```


## Configuration

The backend requires the following environment variables (defined in `.env`):

- `WEATHER_API_KEY`: Your WeatherAPI.com API key.
- `WEATHER_BASE_URL`: Base URL for WeatherAPI (defaults to `https://api.weatherapi.com/v1`).
- `WEATHER_API_TIMEOUT`: HTTP request timeout in seconds (default `15`).
- `GEMINI_API_KEY`: Your Google Gemini API key (obtain at https://aistudio.google.com/). **[Phase 5]**
- `GEMINI_MODEL`: Primary Gemini model name (defaults to `gemini-3.7-flash`). **[Phase 10]**
- `GEMINI_FALLBACK_MODEL`: Fallback Gemini model name (defaults to `gemini-3.6-flash`). **[Phase 10]**

### Smart Alert Engine Thresholds (Phase 6 — Configurable via environment)
- `ALERT_HEAT_WARNING_C`: Temperature threshold for Heat Advisory (default: `38.0` °C)
- `ALERT_HEAT_DANGER_C`: Temperature threshold for Extreme Heat Alert (default: `42.0` °C)
- `ALERT_RAIN_WARNING_PCT`: Precipitation probability threshold for Heavy Rain Advisory (default: `70.0` %)
- `ALERT_WIND_WARNING_KPH`: Wind speed threshold for Strong Wind Advisory (default: `50.0` km/h)
- `ALERT_WIND_DANGER_KPH`: Wind speed threshold for Dangerous Wind Alert (default: `80.0` km/h)
- `ALERT_UV_WARNING_INDEX`: UV index threshold for High UV Advisory (default: `8.0`)
- `ALERT_UV_DANGER_INDEX`: UV index threshold for Extreme UV Alert (default: `11.0`)

**Never commit your `.env` file or API keys.**

The `GEMINI_API_KEY` is exclusively used by the backend — it is never sent to or accessible from the Flutter frontend.

---

## Reliability, Security & Error Handling

- **Log Sanitization**: `SensitiveDataFilter` (in `app/core/logging.py`) dynamically retrieves configured secrets and redacts query parameters (`?key=***`, `&key=***`, `api_key=***`), `x-goog-api-key`, Bearer headers, and configured secret tokens across all logging handlers.
- **Dual-Model Gemini Fallback & Bounded Retry**:
  - Primary model: `gemini-3.7-flash` (configurable via `GEMINI_MODEL`).
  - Fallback model: `gemini-3.6-flash` (configurable via `GEMINI_FALLBACK_MODEL`).
  - Automatically executes 1 retry with a 1.0-second backoff on transient errors (503 high demand, 429 rate limit, timeout).
  - If the primary model fails after retry, automatically invokes the fallback model with the exact same grounded weather context.
  - Permanent authentication errors (401/403) fail immediately without retrying or falling back.
- **Differentiated Error Statuses**:
  - Gemini 503: Returns 503 with `"WeatherGPT is temporarily busy. Please try again."`
  - Gemini 429: Returns 429 with `"WeatherGPT is temporarily rate-limited. Please try again later."`
  - WeatherAPI 503: Returns 503 with `"We're unable to retrieve current weather right now. Please try again."`
  - Gateway Timeout: Returns 504 with `"WeatherGPT is taking longer than expected. Please try again."`
  - Auth/Config errors: Returns 500 without leaking keys or raw stack traces.
- **AFC Elimination**: Automatic function calling (AFC) is explicitly disabled in the `google-genai` SDK configuration (`automatic_function_calling.disable = True`), eliminating unnecessary AFC deprecation warnings.
- **WeatherAPI Deduplication & Cache Reuse**:
  - Coordinate normalization: Latitude and longitude are rounded to 4 decimal places (~11m precision).
  - Cross-endpoint reuse: In-memory 30-second TTL cache reuses forecast responses to satisfy current weather and shorter-day forecast requests without duplicate external calls.

---

## Testing

Run tests using pytest (mocks the WeatherAPI client and Gemini SDK):

```bash
cd backend/weathergpt_api
.venv\Scripts\activate
pip install -r requirements.txt
pytest
```

Tests cover:
- All weather endpoints (current, forecast, hourly, search, alerts) (`tests/test_weather.py`)
- Smart Alert Engine rules, thresholds, deduplication, edge cases (`tests/test_alerts.py`)
- Advisory endpoint and category filtering (`tests/test_alerts.py`)
- Chat endpoint (valid requests, weather context, Gemini success/failure, validation) (`tests/test_chat.py`)
- Climate service, temperature & rainfall trends, baselines, anomalies, and insights (`tests/test_climate.py`)
- Multilingual support for Chat, Smart Alerts, Advisories, and Climate (`tests/test_multilingual.py`)
- Reliability, 503 retry, 429 rate limiting, log sanitization, and deduplication cache (`tests/test_reliability.py`)

---

## CORS Configuration

The API is configured to allow Cross-Origin Resource Sharing (CORS) for development environments.
It uses an `allow_origin_regex` to safely allow requests from:
- `localhost` and `127.0.0.1` on any port (for Flutter Web development).
- `10.0.2.2` on any port (for Android Emulator access).

---

## Project Structure

```
backend/weathergpt_api/
├── app/
│   ├── main.py               # FastAPI application entry point
│   ├── api/
│   │   ├── router.py         # Aggregates all route modules
│   │   └── routes/
│   │       ├── health.py     # GET /api/v1/health
│   │       ├── weather.py    # GET /api/v1/weather/current|forecast|...
│   │       ├── chat.py       # POST /api/v1/chat  [REAL — Phase 5]
│   │       ├── alerts.py     # GET /api/v1/alerts [REAL — Phase 6]
│   │       ├── advisory.py   # GET /api/v1/advisory [REAL — Phase 6]
│   │       └── climate.py    # GET /api/v1/climate [REAL — Phase 7]
│   ├── core/
│   │   ├── config.py         # Environment-based settings & alert thresholds (Pydantic)
│   │   ├── logging.py        # Structured logging setup
│   │   └── security.py       # Security utilities
│   ├── models/               # ORM models (future)
│   ├── schemas/              # Pydantic request/response schemas
│   │   ├── weather.py
│   │   ├── chat.py
│   │   ├── alerts.py
│   │   ├── advisory.py
│   │   └── climate.py        # Phase 7 Climate schemas
│   ├── services/
│   │   ├── weather/          # WeatherService + WeatherAPIClient  [REAL]
│   │   ├── ai/               # GeminiChatService (google-genai SDK) [REAL — Phase 5]
│   │   ├── alerts/           # AlertEngine deterministic rules [REAL — Phase 6]
│   │   ├── advisory/         # AdvisoryService deterministic templates [REAL — Phase 6]
│   │   ├── climate/          # ClimateService deterministic analysis [REAL — Phase 7]
│   │   └── localization/     # [PLANNED — Phase 8]
│   ├── chat_service.py       # Chat orchestrator (Weather → Gemini) [REAL — Phase 5]
│   └── repositories/         # Data access layer (future)
├── data/
│   └── climate/
│       └── historical_weather.csv  # Curated prototype/reference dataset (2000–2023)
├── tests/
│   ├── test_weather.py       # Weather endpoint tests
│   ├── test_chat.py          # Chat endpoint tests [Phase 5]
│   ├── test_alerts.py        # Alert & advisory tests [Phase 6]
│   └── test_climate.py       # Climate analysis & endpoint tests [Phase 7]
├── .env.example              # Required environment variables (no real secrets)
├── requirements.txt
└── README.md
```

---

## API Endpoints

| Method | Path | Description | Status |
|---|---|---|---|
| GET | `/api/v1/health` | Liveness probe | REAL |
| GET | `/api/v1/weather/current` | Current weather | REAL |
| GET | `/api/v1/weather/forecast` | Multi-day forecast | REAL |
| POST | `/api/v1/chat` | Conversational weather query (text & Phase 9 voice pipeline) | REAL |
| GET | `/api/v1/alerts` | Active weather alerts | REAL |
| GET | `/api/v1/advisory` | Weather-based advisories | REAL |
| GET | `/api/v1/climate` | Historical climate intelligence & analysis | REAL (Reference Data) |
| GET | `/api/v1/climate/trends` | Historical climate trends (convenience) | REAL (Reference Data) |

> **Dataset Notice**: The historical weather dataset (`data/climate/historical_weather.csv`) is explicitly a prototype/reference dataset derived from representative climatological summaries for Tamil Nadu cities (`Madurai`, `Chennai`, `Coimbatore`, `Tirunelveli`). It is not an official live meteorological feed.

See [`../../docs/api/API_CONTRACT.md`](../../docs/api/API_CONTRACT.md) for the full API specification.

---

## Ownership

This directory is owned by the **Backend Developer**.  
The Frontend Developer must not modify files in `backend/`.

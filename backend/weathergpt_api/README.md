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

## Configuration

The backend requires the following environment variables (defined in `.env`):

- `WEATHER_API_KEY`: Your WeatherAPI.com API key.
- `WEATHER_BASE_URL`: Base URL for WeatherAPI (defaults to `https://api.weatherapi.com/v1`).
- `WEATHER_API_TIMEOUT`: HTTP request timeout in seconds (default `15`).

**Never commit your `.env` file or API keys.**

---

## Testing

Run tests using pytest (mocks the WeatherAPI client):

```bash
cd backend/weathergpt_api
.venv\Scripts\activate
pip install -r requirements.txt
pytest
```

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
│   │       ├── weather.py    # GET /api/v1/weather/current|forecast
│   │       ├── chat.py       # POST /api/v1/chat
│   │       ├── alerts.py     # GET /api/v1/alerts
│   │       ├── advisory.py   # GET /api/v1/advisory
│   │       └── climate.py    # GET /api/v1/climate/trends
│   ├── core/
│   │   ├── config.py         # Environment-based settings (Pydantic)
│   │   ├── logging.py        # Structured logging setup
│   │   └── security.py       # Security utilities (placeholder)
│   ├── models/               # ORM models (future)
│   ├── schemas/              # Pydantic request/response schemas
│   │   ├── weather.py
│   │   ├── chat.py
│   │   ├── alerts.py
│   │   ├── advisory.py
│   │   └── climate.py
│   ├── services/             # Business logic (stubs)
│   │   ├── weather/
│   │   ├── ai/
│   │   ├── alerts/
│   │   ├── advisory/
│   │   ├── climate/
│   │   └── localization/
│   └── repositories/         # Data access layer (future)
├── tests/
├── .env.example              # Required environment variables (no real secrets)
├── requirements.txt
└── README.md
```

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/health` | Liveness probe |
| GET | `/api/v1/weather/current` | Current weather |
| GET | `/api/v1/weather/forecast` | Multi-day forecast |
| POST | `/api/v1/chat` | Conversational weather query |
| GET | `/api/v1/alerts` | Active weather alerts |
| GET | `/api/v1/advisory` | Weather-based advisories |
| GET | `/api/v1/climate/trends` | Historical climate trends |

See [`../../docs/api/API_CONTRACT.md`](../../docs/api/API_CONTRACT.md) for the full API specification.

---

## Ownership

This directory is owned by the **Backend Developer**.  
The Frontend Developer must not modify files in `backend/`.

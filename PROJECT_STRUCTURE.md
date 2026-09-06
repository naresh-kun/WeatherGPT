Create the initial project structure for a two-person software project named **WeatherGPT**.

## Project
WeatherGPT is a conversational weather intelligence prototype providing:
- real-time weather
- forecasts
- conversational weather queries
- smart weather alerts
- weather-based advisories
- historical climate trends
- multilingual support
- voice interaction

The project has exactly two developers:

1. **Frontend Developer**
   - Owns Flutter development.
2. **Backend Developer**
   - Owns FastAPI backend development.

The two applications must be completely separated and communicate through a documented REST API using JSON.

---

# 1. Repository structure

Create this root structure:

```text
WeatherGPT/
├── frontend/
│   └── weathergpt_app/
├── backend/
│   └── weathergpt_api/
├── docs/
│   ├── architecture/
│   └── api/
├── data/
│   ├── historical/
│   └── sample/
├── .gitignore
├── README.md
└── LICENSE
```

Do not add unnecessary technologies or services.

---

# 2. Frontend structure

Inside:

```text
frontend/weathergpt_app/
```

create a Flutter project structure containing:

```text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── errors/
├── models/
├── services/
│   ├── api/
│   ├── location/
│   ├── voice/
│   └── storage/
├── repositories/
├── providers/
├── navigation/
├── screens/
│   ├── splash/
│   ├── home/
│   ├── chat/
│   ├── forecast/
│   ├── alerts/
│   ├── advisory/
│   ├── climate/
│   └── settings/
├── widgets/
│   ├── weather/
│   ├── chat/
│   ├── alerts/
│   ├── advisory/
│   ├── climate/
│   └── common/
└── main.dart

assets/
├── images/
├── icons/
└── animations/

test/
```

Create only the required placeholder files needed to establish the structure.

Do not implement the actual UI.

Do not implement API integration yet.

Do not add business logic yet.

---

# 3. Backend structure

Inside:

```text
backend/weathergpt_api/
```

create:

```text
app/
├── api/
│   ├── routes/
│   │   ├── health.py
│   │   ├── weather.py
│   │   ├── chat.py
│   │   ├── alerts.py
│   │   ├── advisory.py
│   │   └── climate.py
│   └── router.py
├── core/
│   ├── config.py
│   ├── logging.py
│   └── security.py
├── models/
├── schemas/
│   ├── weather.py
│   ├── chat.py
│   ├── alerts.py
│   ├── advisory.py
│   └── climate.py
├── services/
│   ├── weather/
│   ├── ai/
│   ├── alerts/
│   ├── advisory/
│   ├── climate/
│   └── localization/
├── repositories/
└── main.py

tests/

.env.example
requirements.txt
README.md
```

Do not implement the complete services yet.

Do not connect an external weather API yet.

Do not connect an LLM yet.

Do not create database infrastructure unless required by the structure.

---

# 4. API contract

Create:

```text
docs/api/API_CONTRACT.md
```

Document the initial REST API:

```text
GET  /api/v1/health
GET  /api/v1/weather/current
GET  /api/v1/weather/forecast
POST /api/v1/chat
GET  /api/v1/alerts
GET  /api/v1/advisory
GET  /api/v1/climate/trends
```

For every endpoint document:

- purpose
- HTTP method
- parameters
- request body
- response JSON
- possible errors
- example request
- example response

Use JSON for all API communication.

---

# 5. Core conceptual data models

Document the following conceptual models in:

```text
docs/api/DATA_MODELS.md
```

Models:

```text
Location
WeatherCurrent
HourlyForecast
DailyForecast
WeatherForecast
ChatRequest
ChatResponse
Conversation
Alert
Advisory
ClimateTrend
```

The frontend and backend will implement their own versions of these models.

They must follow the same API contract.

---

# 6. Architecture documentation

Create:

```text
docs/architecture/ARCHITECTURE.md
```

Document this architecture:

```text
Flutter
   ↓
REST/JSON
   ↓
FastAPI
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

Document that the frontend must never directly call the weather provider or LLM provider.

---

# 7. Ownership rules

Document in the root README:

### Frontend developer owns:
```text
frontend/
```

### Backend developer owns:
```text
backend/
```

### Shared:
```text
docs/
README.md
```

### Restrictions:

Frontend developer must not modify backend implementation.

Backend developer must not modify Flutter implementation.

Both developers must use the API contract as the integration boundary.

---

# 8. Data flow documentation

Document these flows:

### Weather
Flutter → FastAPI → Weather Provider → FastAPI → Flutter

### Chat
Flutter → FastAPI → intent understanding → weather tool/data retrieval → LLM → Flutter

### Alerts
Weather data → rule engine → alert → Flutter

### Advisory
Weather data → advisory rules/service → Flutter

### Climate
Historical dataset → climate service → trend calculation → Flutter charts

### Voice
Speech-to-text → chat API → response → text-to-speech

### Multilingual
Flutter language selection → backend language parameter → localized AI response → Flutter

---

# 9. Security rules

Create `.env.example` in backend containing placeholders such as:

```env
WEATHER_API_KEY=
LLM_API_KEY=
WEATHER_BASE_URL=
```

Do not create a real `.env`.

Ensure `.gitignore` excludes:

```text
.env
.venv/
__pycache__/
.dart_tool/
build/
.idea/
.vscode/
*.log
```

Never hardcode API secrets.

---

# 10. Git documentation

Document the recommended branches:

```text
main
develop
```

Feature branches:

```text
feature/frontend-*
feature/backend-*
```

Explain that frontend and backend work should remain isolated.

---

# 11. Important restrictions

This task is ONLY for initial project architecture and structure.

Do NOT:

- implement WeatherGPT
- implement the weather API
- implement the LLM
- implement alert logic
- implement advisory logic
- implement climate calculations
- implement authentication
- implement database infrastructure
- implement MQTT
- implement WIS2
- implement Kubernetes
- implement NWP/WRF/GFS
- implement satellite processing
- build the Flutter screens
- create complex business logic

Do not invent additional architecture that is not required.

Prefer a simple, modular architecture suitable for an SIH prototype.

---

# 12. Final verification

After creating the structure:

1. Verify all directories exist.
2. Verify Flutter project can be initialized successfully.
3. Verify FastAPI project structure is valid.
4. Verify Python imports are organized correctly.
5. Verify no secret files were created.
6. Verify README explains developer ownership.
7. Verify API contract document exists.
8. Verify data model document exists.
9. Verify architecture document exists.
10. Report the final directory tree.

Do not make additional feature changes after the structure is complete.
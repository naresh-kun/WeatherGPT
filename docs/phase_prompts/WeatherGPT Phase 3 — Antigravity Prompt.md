# WeatherGPT — Phase 3: Weather API + FastAPI Backend

You are working on the **WeatherGPT SIH prototype**.

## Project Context

WeatherGPT is a conversational AI weather application being built as a **decent-looking, functional SIH prototype**, not a production-scale meteorological platform.

Phase 1 — Foundation is complete.

Phase 2 — Flutter UI is complete and uses centralized mock data.

Your task is now:

> **Phase 3 — Weather API + FastAPI Backend**

The objective is to replace the backend scaffold's placeholder weather routes with a clean, working weather service backed by a real external weather API.

---

# IMPORTANT SCOPE

This phase is focused on the **backend weather-data layer only**.

Implement:

- Real current weather retrieval
- Real forecast retrieval
- Real hourly weather retrieval
- Location/city search
- Real weather-alert retrieval where supported by the provider
- Backend response models
- Weather-service abstraction
- Configuration through environment variables
- Backend error handling
- Backend tests
- API documentation updates

Do NOT implement:

- LLM / WeatherGPT AI
- Chat orchestration
- Smart alert rule engine
- Farming advisory calculations
- Travel advisory calculations
- Climate analysis
- Historical climate processing
- Flutter integration
- GPS on Flutter
- STT/TTS
- Authentication
- PostgreSQL migration
- WebSockets
- Docker/Kubernetes
- Any production-scale infrastructure

Do not modify the Flutter implementation except documentation if absolutely necessary.

---

# WEATHER PROVIDER

Use:

**WeatherAPI.com**

The provider currently supports realtime weather, forecast data, hourly intervals, location search/autocomplete, and weather alerts.

Use the WeatherAPI REST/JSON interface.

Relevant provider endpoints include:

- `/current.json`
- `/forecast.json`
- `/search.json`
- `/alerts.json`

The forecast API can return up to 14 days depending on the account/plan; our prototype only needs the project's documented forecast range. WeatherAPI also supports alert data through its forecast/alerts APIs.

Do not expose the provider directly to Flutter.

Architecture must remain:

Flutter
↓
FastAPI
↓
Weather Service
↓
WeatherAPI.com

---

# FIRST STEP — INSPECT BEFORE MODIFYING

Before writing code:

1. Inspect the existing backend structure.
2. Inspect:
   - `README.md`
   - `backend/weathergpt_api/README.md`
   - `docs/api/API_CONTRACT.md`
   - `docs/api/DATA_MODELS.md`
   - `docs/architecture/ARCHITECTURE.md`
3. Inspect the existing:
   - FastAPI routes
   - schemas
   - configuration
   - tests
   - environment example
4. Determine exactly what Phase 1 already created.
5. Preserve the existing architecture wherever practical.

Do NOT blindly recreate files that already exist.

---

# BACKEND ROOT

Backend project:

`backend/weathergpt_api/`

Use the existing FastAPI structure.

Prefer the existing organization:

```text
app/
├── api/
├── core/
├── models/
├── repositories/
├── schemas/
└── services/
```

Keep weather-provider-specific code inside the weather service area rather than placing provider calls directly in route files.

---

# 1. CONFIGURATION

Use the existing Pydantic settings/configuration system.

Add the WeatherAPI configuration required by the implementation.

At minimum, provide configuration for:

- WeatherAPI base URL
- WeatherAPI API key
- Request timeout

Do NOT hardcode secrets.

Use environment variables.

Update:

`backend/weathergpt_api/.env.example`

with placeholder values only.

Example conceptually:

```env
WEATHER_API_BASE_URL=...
WEATHER_API_KEY=...
WEATHER_API_TIMEOUT=...
```

Use the existing naming conventions from the project wherever possible.

Do not create a real `.env` file containing credentials.

---

# 2. HTTP CLIENT

Implement a clean HTTP client for communicating with WeatherAPI.

Use an appropriate maintained Python HTTP library already present in the project or add a minimal dependency only when necessary.

Requirements:

- Configurable timeout
- Proper exception handling
- HTTP status handling
- JSON parsing
- Clean separation from FastAPI routes
- No duplicated request code

Do not put raw provider requests directly into every endpoint.

---

# 3. WEATHER SERVICE

Implement the weather service under the existing service structure.

The weather service should provide application-level operations such as:

- get current weather
- get forecast
- get hourly forecast
- search locations
- get weather alerts

The route layer should call the service layer.

The service layer should communicate with the provider client.

Keep the design modular so the provider could be replaced later without rewriting the entire API.

Suggested conceptual flow:

```text
FastAPI Route
      ↓
Weather Service
      ↓
WeatherAPI Client
      ↓
WeatherAPI.com
```

---

# 4. CURRENT WEATHER

Implement the existing:

`GET /api/v1/weather/current`

Use a location query parameter consistent with the existing API contract.

Support at least:

- City/location text
- Latitude/longitude where the contract requires or allows it

Retrieve real weather data.

Return application-defined response data rather than leaking the entire WeatherAPI response.

Data should cover the fields needed by the current Flutter UI, including where available:

- Location
- Temperature
- Feels-like temperature
- Weather condition
- Humidity
- Wind speed
- Wind direction
- Rain/precipitation-related information
- UV index
- Last updated time

Map provider data into our own schema.

Do not make Flutter dependent on WeatherAPI.com's exact response structure.

---

# 5. FORECAST

Implement the existing forecast route specified by:

`docs/api/API_CONTRACT.md`

Return a normalized forecast structure.

Support the project's required forecast range.

Include:

### Daily information

- Date
- Weather condition
- High temperature
- Low temperature
- Average temperature where useful
- Rain probability
- Precipitation
- Maximum wind
- UV where available

### Hourly information

- Time
- Temperature
- Feels-like/apparent temperature where useful
- Condition
- Rain probability
- Precipitation
- Wind speed
- UV where available

Do not return unnecessarily huge provider payloads.

Return only application-relevant fields.

---

# 6. HOURLY FORECAST

Implement the existing:

`GET /api/v1/weather/hourly`

Return normalized hourly information.

The response should be suitable for the Flutter hourly forecast UI created in Phase 2.

The frontend currently expects information such as:

- Time
- Temperature
- Weather icon/condition
- Rain probability

Additional useful weather values may be included where already defined by the API contract.

---

# 7. LOCATION SEARCH

Implement the existing location-search functionality from the project API contract.

Use WeatherAPI's location search/autocomplete capability.

Return normalized location information such as:

- Location name
- Region/state
- Country
- Latitude
- Longitude
- Time zone where useful

Do not expose unnecessary provider fields.

This will later support:

- City search
- Location selection
- Multiple locations
- Future GPS-coordinate queries

---

# 8. WEATHER ALERTS

Implement the existing:

`GET /api/v1/weather/alerts`

At this stage, this means **provider-sourced weather alerts**, not our future rule-based smart-alert engine.

WeatherAPI supports alert data issued by government agencies and exposes fields such as severity, urgency, event, effective time, expiry, description, and instructions.

Normalize the provider alerts into the project's application schema.

Include, where available:

- Title/headline
- Severity
- Urgency
- Event
- Category
- Affected area
- Effective time
- Expiry time
- Description
- Instructions

If the provider returns no active alerts, return a valid empty result.

Do not fabricate alerts.

Do not implement thresholds such as:

```text
rain_probability > X → alert
```

That belongs to **Phase 6**.

---

# 9. RESPONSE SCHEMAS

Use the existing Pydantic schemas.

Update or complete them where necessary.

Keep schemas aligned with:

`docs/api/DATA_MODELS.md`

Do not unnecessarily duplicate equivalent models.

Use explicit types and nullability.

Make the application response models stable even if the external provider changes.

---

# 10. ERROR HANDLING

Implement clean error handling.

Handle at minimum:

### Invalid location

Return an appropriate client-facing error.

### Invalid API key

Return a controlled server/configuration error.

Do not expose the API key.

### Provider unavailable

Return an appropriate service-unavailable response.

### Provider timeout

Return a controlled timeout/service error.

### Malformed/unexpected provider response

Handle safely and log enough information for debugging without leaking secrets.

### Empty alert response

Return an empty list/result rather than an exception.

Do not expose raw stack traces to API consumers.

---

# 11. LOGGING

Use the existing logging system.

Log useful backend information such as:

- Endpoint being called
- Requested location
- Provider request failure
- Timeout
- Provider HTTP status

Do NOT log:

- API keys
- Secrets
- Authorization headers
- Sensitive credentials

Avoid excessive noisy logging.

---

# 12. CACHING

Do NOT implement a complex distributed caching system.

A cache is optional at this phase.

If you choose not to implement caching, explicitly document that it is deferred.

Do not introduce Redis or another infrastructure component just for this prototype.

---

# 13. RATE LIMITING

Do not build a custom production rate-limiting system in this phase.

However:

- Handle provider HTTP errors gracefully.
- Avoid unnecessary duplicate provider requests within a single API operation.

Document production rate limiting as future work if appropriate.

---

# 14. TESTING

Create or update backend tests.

Test the application layer without requiring a real WeatherAPI key where possible.

Mock external provider calls.

At minimum test:

### Current Weather

- Successful response
- Invalid location
- Provider failure
- Timeout

### Forecast

- Successful response
- Correct mapping
- Provider failure

### Hourly

- Correct response mapping

### Location Search

- Successful search
- Empty result
- Provider failure

### Alerts

- Alerts returned
- No alerts
- Provider failure

### Configuration

Ensure missing/invalid required configuration is handled appropriately.

Do not make the core test suite dependent on live external API calls.

Optional:

Create a separate manual/integration test instruction for testing against a real WeatherAPI key.

---

# 15. MANUAL API VERIFICATION

After implementation, run the FastAPI application and verify:

```text
GET /api/v1/health
```

still returns:

```json
{
  "status": "ok"
}
```

Then verify each weather endpoint using:

- Swagger UI
- curl/http client
- or another suitable method

Test with a real location such as:

`Madurai, Tamil Nadu`

when a valid WeatherAPI key is available.

Do not commit the key.

---

# 16. API CONTRACT COMPATIBILITY

The file:

`docs/api/API_CONTRACT.md`

is the existing contract.

Do not casually redesign its endpoints.

Before changing a route:

1. Read the current contract.
2. Preserve existing route names where possible.
3. Preserve documented request/response semantics.
4. Only make changes where the existing scaffold is incomplete or incompatible with the actual Phase 3 implementation.

If a contract change is genuinely necessary:

- update the contract
- document the change clearly
- ensure the frontend Phase 2 structure remains compatible or note the future integration impact

Do not invent unrelated APIs.

---

# 17. FRONTEND BOUNDARY

Flutter is NOT being connected in this phase.

Do not implement HTTP calls from Flutter.

Do not remove the Phase 2 mock-data architecture.

Do not redesign the Flutter screens.

The backend should simply become ready for Phase 4.

---

# 18. DOCUMENTATION UPDATE — MANDATORY

This is a strict requirement.

After implementation, update all relevant documentation.

Documentation must describe the **actual state of the repository after Phase 3**.

At minimum, review:

### Root README

Update:

- Phase 3 completion
- Backend weather integration status
- Current implementation status
- What remains mocked
- What is deferred

Clearly state that:

- Backend weather data is now real
- Flutter still uses Phase 2 mock data
- AI is not implemented
- Smart alert/advisory logic is not implemented

### Backend README

Update:

- WeatherAPI integration
- Required environment variables
- How to run FastAPI
- Available weather endpoints
- Testing instructions
- Error handling
- Provider dependency

### API Contract

Update:

`docs/api/API_CONTRACT.md`

to accurately describe:

- Implemented endpoints
- Request parameters
- Response structures
- Error behavior
- Provider-backed weather operations

Do not document endpoints that do not exist.

### Data Models

Update:

`docs/api/DATA_MODELS.md`

to reflect the actual backend response models.

### Architecture

Update:

`docs/architecture/ARCHITECTURE.md`

to show the real Phase 3 flow:

```text
Flutter
   ↓
FastAPI
   ↓
Weather Service
   ↓
WeatherAPI.com
```

Clearly distinguish Phase 2 mock data from Phase 3 backend data.

---

# 19. DOCUMENTATION ACCURACY RULE

This rule is mandatory.

Never write:

> "Implemented"

unless the functionality actually exists and has been tested.

Use clear states:

### Implemented

Actually working and verified.

### Mocked

Currently using local/dummy data.

### Planned

Future phase.

For example:

```text
Weather API → Implemented in backend
Flutter weather API integration → Planned for Phase 4
LLM → Planned for Phase 5
Smart alerts → Planned for Phase 6
Climate backend → Planned for Phase 7
Tamil localization → Planned for Phase 8
Voice → Planned for Phase 9
```

---

# 20. SECURITY

Do not:

- Commit API keys
- Create a real `.env`
- Print secrets in logs
- Return secrets in API responses
- Hardcode provider credentials
- Commit temporary credential files

Check `.gitignore` before finishing.

---

# 21. DO NOT OVER-ENGINEER

This is a prototype.

Do not introduce:

- Microservices
- Redis
- Kafka
- Celery
- Kubernetes
- Docker
- PostgreSQL
- Complex dependency injection frameworks
- Complex event buses
- Distributed caches

unless something already present in the repository genuinely requires it.

A clean FastAPI service architecture is enough.

---

# 22. BACKWARD COMPATIBILITY

Ensure the existing Phase 1 endpoint still works:

```text
GET /api/v1/health
```

Do not break existing application startup.

The following must continue to work:

```bash
cd backend/weathergpt_api
.venv\Scripts\activate
uvicorn app.main:app --reload
```

and:

```text
http://localhost:8000/docs
```

---

# 23. FINAL VERIFICATION CHECKLIST

Before reporting completion, verify:

### Backend startup

- FastAPI starts successfully
- Swagger loads
- Health endpoint works

### Weather

- Current weather works
- Forecast works
- Hourly forecast works
- Location search works
- Weather alerts work or correctly return an empty result

### Errors

- Invalid location handled
- Provider failure handled
- Timeout handled
- Configuration problems handled

### Tests

Run the complete backend test suite.

### Security

Confirm:

- No secrets committed
- No API key hardcoded
- `.env` not created/committed

### Documentation

Confirm relevant `.md` files are updated.

---

# 24. FINAL REPORT

After completing the task, provide a concise report containing:

## Implemented

Actual functionality implemented.

## Files Created/Modified

Important backend files.

## API Provider

Confirm the provider used.

## Endpoints

List the implemented endpoints.

## Configuration

Explain required environment variables without exposing credentials.

## Tests

Report test results.

## Manual Verification

Report which endpoints were manually tested.

## Documentation Updated

List every `.md` file modified.

## Deferred

Explicitly list features remaining for later phases:

- Flutter ↔ backend integration
- WeatherGPT LLM
- Smart alert rules
- Advisories
- Climate intelligence
- Tamil localization
- Voice
- GPS
- Production-scale infrastructure

## Known Issues

List only genuine remaining issues or limitations.

---

# MOST IMPORTANT RULES

1. This is **Phase 3 only**.
2. Implement real weather retrieval in FastAPI.
3. Use **WeatherAPI.com** as the external provider.
4. Keep provider-specific logic inside the backend service/client layer.
5. Do not connect Flutter yet.
6. Do not implement LLM or smart advisory logic.
7. Do not implement infrastructure that the prototype does not need.
8. Never hardcode secrets.
9. Mock external calls in automated tests.
10. Preserve the existing API contract where possible.
11. **Update the relevant `.md` files after implementation.**
12. Documentation must accurately distinguish implemented, mocked, and planned functionality.
13. Verify the implementation before reporting completion.

Start by inspecting the current backend code and documentation, then implement Phase 3 systematically.
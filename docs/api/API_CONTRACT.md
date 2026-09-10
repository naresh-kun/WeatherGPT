# WeatherGPT — REST API Contract

**Version**: 0.1.0  
**Base URL**: `http://localhost:8000/api/v1`  
**Format**: All requests and responses use `application/json`.

This document is the single source of truth for the integration boundary between the Flutter frontend and the FastAPI backend. Both developers must agree before making any changes.

> **Frontend integration status (Phase 4+5)**: Weather endpoints fully integrated. Chat endpoint integrated as of Phase 5.
> **Backend implementation status (Phase 3+5)**: Weather endpoints (`/current`, `/forecast`, `/hourly`, `/search`, `/alerts`) are fully implemented. **`POST /chat` is real as of Phase 5** — powered by Google Gemini 3.7 Flash with real weather grounding.

---

## Table of Contents

1. [GET /health](#1-get-health)
2. [GET /weather/current](#2-get-weathercurrent)
3. [GET /weather/forecast](#3-get-weatherforecast)
4. [GET /weather/hourly](#4-get-weatherhourly)
5. [GET /weather/search](#5-get-weathersearch)
6. [POST /chat](#6-post-chat)
7. [GET /alerts](#7-get-alerts)
8. [GET /advisory](#8-get-advisory)
9. [GET /climate/trends](#9-get-climatetrends)
10. [Error Responses](#10-error-responses)

---

## 1. GET /health

### Purpose
Liveness and readiness probe. Used by load balancers, orchestration systems, and the frontend to confirm the backend is reachable.

### HTTP Method
`GET`

### Parameters
None.

### Request Body
None.

### Response JSON
```json
{
  "status": "ok",
  "service": "weathergpt-api"
}
```

| Field | Type | Description |
|---|---|---|
| `status` | string | `"ok"` when healthy |
| `service` | string | Service identifier |

### Possible Errors
| Status | Description |
|---|---|
| `503 Service Unavailable` | Backend is not healthy |

### Example Request
```bash
curl http://localhost:8000/api/v1/health
```

### Example Response
```json
{
  "status": "ok",
  "service": "weathergpt-api"
}
```

---

## 2. GET /weather/current

### Purpose
Returns real-time current weather conditions for a geographic coordinate.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude (-90 to 90) |
| `lon` | float | Yes | — | Longitude (-180 to 180) |
| `units` | string | No | `metric` | `metric` \| `imperial` \| `standard` |

### Request Body
None.

### Response JSON
```json
{
  "location": {
    "lat": 28.6139,
    "lon": 77.2090,
    "city": "New Delhi",
    "country": "IN",
    "timezone": "Asia/Kolkata"
  },
  "temperature": 32.4,
  "feels_like": 36.1,
  "humidity": 60,
  "wind_speed": 4.2,
  "wind_direction": 220,
  "description": "Partly cloudy",
  "icon": "02d",
  "uv_index": 7.2,
  "visibility": 10.0,
  "timestamp": 1756137600
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Invalid coordinates |
| `503 Service Unavailable` | Weather provider unreachable |

### Example Request
```bash
curl "http://localhost:8000/api/v1/weather/current?lat=28.6139&lon=77.2090&units=metric"
```

---

## 3. GET /weather/forecast

### Purpose
Returns a multi-day weather forecast (hourly + daily) for a geographic coordinate.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude (-90 to 90) |
| `lon` | float | Yes | — | Longitude (-180 to 180) |
| `days` | int | No | `7` | Number of forecast days (1–16) |
| `units` | string | No | `metric` | `metric` \| `imperial` \| `standard` |

### Request Body
None.

### Response JSON
```json
{
  "location": { "lat": 28.6139, "lon": 77.2090, "city": "New Delhi", "country": "IN", "timezone": "Asia/Kolkata" },
  "units": "metric",
  "hourly": [
    {
      "timestamp": 1756137600,
      "temperature": 32.4,
      "feels_like": 36.1,
      "humidity": 60,
      "wind_speed": 4.2,
      "description": "Partly cloudy",
      "icon": "02d",
      "precipitation_probability": 0.1
    }
  ],
  "daily": [
    {
      "date": "2026-09-07",
      "temp_min": 26.0,
      "temp_max": 35.0,
      "humidity": 65,
      "wind_speed": 5.0,
      "description": "Mostly sunny",
      "icon": "01d",
      "sunrise": 1756100400,
      "sunset": 1756145000,
      "precipitation_probability": 0.05
    }
  ]
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Invalid parameters |
| `503 Service Unavailable` | Weather provider unreachable |

### Example Request
```bash
curl "http://localhost:8000/api/v1/weather/forecast?lat=28.6139&lon=77.2090&days=7"
```

## 4. GET /weather/hourly

### Purpose
Returns an hourly weather forecast for a geographic coordinate.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude (-90 to 90) |
| `lon` | float | Yes | — | Longitude (-180 to 180) |
| `limit` | int | No | `24` | Number of hours to return |

### Response JSON
```json
[
  {
    "timestamp": 1756137600,
    "temperature": 32.4,
    "feels_like": 36.1,
    "humidity": 60,
    "wind_speed": 4.2,
    "description": "Partly cloudy",
    "icon": "02d",
    "precipitation_probability": 0.1
  }
]
```

---

## 5. GET /weather/search

### Purpose
Searches for locations by name, returning coordinates.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `q` | string | Yes | — | Search query |

### Response JSON
```json
[
  {
    "name": "Madurai",
    "region": "Tamil Nadu",
    "country": "India",
    "lat": 9.93,
    "lon": 78.12,
    "url": "madurai-tamil-nadu-india"
  }
]
```

---

## 6. POST /chat

> **Implementation status**: **[REAL — Phase 5]** — powered by Google Gemini 3.7 Flash grounded in real-time WeatherAPI data. The Gemini API key is backend-only and never exposed to the client.

### Purpose
Accepts a natural-language weather query from the user, fetches real-time weather for the provided location via WeatherService, and generates a conversational AI response via Google Gemini.

### HTTP Method
`POST`

### Parameters
None (body-only).

### Request Body
```json
{
  "message": "Will it rain in Mumbai tomorrow?",
  "conversation_id": "conv-abc123",
  "language": "en",
  "location": { "lat": 19.0760, "lon": 72.8777 },
  "voice": false
}
```

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `message` | string | Yes | — | User's natural-language query |
| `conversation_id` | string | No | `null` | ID to continue a conversation |
| `language` | string | No | `"en"` | BCP-47 language tag |
| `location` | object | No | `null` | `{lat, lon}` location context |
| `voice` | boolean | No | `false` | Optimise response for TTS |

### Response JSON
```json
{
  "message": "Yes, there is a 70% chance of rain in Mumbai tomorrow afternoon. Expect moderate rainfall between 2 PM and 6 PM IST.",
  "conversation_id": "conv-abc123",
  "language": "en",
  "suggestions": [
    "What should I carry?",
    "How long will the rain last?",
    "Any flood alerts in Mumbai?"
  ]
}
```

| Field | Type | Description |
|---|---|---|
| `message` | string | AI-generated natural-language response |
| `conversation_id` | string | Conversation identifier for threading |
| `language` | string | Language of the response |
| `suggestions` | array of string | Follow-up query suggestions |

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Empty or invalid message / out-of-range coordinates |
| `422 Unprocessable Entity` | Schema validation failure (missing `message` field) |
| `503 Service Unavailable` | Gemini provider unreachable or API key not configured |

### Example Request
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Will it rain in Mumbai tomorrow?", "language": "en"}'
```

---

## 7. GET /alerts

> **Implementation status**: **[REAL — Phase 6]** — powered by deterministic `AlertEngine` evaluating live WeatherAPI.com current and forecast observations against configurable thresholds, merged with native WeatherAPI authority alerts. No LLM involved.

### Purpose
Returns active weather alerts (severe weather warnings, watches, advisories) for a location. Alerts are produced deterministically by the Smart Alert Engine and merged with any native alerts issued by meteorological authorities.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude (-90 to 90) |
| `lon` | float | Yes | — | Longitude (-180 to 180) |

### Request Body
None.

### Response JSON
```json
{
  "alerts": [
    {
      "alert_id": "sae-b0aa1d70",
      "alert_type": "heat",
      "severity": "moderate",
      "title": "Heat Advisory",
      "description": "High temperature of 39.1°C expected. Stay hydrated and limit prolonged exposure during afternoon hours.",
      "area": "Al Wurud",
      "start_time": 1789036196,
      "end_time": 1789122596,
      "source": "WeatherGPT Smart Alert Engine",
      "relevant_value": 39.1,
      "threshold": 38.0
    },
    {
      "alert_id": "alert-001",
      "alert_type": "thunderstorm",
      "severity": "severe",
      "title": "Thunderstorm Warning",
      "description": "Heavy thunderstorms expected with lightning and gusty winds.",
      "area": "Mumbai Metropolitan Region",
      "start_time": 1756137600,
      "end_time": 1756159200,
      "source": "India Meteorological Department",
      "relevant_value": null,
      "threshold": null
    }
  ],
  "total": 2
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Invalid coordinates |
| `503 Service Unavailable` | Weather provider or alert engine unreachable |

### Example Request
```bash
curl "http://localhost:8000/api/v1/alerts?lat=19.0760&lon=72.8777"
```

---

## 8. GET /advisory

> **Implementation status**: **[REAL — Phase 6]** — deterministic, rule-based weather advisories generated from live weather observations and the Smart Alert Engine. No LLM is used.

### Purpose
Returns practical, actionable weather advisories with recommendations tailored for general guidance, travel, agriculture, health, or outdoor activities.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude (-90 to 90) |
| `lon` | float | Yes | — | Longitude (-180 to 180) |
| `category` | string | No | `general` | Category filter: `general` \| `travel` \| `agriculture` \| `health` \| `outdoor` |

### Request Body
None.

### Response JSON
```json
{
  "advisories": [
    {
      "advisory_id": "adv-ce17eaae",
      "category": "health",
      "title": "Heat Safety Advisory",
      "message": "High temperature of 39.1°C detected. Stay hydrated and avoid prolonged exposure during peak afternoon hours.",
      "recommendation": "Drink at least 2–3 litres of water per day. Wear loose, light-coloured clothing. Avoid strenuous outdoor activity between 11am and 4pm.",
      "valid_until": 1789122614
    }
  ],
  "total": 1
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Invalid coordinates or category |
| `503 Service Unavailable` | Advisory service unreachable |

### Example Request
```bash
curl "http://localhost:8000/api/v1/advisory?lat=28.6139&lon=77.2090&category=health"
```

---

## 9. GET /climate/trends

### Purpose
Returns historical climate trend data for a location over a specified period. Used to display long-term climate analytics charts in the Flutter app.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude |
| `lon` | float | Yes | — | Longitude |
| `start_year` | int | No | `2000` | Start of the trend period |
| `end_year` | int | No | `2025` | End of the trend period |
| `parameter` | string | No | `temperature` | `temperature` \| `precipitation` \| `humidity` |

### Request Body
None.

### Response JSON
```json
{
  "location_name": "New Delhi",
  "lat": 28.6139,
  "lon": 77.2090,
  "trends": [
    {
      "parameter": "temperature",
      "unit": "°C",
      "baseline_period": "1981-2010",
      "data_points": [
        { "year": 2000, "value": 25.1, "anomaly": 0.3 },
        { "year": 2001, "value": 25.4, "anomaly": 0.6 }
      ]
    }
  ]
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Invalid coordinates or year range |
| `404 Not Found` | No historical data for the location |
| `503 Service Unavailable` | Climate service unavailable |

### Example Request
```bash
curl "http://localhost:8000/api/v1/climate/trends?lat=28.6139&lon=77.2090&start_year=2000&end_year=2025&parameter=temperature"
```

---

## 10. Error Responses

All errors follow a consistent JSON structure:

```json
{
  "detail": "Human-readable error message"
}
```

For validation errors (422):
```json
{
  "detail": [
    {
      "loc": ["query", "lat"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

---

*This document must be updated whenever an endpoint is added, removed, or modified. Both developers must agree before making changes.*

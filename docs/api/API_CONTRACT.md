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

### Timeout and Retry Behavior
- **Client Timeout**: 60 seconds (`AppConfig.chatApiTimeout`). Standard non-chat endpoints retain a 15-second timeout (`AppConfig.apiTimeout`).
- **Transient Gemini 503 Retry**: Backend automatically attempts 1 retry with a 1.5-second backoff for transient 503 (high demand) errors before failing.
- **Deduplication**: Weather context retrieval reuses WeatherAPIClient's in-memory 30-second deduplication cache to prevent unnecessary external calls.

### Possible Errors
| Status | Detail Message | Cause |
|---|---|---|
| `400 Bad Request` | `"Message cannot be empty."` / `"Invalid location coordinates."` | Empty message or invalid coordinates |
| `422 Unprocessable Entity` | Field validation error | Missing `message` field |
| `429 Too Many Requests` | `"WeatherGPT request limit reached. Please try again later."` | Gemini API rate limit / quota exceeded |
| `503 Service Unavailable` | `"WeatherGPT is temporarily busy. Please try again."` | Gemini 503 high demand (after 1 retry) |
| `503 Service Unavailable` | `"Weather service is temporarily unavailable."` | WeatherAPI provider unreachable |
| `500 Internal Server Error` | `"AI service configuration error."` | Missing/invalid Gemini credentials (no keys leaked) |

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

---

## 9. GET /climate

### Purpose
Returns deterministic historical climate analysis for a requested location over a specified period. Computes temperature and rainfall trends, historical baseline comparisons, anomalies, Tamil Nadu seasonal context, and rule-based insights without LLM involvement. Powered by a curated reference dataset.

> **Dataset Notice**: The underlying dataset (`backend/weathergpt_api/data/climate/historical_weather.csv`) is a prototype/reference historical dataset containing representative monthly records for Tamil Nadu cities (`Madurai`, `Chennai`, `Coimbatore`, `Tirunelveli`) spanning 2000–2023. It is not an official government meteorological feed.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `location` | string | No | `Madurai` | City name (`Madurai`, `Chennai`, `Coimbatore`, `Tirunelveli`) |
| `year_from` | int | No | `2000` | Start year of analysis (1990–2030) |
| `year_to` | int | No | `2023` | End year of analysis (1990–2030) |
| `month` | int | No | `null` | Optional calendar month (1–12); omit for whole-year analysis |
| `metric` | string | No | `null` | Optional metric focus: `temperature` \| `rainfall` |

### Request Body
None.

### Response JSON
```json
{
  "location": "Madurai",
  "year_from": 2000,
  "year_to": 2023,
  "temperature_trend": {
    "location": "Madurai",
    "metric": "temperature",
    "unit": "°C",
    "period": "2000–2023",
    "values": [
      { "year": 2000, "value": 29.5 },
      { "year": 2023, "value": 29.8 }
    ]
  },
  "rainfall_trend": {
    "location": "Madurai",
    "metric": "rainfall",
    "unit": "mm",
    "period": "2000–2023",
    "values": [
      { "year": 2000, "value": 717.4 },
      { "year": 2023, "value": 820.0 }
    ]
  },
  "temperature_comparison": {
    "metric": "temperature",
    "current_value": 29.8,
    "historical_average": 29.3,
    "difference": 0.5,
    "difference_percent": 1.7,
    "interpretation": "above_average"
  },
  "rainfall_comparison": {
    "metric": "rainfall",
    "current_value": 820.0,
    "historical_average": 860.0,
    "difference": -40.0,
    "difference_percent": -4.7,
    "interpretation": "near_average"
  },
  "temperature_anomaly": 0.5,
  "rainfall_anomaly": -40.0,
  "season": "Southwest Monsoon",
  "insight": "Recent temperatures are relatively stable compared with the historical baseline.",
  "data_source": "Prototype/reference dataset — derived from publicly available climatological summaries for Tamil Nadu cities. Not official meteorological observations.",
  "available_locations": [
    "Chennai",
    "Coimbatore",
    "Madurai",
    "Tirunelveli"
  ]
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | `year_from` > `year_to` or out-of-range parameters |
| `404 Not Found` | Location not in reference dataset |
| `500 Internal Server Error` | Unexpected analysis error |

### Example Request
```bash
curl "http://localhost:8000/api/v1/climate?location=Madurai&year_from=2000&year_to=2023"
```

---

## 9.1 GET /climate/trends (Legacy / Convenience)

### Purpose
Convenience endpoint for single-parameter historical trends.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `location` | string | No | `Madurai` | City name |
| `parameter` | string | No | `temperature` | `temperature` \| `rainfall` |
| `start_year` | int | No | `2000` | Start year |
| `end_year` | int | No | `2023` | End year |

### Example Request
```bash
curl "http://localhost:8000/api/v1/climate/trends?location=Madurai&parameter=temperature&start_year=2000&end_year=2023"
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

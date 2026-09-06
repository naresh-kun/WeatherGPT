# WeatherGPT — REST API Contract

**Version**: 0.1.0  
**Base URL**: `http://localhost:8000/api/v1`  
**Format**: All requests and responses use `application/json`.

This document is the single source of truth for the integration boundary between the Flutter frontend and the FastAPI backend. Both developers must agree before making any changes.

---

## Table of Contents

1. [GET /health](#1-get-health)
2. [GET /weather/current](#2-get-weathercurrent)
3. [GET /weather/forecast](#3-get-weatherforecast)
4. [POST /chat](#4-post-chat)
5. [GET /alerts](#5-get-alerts)
6. [GET /advisory](#6-get-advisory)
7. [GET /climate/trends](#7-get-climatetrends)
8. [Error Responses](#8-error-responses)

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

---

## 4. POST /chat

### Purpose
Accepts a natural-language weather query from the user, routes it through intent understanding, weather data retrieval, and an LLM to produce a conversational response.

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
| `400 Bad Request` | Empty or invalid message |
| `422 Unprocessable Entity` | Schema validation failure |
| `503 Service Unavailable` | LLM provider unreachable |

### Example Request
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Will it rain in Mumbai tomorrow?", "language": "en"}'
```

---

## 5. GET /alerts

### Purpose
Returns active weather alerts (severe weather warnings, watches, advisories) for a location issued by meteorological authorities.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude |
| `lon` | float | Yes | — | Longitude |

### Request Body
None.

### Response JSON
```json
{
  "alerts": [
    {
      "alert_id": "alert-001",
      "alert_type": "thunderstorm",
      "severity": "moderate",
      "title": "Thunderstorm Warning",
      "description": "Heavy thunderstorms expected over the next 6 hours with lightning and gusty winds up to 60 km/h.",
      "area": "Mumbai Metropolitan Region",
      "start_time": 1756137600,
      "end_time": 1756159200,
      "source": "India Meteorological Department"
    }
  ],
  "total": 1
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Invalid coordinates |
| `503 Service Unavailable` | Alert data unavailable |

### Example Request
```bash
curl "http://localhost:8000/api/v1/alerts?lat=19.0760&lon=72.8777"
```

---

## 6. GET /advisory

### Purpose
Returns weather-based advisories with recommendations for travel, agriculture, health, or outdoor activities.

### HTTP Method
`GET`

### Query Parameters
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `lat` | float | Yes | — | Latitude |
| `lon` | float | Yes | — | Longitude |
| `category` | string | No | `general` | `general` \| `travel` \| `agriculture` \| `health` \| `outdoor` |

### Request Body
None.

### Response JSON
```json
{
  "advisories": [
    {
      "advisory_id": "adv-001",
      "category": "travel",
      "title": "Reduced Visibility Advisory",
      "message": "Dense fog is expected on NH-48 between 4 AM and 9 AM. Visibility below 50 m.",
      "recommendation": "Avoid highway travel before 9 AM or use fog lights and drive slowly.",
      "valid_until": 1756173600
    }
  ],
  "total": 1
}
```

### Possible Errors
| Status | Description |
|---|---|
| `400 Bad Request` | Invalid coordinates or category |
| `503 Service Unavailable` | Advisory service unavailable |

### Example Request
```bash
curl "http://localhost:8000/api/v1/advisory?lat=28.6139&lon=77.2090&category=travel"
```

---

## 7. GET /climate/trends

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

## 8. Error Responses

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

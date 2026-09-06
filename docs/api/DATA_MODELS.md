# WeatherGPT — Conceptual Data Models

**Version**: 0.1.0

This document defines the canonical conceptual data models shared between the Flutter frontend and the FastAPI backend.  
Both sides implement their own representation of these models but must produce and consume JSON that matches this specification exactly.

---

## 1. Location

Represents a geographic location.

| Field | Type | Required | Description |
|---|---|---|---|
| `lat` | float | Yes | Latitude in decimal degrees (-90 to 90) |
| `lon` | float | Yes | Longitude in decimal degrees (-180 to 180) |
| `city` | string | No | Human-readable city name |
| `country` | string | No | ISO 3166-1 alpha-2 country code (e.g., `"IN"`) |
| `timezone` | string | No | IANA timezone string (e.g., `"Asia/Kolkata"`) |

```json
{
  "lat": 28.6139,
  "lon": 77.2090,
  "city": "New Delhi",
  "country": "IN",
  "timezone": "Asia/Kolkata"
}
```

---

## 2. WeatherCurrent

Current weather conditions at a location.

| Field | Type | Required | Description |
|---|---|---|---|
| `location` | Location | Yes | Geographic location |
| `temperature` | float | Yes | Temperature in the requested unit system |
| `feels_like` | float | Yes | Apparent ("feels like") temperature |
| `humidity` | int | Yes | Relative humidity (0–100%) |
| `wind_speed` | float | Yes | Wind speed (m/s for metric) |
| `wind_direction` | int | Yes | Wind direction in degrees (0–360) |
| `description` | string | Yes | Short human-readable description |
| `icon` | string | Yes | Icon code from the weather provider |
| `uv_index` | float | No | UV index (0–11+) |
| `visibility` | float | No | Visibility in km |
| `timestamp` | int | Yes | Unix UTC timestamp of the observation |

---

## 3. HourlyForecast

Weather forecast for a single hour within a forecast period.

| Field | Type | Required | Description |
|---|---|---|---|
| `timestamp` | int | Yes | Unix UTC timestamp for this hour |
| `temperature` | float | Yes | Temperature |
| `feels_like` | float | Yes | Apparent temperature |
| `humidity` | int | Yes | Relative humidity (0–100%) |
| `wind_speed` | float | Yes | Wind speed |
| `description` | string | Yes | Short description |
| `icon` | string | Yes | Icon code |
| `precipitation_probability` | float | Yes | Probability of precipitation (0.0–1.0) |

---

## 4. DailyForecast

Weather forecast for a single day.

| Field | Type | Required | Description |
|---|---|---|---|
| `date` | string | Yes | Date in `YYYY-MM-DD` format |
| `temp_min` | float | Yes | Minimum temperature |
| `temp_max` | float | Yes | Maximum temperature |
| `humidity` | int | Yes | Average relative humidity (0–100%) |
| `wind_speed` | float | Yes | Average wind speed |
| `description` | string | Yes | Short description |
| `icon` | string | Yes | Icon code |
| `sunrise` | int | Yes | Sunrise time — Unix UTC timestamp |
| `sunset` | int | Yes | Sunset time — Unix UTC timestamp |
| `precipitation_probability` | float | Yes | Probability of precipitation (0.0–1.0) |

---

## 5. WeatherForecast

Complete forecast response containing both hourly and daily data.

| Field | Type | Required | Description |
|---|---|---|---|
| `location` | Location | Yes | Geographic location |
| `hourly` | HourlyForecast[] | Yes | Hourly forecast array |
| `daily` | DailyForecast[] | Yes | Daily forecast array |
| `units` | string | Yes | Unit system: `metric` \| `imperial` \| `standard` |

---

## 6. ChatRequest

A natural-language weather query from the user.

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `message` | string | Yes | — | User's natural-language query |
| `conversation_id` | string | No | `null` | Continue an existing conversation |
| `language` | string | No | `"en"` | BCP-47 language tag for the response |
| `location` | `{lat, lon}` | No | `null` | Optional location context |
| `voice` | boolean | No | `false` | Optimise response for text-to-speech |

```json
{
  "message": "Will it rain in Mumbai tomorrow?",
  "conversation_id": "conv-abc123",
  "language": "en",
  "location": { "lat": 19.0760, "lon": 72.8777 },
  "voice": false
}
```

---

## 7. ChatResponse

The AI-generated conversational response.

| Field | Type | Required | Description |
|---|---|---|---|
| `message` | string | Yes | Natural-language response |
| `conversation_id` | string | Yes | Conversation thread identifier |
| `language` | string | Yes | BCP-47 language of the response |
| `suggestions` | string[] | Yes | Follow-up query suggestions |

```json
{
  "message": "Yes, there is a 70% chance of rain in Mumbai tomorrow afternoon.",
  "conversation_id": "conv-abc123",
  "language": "en",
  "suggestions": ["What should I carry?", "How long will it last?"]
}
```

---

## 8. Conversation

Full conversation thread history.

| Field | Type | Required | Description |
|---|---|---|---|
| `conversation_id` | string | Yes | Unique conversation identifier |
| `messages` | Message[] | Yes | Ordered list of conversation turns |
| `language` | string | Yes | Language of the conversation |

Each **Message** has:
| Field | Type | Description |
|---|---|---|
| `role` | string | `"user"` \| `"assistant"` \| `"system"` |
| `content` | string | Message text |
| `timestamp` | int | Unix UTC timestamp |

---

## 9. Alert

An active weather alert issued by a meteorological authority.

| Field | Type | Required | Description |
|---|---|---|---|
| `alert_id` | string | Yes | Unique alert identifier |
| `alert_type` | string | Yes | `thunderstorm` \| `flood` \| `cyclone` \| `heatwave` \| `coldwave` \| `drought` \| `fog` \| `other` |
| `severity` | string | Yes | `minor` \| `moderate` \| `severe` \| `extreme` |
| `title` | string | Yes | Short alert title |
| `description` | string | Yes | Detailed description |
| `area` | string | Yes | Affected area name |
| `start_time` | int | Yes | Start — Unix UTC timestamp |
| `end_time` | int | No | End — Unix UTC timestamp |
| `source` | string | No | Issuing authority |

---

## 10. Advisory

A weather-based advisory with a recommendation.

| Field | Type | Required | Description |
|---|---|---|---|
| `advisory_id` | string | Yes | Unique advisory identifier |
| `category` | string | Yes | `general` \| `travel` \| `agriculture` \| `health` \| `outdoor` |
| `title` | string | Yes | Short advisory title |
| `message` | string | Yes | Detailed advisory message |
| `recommendation` | string | Yes | Recommended user action |
| `valid_until` | int | No | Validity end — Unix UTC timestamp |

---

## 11. ClimateTrend

Historical climate trend data for a single parameter.

| Field | Type | Required | Description |
|---|---|---|---|
| `parameter` | string | Yes | Climate parameter (`temperature`, `precipitation`, `humidity`) |
| `unit` | string | Yes | Unit of measurement (e.g., `°C`, `mm`) |
| `baseline_period` | string | Yes | Reference period (e.g., `"1981-2010"`) |
| `data_points` | DataPoint[] | Yes | Yearly data points |

Each **DataPoint** has:
| Field | Type | Description |
|---|---|---|
| `year` | int | Year of the observation |
| `value` | float | Observed value |
| `anomaly` | float | Deviation from the baseline |

---

*Both the Flutter frontend and the FastAPI backend must implement models that produce and consume JSON exactly matching these specifications.*

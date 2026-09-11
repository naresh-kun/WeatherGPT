# WeatherGPT — Flutter Application

Conversational weather intelligence UI for the WeatherGPT SIH prototype.

**Phase 4 status**: UI integrated with FastAPI backend. Real weather data is fetched for Home, Forecast, Alerts, and Location Search. Advanced AI features (Chat, Climate, Advisory) remain mocked pending later phases.

---

## Implemented Screens

| Screen | Route / Access | Description |
|---|---|---|
| Splash | `/` (initial) | Branding screen with 2-second transition to main app |
| Home | Bottom nav tab | Dashboard with real current weather, metrics, hourly/daily preview, suggestions, active alerts preview |
| WeatherGPT Chat | Bottom nav tab | Conversational UI with mock AI responses (Phase 5) |
| Forecast | `/forecast` (from Home) | Full real hourly forecast, 7-day forecast, temperature chart |
| Alerts | Bottom nav tab | Real weather alerts dashboard with severity indicators |
| Advisory | Bottom nav tab | Category cards (Farming, Travel, Outdoor, Driving) with detail views (Mocked) |
| Climate | Bottom nav tab | Historical temperature/rainfall charts with time range selector (Mocked) |
| Settings | `/settings` (from Home app bar) | Location, language, notifications, voice, units, about |
| Location Search | `/location-search` (from Home) | Real backend-powered city search & GPS |

---

## Navigation

- **Bottom navigation bar**: Home → WeatherGPT → Alerts → Advisory → Climate
- **Settings**: Accessible via the gear icon on the Home screen app bar
- **Location Search**: Accessible via tapping the location name in the Home screen header
- **Forecast**: Accessible via "Full forecast" / "View all" links on Home, or route `/forecast`
- **Advisory detail**: Tap a category card to open its advisory detail screen
- **Chat suggestions**: Tapping Home suggestion chips navigates to WeatherGPT tab and pre-fills the input

---

## Reusable Widgets

| Widget | Location | Purpose |
|---|---|---|
| `WeatherCard` | `widgets/weather/` | Current weather display |
| `WeatherMetricCard` / `WeatherMetricGrid` | `widgets/weather/` | Quick metric cards (humidity, wind, rain, UV) |
| `HourlyForecastItem` / `DailyForecastCard` | `widgets/weather/` | Forecast list items |
| `TemperatureChart` | `widgets/weather/` | Hourly temperature line chart |
| `ChatBubble` | `widgets/chat/` | User/AI message bubbles |
| `AlertCard` | `widgets/alerts/` | Alert card with severity styling |
| `AdvisoryCategoryCard` / `AdvisoryDetailCard` | `widgets/advisory/` | Advisory category and detail views |
| `ClimateLineChart` / `RainfallChart` | `widgets/climate/` | Climate trend charts |
| `CommonCard` | `widgets/common/` | Shared card container |
| `SectionHeader` | `widgets/common/` | Section title with optional action |
| `SuggestionChip` | `widgets/common/` | Tappable suggestion chips |
| `LoadingWidget` | `widgets/common/` | Loading state (demo on Alerts screen) |
| `ErrorDisplayWidget` | `widgets/common/` | Error state with optional retry |
| `EmptyStateWidget` | `widgets/common/` | Empty data state |

---

## Data Approach (Phase 4)

- **Real Data (Weather, Forecast, Alerts, Location)**: Providers (`WeatherProvider`, `LocationProvider`) communicate with `ApiService` to fetch live data from the FastAPI backend.
- **Mock Data (Chat, Advisory, Climate)**: Remaining features read from `lib/data/mock_data.dart` until their respective backend services are built.

---

## Current Limitations

- **No LLM** — chat responses are keyword-matched mock replies
- **No real advisory logic** — advisories are pre-written examples
- **No real climate processing** — charts use static historical mock data
- **No Tamil localization** — language selector is UI-only
- **No STT/TTS** — microphone button shows a placeholder snackbar

---

## Dependencies

| Package | Purpose |
|---|---|
| `fl_chart` | Temperature and rainfall charts |
| `cupertino_icons` | iOS-style icons |
| `http` | Backend API communication |
| `geolocator` | GPS coordinates |
| `shared_preferences` | Local storage (selected city) |

---

## How to Run

```bash
cd frontend/weathergpt_app
flutter pub get
flutter run
```

**Note**: To see real weather data, you must have the FastAPI backend running (`cd backend/weathergpt_api && uvicorn app.main:app --reload`). The app defaults to connecting to `10.0.2.2:8000` (for Android emulators) or `localhost:8000` (for web/desktop).

### Verification commands

```bash
flutter analyze    # Static analysis
flutter test       # Unit and Widget tests
flutter build apk  # Build Android APK
```

---

## Project Structure (lib/)

```
lib/
├── core/
│   ├── config/          # App configuration (Base URLs)
│   ├── constants/       # Shared constants
│   ├── theme/           # AppTheme, AppColors, AppDimensions
│   ├── utils/           # WeatherUtils (icons, formatting)
│   └── errors/          # Exception types
├── data/
│   └── mock_data.dart   # Mock data for Chat, Advisory, Climate
├── models/              # Dart data models (API-contract aligned)
├── navigation/          # AppRoutes, MainShell (bottom nav)
├── providers/           # State management (Weather, Location)
├── screens/             # All feature screens
├── services/            # API client and local storage services
├── widgets/             # Reusable UI components
└── main.dart            # App entry point
```

---

## Architecture Reference

See [`docs/architecture/ARCHITECTURE.md`](../../docs/architecture/ARCHITECTURE.md) for the full system architecture.  
See [`docs/api/API_CONTRACT.md`](../../docs/api/API_CONTRACT.md) for the REST API specification.  
See [`docs/api/DATA_MODELS.md`](../../docs/api/DATA_MODELS.md) for data model definitions.

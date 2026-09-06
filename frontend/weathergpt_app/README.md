# WeatherGPT — Flutter Application

Conversational weather intelligence UI for the WeatherGPT SIH prototype.

**Phase 2 status**: UI complete with mock data. Backend integration not yet implemented.

---

## Implemented Screens

| Screen | Route / Access | Description |
|---|---|---|
| Splash | `/` (initial) | Branding screen with 2-second transition to main app |
| Home | Bottom nav tab | Dashboard with current weather, metrics, hourly/daily preview, suggestions, alert preview |
| WeatherGPT Chat | Bottom nav tab | Conversational UI with mock AI responses |
| Forecast | `/forecast` (from Home) | Full hourly forecast, 7-day forecast, temperature chart |
| Alerts | Bottom nav tab | Weather alerts dashboard with severity indicators |
| Advisory | Bottom nav tab | Category cards (Farming, Travel, Outdoor, Driving) with detail views |
| Climate | Bottom nav tab | Historical temperature/rainfall charts with time range selector |
| Settings | `/settings` (from Home app bar) | Location, language, notifications, voice, units, about |

---

## Navigation

- **Bottom navigation bar**: Home → WeatherGPT → Alerts → Advisory → Climate
- **Settings**: Accessible via the gear icon on the Home screen app bar
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

## Mock Data Approach

All UI data comes from **`lib/data/mock_data.dart`**, a centralized mock data provider.

- Models in `lib/models/` mirror the API contract in `docs/api/DATA_MODELS.md`
- Screens read from `MockData` — no API calls are made
- Chat responses are simulated locally via `MockData.simulateChatResponse()`
- Climate datasets switch by time range (5 / 10 / 20 years) using prepared mock datasets

**Replacing mock data (Phase 3+)**: Introduce repositories that call `ApiService`, map JSON responses to the existing model classes, and swap `MockData` references in screens for repository calls. The UI widgets require minimal changes.

---

## Current Limitations

- **No backend integration** — FastAPI endpoints are not called
- **No real weather data** — all values are dummy/local
- **No LLM** — chat responses are keyword-matched mock replies
- **No real alerts engine** — alerts are static mock entries
- **No real advisory logic** — advisories are pre-written examples
- **No real climate processing** — charts use static historical mock data
- **No Tamil localization** — language selector is UI-only
- **No STT/TTS** — microphone button shows a placeholder snackbar
- **No GPS/location** — location is hardcoded to Madurai, Tamil Nadu

---

## Dependencies

| Package | Purpose |
|---|---|
| `fl_chart` | Temperature and rainfall charts |
| `cupertino_icons` | iOS-style icons |

---

## How to Run

```bash
cd frontend/weathergpt_app
flutter pub get
flutter run
```

### Verification commands

```bash
flutter analyze    # Static analysis
flutter test       # Widget tests
flutter build apk  # Build Android APK
```

No backend server is required for Phase 2.

---

## Project Structure (lib/)

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── constants/       # Shared constants
│   ├── theme/           # AppTheme, AppColors, AppDimensions
│   ├── utils/           # WeatherUtils (icons, formatting)
│   └── errors/          # Exception types
├── data/
│   └── mock_data.dart   # Centralized mock data (Phase 2)
├── models/              # Dart data models (API-contract aligned)
├── navigation/          # AppRoutes, MainShell (bottom nav)
├── screens/             # All feature screens
├── widgets/             # Reusable UI components
└── main.dart            # App entry point
```

Services (`api/`, `location/`, `voice/`, `storage/`) and repositories remain as Phase 1 placeholders for future integration.

---

## Architecture Reference

See [`docs/architecture/ARCHITECTURE.md`](../../docs/architecture/ARCHITECTURE.md) for the full system architecture.  
See [`docs/api/API_CONTRACT.md`](../../docs/api/API_CONTRACT.md) for the REST API specification.  
See [`docs/api/DATA_MODELS.md`](../../docs/api/DATA_MODELS.md) for data model definitions.

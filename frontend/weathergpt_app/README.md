# WeatherGPT — Flutter Application

Conversational weather intelligence UI for the WeatherGPT SIH prototype.

**Phase 9 status**: UI integrated with FastAPI backend (Weather, Forecast, Alerts, Location Search, Gemini 3.7 Flash Chat, Advisories, Climate Intelligence, and English/Tamil Multilingual). **Phase 9 adds Voice Interaction**: Speech-to-Text (STT) and Text-to-Speech (TTS) supporting English and Tamil.

---

## Implemented Screens

| Screen | Route / Access | Description |
|---|---|---|
| Splash | `/` (initial) | Branding screen with 2-second transition to main app |
| Home | Bottom nav tab | Dashboard with real current weather, metrics, hourly/daily preview, suggestions, active alerts preview |
| WeatherGPT Chat | Bottom nav tab | Conversational UI with Gemini 3.7 Flash AI, Tamil/English support, and voice input/output (Phase 9) |
| Forecast | `/forecast` (from Home) | Full real hourly forecast, 7-day forecast, temperature chart |
| Alerts | Bottom nav tab | Real weather alerts dashboard with severity indicators |
| Advisory | Bottom nav tab | Category cards with detail views (Deterministic, bilingual) |
| Climate | Bottom nav tab | Historical temperature/rainfall charts with deterministic insight analysis |
| Settings | `/settings` (from Home app bar) | Location, language (EN/TA), notifications, voice, units, about |
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
| `ChatBubble` | `widgets/chat/` | User/AI message bubbles with Speak/Stop audio action (Phase 9) |
| `AlertCard` | `widgets/alerts/` | Alert card with severity styling |
| `AdvisoryCategoryCard` / `AdvisoryDetailCard` | `widgets/advisory/` | Advisory category and detail views |
| `ClimateLineChart` / `RainfallChart` | `widgets/climate/` | Climate trend charts |
| `CommonCard` | `widgets/common/` | Shared card container |
| `SectionHeader` | `widgets/common/` | Section title with optional action |
| `SuggestionChip` | `widgets/common/` | Tappable suggestion chips |
| `LoadingWidget` | `widgets/common/` | Loading state |
| `ErrorDisplayWidget` | `widgets/common/` | Error state with optional retry |
| `EmptyStateWidget` | `widgets/common/` | Empty data state |

---

## Voice Interaction (Phase 9)

- **Speech-to-Text (STT)**: `speech_to_text: ^7.4.0`
  - Input field mic button activates listening state.
  - Partial recognized speech streams into the chat TextField for review/edit before sending.
  - Cancel & stop controls.
- **Text-to-Speech (TTS)**: `flutter_tts: ^4.2.5`
  - Assistant bubbles feature a Speak/Stop toggle.
  - Cleans Markdown formatting before passing text to the TTS engine.
- **Languages**: English (`en-US`) and Tamil (`ta-IN`).
  - Graceful fallback with user-friendly error banners if a device lacks Tamil voice capabilities.
- **Android Permissions**: `android.permission.RECORD_AUDIO`. Requested only on user interaction.

---

## Dependencies

| Package | Purpose |
|---|---|
| `fl_chart` | Temperature and rainfall charts |
| `cupertino_icons` | iOS-style icons |
| `http` | Backend API communication |
| `geolocator` | GPS coordinates |
| `shared_preferences` | Local storage (selected city, language preference) |
| `speech_to_text` | Speech recognition for voice input (Phase 9) |
| `flutter_tts` | Text-to-speech for assistant response playback (Phase 9) |

---

## How to Run & Build

### Local Development (Debug Mode)
```bash
cd frontend/weathergpt_app
flutter pub get
flutter run
```
*Note*: Connects to local FastAPI backend (`http://127.0.0.1:8000/api/v1` or `10.0.2.2:8000` on Android emulator). Cleartext traffic is enabled exclusively in debug builds.

### Production Release APK Build (Phase 12)
```bash
cd frontend/weathergpt_app
flutter build apk --release --dart-define=API_BASE_URL=https://weathergpt-production-84b3.up.railway.app/api/v1
```
*Output*: `build/app/outputs/flutter-apk/app-release.apk` (~51.8 MB).  
*Security*: Enforces HTTPS traffic to Railway backend, zero API keys bundled, keystore passwords protected via local `key.properties`.

### Testing APK on Device / Emulator
```bash
# Install to running emulator / device
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Launch
adb shell am start -n com.weathergpt.weathergpt_app/com.weathergpt.weathergpt_app.MainActivity
```

### Verification commands

```bash
flutter analyze    # Static analysis (clean)
flutter test       # Unit and Widget tests (171 tests passed)
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

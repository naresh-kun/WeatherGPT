WeatherGPT — Phase 4: Flutter ↔ FastAPI Integration

You are working on the WeatherGPT SIH prototype.

Project Context

WeatherGPT is a conversational AI weather application being developed as a polished SIH prototype.

Completed phases:

Phase 1

Foundation and project scaffold ✅

Phase 2

Flutter UI with centralized mock data ✅

Phase 3

FastAPI weather backend connected to WeatherAPI.com ✅

The backend currently provides real weather data through FastAPI.

Your task is now:

Phase 4 — Flutter ↔ FastAPI Integration

The goal is to replace the weather-related Flutter mock data with real data retrieved from our FastAPI backend.

MOST IMPORTANT SCOPE RULE

This phase is for frontend/backend integration and location handling.

Implement:

Flutter HTTP/API integration
Backend base URL configuration
Current weather integration
Forecast integration
Hourly forecast integration
Weather alert integration
Location search integration
Current GPS location support
Loading states
Error states
Refresh behavior
Selected-location handling
Mapping backend responses into Flutter models
Documentation updates
Frontend integration testing

Do NOT implement:

LLM / WeatherGPT AI
Chat backend
Smart alert rules
Farming advisory engine
Climate backend
STT/TTS
Tamil localization
Authentication
WebSockets
Database
Production infrastructure

Keep Phase 2's visual design.

Do not redesign the entire UI.

CRITICAL: READ THE EXISTING DOCUMENTATION FIRST

Before modifying code, inspect:

README.md
frontend/weathergpt_app/README.md
docs/api/API_CONTRACT.md
docs/api/DATA_MODELS.md
docs/architecture/ARCHITECTURE.md

Also inspect the existing Flutter code from Phase 2.

Especially inspect:

lib/
├── core/
├── data/
├── models/
├── navigation/
├── repositories/
├── services/
├── providers/
├── screens/
└── widgets/

Also inspect:

lib/data/mock_data.dart
lib/services/api/api_service.dart
lib/services/location/location_service.dart
lib/core/config/app_config.dart
lib/models/

Do not assume the endpoint structure from this prompt.

The authoritative backend contract is:

docs/api/API_CONTRACT.md

Use the actual documented request parameters and response models.

The backend implementation from Phase 3 is the actual API source of truth.

1. CURRENT ARCHITECTURE

The final Phase 4 flow should become:

Flutter
   │
   ▼
API Service
   │
   ▼
FastAPI
   │
   ▼
WeatherAPI.com

Flutter must communicate only with our FastAPI backend.

Flutter must NOT call WeatherAPI.com directly.

2. BACKEND BASE URL CONFIGURATION

Use the existing:

lib/core/config/app_config.dart

Create a configurable backend base URL.

Do NOT scatter URLs across the codebase.

The backend URL must be changeable depending on environment/device.

For Android emulator, remember that:

localhost

inside the emulator refers to the emulator itself, not the development PC.

Use a configuration-based approach so the backend host can be changed without modifying API service code.

Example conceptually:

Android emulator:
http://10.0.2.2:8000

Physical Android device:
http://<developer-machine-local-ip>:8000

Do not permanently hardcode one development machine IP.

Document how the developer can change the backend URL.

3. HTTP CLIENT / API SERVICE

Implement the existing:

lib/services/api/api_service.dart

as the central HTTP communication layer.

Do not place HTTP requests directly inside screens.

The API service should provide reusable methods for the documented backend endpoints.

At minimum support the weather endpoints that currently exist in the backend contract, including as applicable:

Current weather
Forecast
Hourly forecast
Location search
Weather alerts

Use the actual routes and parameters from:

docs/api/API_CONTRACT.md

Do not guess endpoint names or parameters.

4. HTTP DEPENDENCY

Inspect the existing pubspec.yaml.

If an HTTP client dependency already exists, reuse it.

If no suitable HTTP library exists, use a simple maintained HTTP package such as http.

Do not introduce a large networking framework unnecessarily.

5. API RESPONSE MAPPING

Do not bind Flutter widgets directly to raw JSON maps.

Use the existing Flutter model architecture.

Inspect the current model classes and update them where necessary.

The Flutter model layer should represent the application's data rather than the provider's raw response.

The intended flow is:

JSON response
     ↓
API Service
     ↓
Flutter Model
     ↓
Repository / Provider
     ↓
Screen
     ↓
Widget

Keep this architecture as simple as practical.

Do not introduce excessive abstraction.

6. REPOSITORIES

Inspect:

lib/repositories/

Use the existing repository layer if it already fits the architecture.

If repositories are currently placeholders, implement only what is necessary for weather integration.

Potential conceptual structure:

WeatherRepository
    ↓
ApiService
    ↓
FastAPI

Screens should preferably not know about HTTP implementation details.

7. STATE MANAGEMENT

Inspect the existing:

lib/providers/

Use the project's existing/simple state-management approach.

Do NOT introduce Riverpod, Bloc, Provider, Redux, GetX, or another framework unless the project already uses it or there is a strong existing architectural reason.

Keep state management lightweight.

The following states must be represented:

Initial
Loading
Success
Error
8. CURRENT WEATHER INTEGRATION

Replace the Phase 2 Home-screen current weather mock data with real backend data.

The Home screen should retrieve current weather from FastAPI.

Use the actual endpoint and query parameters from the backend contract.

The UI should continue displaying the Phase 2 weather card information such as:

Temperature
Condition
Feels-like
Humidity
Wind
Rain/precipitation information
UV

Do not redesign the weather card.

Only replace its data source.

9. HOURLY FORECAST INTEGRATION

Replace mock hourly data on the Home screen with real backend data.

The existing Phase 2 hourly UI should remain visually similar.

Populate:

Time
Temperature
Weather condition/icon
Rain probability
Other available data already supported by the backend model

Handle missing/null values gracefully.

Do not crash if optional weather fields are absent.

10. DAILY FORECAST INTEGRATION

Replace mock daily forecast data with real FastAPI forecast data.

Update:

Home screen

The compact forecast preview should use real data.

Forecast screen

The full 7-day forecast should use real data.

Populate:

Day/date
Weather condition
Weather icon
High temperature
Low temperature
Rain probability

Again, use the backend contract as the source of truth.

11. TEMPERATURE CHART

The Phase 2 chart uses mock data.

Replace the weather-related chart dataset with real forecast data where appropriate.

Keep the existing chart design.

Do not rebuild the entire chart unless the existing implementation cannot consume the backend data.

Ensure:

No chart crashes
Missing values handled safely
Empty dataset handled properly
Values mapped correctly
12. WEATHER ALERTS

Connect the Phase 2 Alerts screen to:

GET /api/v1/alerts

using the actual documented parameters.

Important:

This endpoint represents provider-sourced weather alerts.

Do NOT implement smart threshold-based alerts here.

Examples such as:

rain probability > threshold
temperature > threshold
wind > threshold

belong to Phase 6.

The Flutter Alerts screen should display the backend-provided alerts.

If there are no alerts:

Show a proper empty state such as:

No active weather alerts

Do not treat an empty alert response as an API failure.

13. LOCATION SEARCH

Connect the existing location search functionality to:

GET /api/v1/weather/search

using the actual API contract.

Create a usable city/location search experience.

The user should be able to search for something such as:

Madurai
Chennai
Coimbatore
Bengaluru
Mumbai

Display returned locations with useful information such as:

City
Region/state
Country
Optional coordinates

When the user selects a location:

Save the selected location in application state.
Retrieve weather for the selected location.
Refresh weather-dependent screens.

Do not call WeatherAPI directly.

14. CURRENT GPS LOCATION

Implement the existing:

lib/services/location/location_service.dart

to support getting the device's current location.

Use a simple maintained Flutter location/geolocation package only if necessary.

You must handle Android location permissions properly.

The application should:

Request location permission
        ↓
Get latitude/longitude
        ↓
Send coordinates to FastAPI
        ↓
Receive weather
        ↓
Display current weather

Do not send GPS coordinates directly to WeatherAPI.

The backend remains responsible for external weather retrieval.

15. LOCATION PERMISSION STATES

Handle at least:

Permission granted

Retrieve location.

Permission denied

Show a useful message and allow manual city search.

Permission denied permanently

Tell the user that location permission needs to be enabled from device settings.

Location service disabled

Handle gracefully.

Do not let location failure crash the application.

16. SELECTED LOCATION

Introduce a simple selected-location state.

The selected location should be usable by:

Home
Forecast
Alerts
Hourly weather
Future advisory
Future WeatherGPT

Do not build a complex multi-location management system in this phase unless the existing architecture already supports it.

At minimum, support:

Current location
OR
Selected searched city
17. LOCATION PERSISTENCE

Inspect:

lib/services/storage/storage_service.dart

If practical, persist the user's last selected location using the existing storage layer.

On application restart:

Saved location
      ↓
Load location
      ↓
Fetch weather

If no saved location exists:

Use current GPS if permission is available, otherwise use a sensible default location such as:

Madurai, Tamil Nadu

Do not introduce a complex database.

Simple local persistence is sufficient.

18. REFRESH

Implement pull-to-refresh or another suitable refresh mechanism on the main weather screens.

Refreshing should cause the app to retrieve fresh data from FastAPI.

Do not bypass the backend.

Handle refresh errors gracefully.

19. LOADING STATES

The Phase 2 reusable:

LoadingWidget

should be used where appropriate.

Examples:

Home

Show loading state while current weather is being retrieved.

Forecast

Show loading state while forecast data is being fetched.

Alerts

Show loading state while alert data is loading.

Location search

Show a compact loading indicator while searching.

Avoid unnecessary full-screen loading if only one component is refreshing.

20. ERROR STATES

Use the existing:

ErrorDisplayWidget

or improve it where necessary.

Handle:

Backend unavailable
Connection refused
Timeout
Invalid response
HTTP 4xx
HTTP 5xx
Empty result
Location not found

Error messages should be understandable to normal users.

Avoid displaying raw stack traces or raw JSON errors.

Example:

Unable to fetch weather right now.
Please check your connection and try again.
21. RETRY

Where practical, provide a:

Retry

action on error states.

Retry should repeat the relevant API request.

Do not force the user to restart the app.

22. CHAT SCREEN BOUNDARY

DO NOT CONNECT the WeatherGPT chat to the backend yet.

The chat remains Phase 2 mock/local functionality.

Keep:

WeatherGPT Chat

using mock responses.

Phase 5 will replace it with the real AI orchestration.

Do not accidentally introduce chat API calls during this phase.

23. ADVISORY SCREEN BOUNDARY

Keep the Phase 2 advisory screen using mock data.

Do not connect advisory calculations to live weather yet.

The actual advisory engine belongs to Phase 6.

24. CLIMATE SCREEN BOUNDARY

Keep the Phase 2 climate screen using mock historical data.

Do not replace it with live climate backend data.

Climate integration belongs to Phase 7.

25. TAMIL BOUNDARY

Do NOT implement real localization in this phase.

The English/Tamil selector can remain UI-only.

Real localization belongs to Phase 8.

26. VOICE BOUNDARY

Do NOT implement real STT/TTS.

The microphone button remains a UI placeholder.

Voice functionality belongs to Phase 9.

27. MOCK DATA MIGRATION

Do not immediately delete:

lib/data/mock_data.dart

The project still needs mock data for:

Chat
Advisory
Climate
Other future/deferred functionality

Remove or stop using mock data only where real backend data is now available.

At the end of this phase:

Real backend data
Current weather
Forecast
Hourly weather
Weather alerts
Location search
Mock data
Chat
Advisory
Climate
Tamil
Voice

Document this distinction.

28. HOME SCREEN BEHAVIOR

The Home screen should now work approximately like this:

App starts
    ↓
Load saved/current location
    ↓
Request backend current weather
    ↓
Request forecast/hourly data
    ↓
Request alerts
    ↓
Display real weather

Do not make unnecessary duplicate API requests.

Where multiple pieces of data can reasonably be retrieved from one backend operation, reuse the response instead of making redundant requests.

29. NETWORK ARCHITECTURE

Do not put networking logic inside widgets.

Avoid code like:

FutureBuilder(
  future: http.get(...)
)

directly inside screen widgets when a service/repository abstraction already exists.

Prefer:

Screen
 ↓
State/Provider
 ↓
Repository
 ↓
ApiService
 ↓
FastAPI

Keep implementation proportional to the prototype.

30. ICONS / WEATHER VISUALS

The backend may return text/icon information different from the Phase 2 mock data.

Create or update a small utility responsible for mapping backend weather conditions into Flutter-friendly visual representations.

Use:

lib/core/utils/weather_utils.dart

where appropriate.

Do not duplicate condition-mapping logic across multiple screens.

Handle common conditions such as:

Sunny
Clear
Partly cloudy
Cloudy
Overcast
Rain
Heavy rain
Thunderstorm
Mist/Fog

Add sensible fallback behavior for unknown conditions.

31. API ERROR MAPPING

The API layer should convert technical failures into application-level exceptions/states.

For example:

Timeout
   ↓
ApiTimeoutException
HTTP 404
   ↓
LocationNotFoundException
HTTP 503
   ↓
ServiceUnavailableException

Do not expose raw backend implementation details to UI widgets.

32. SECURITY

Do not place WeatherAPI credentials anywhere in Flutter.

Flutter must ONLY know:

FastAPI base URL

Never include:

WEATHER_API_KEY

in:

Flutter source
Flutter assets
Flutter config
Git
UI
API requests from Flutter

The WeatherAPI key belongs exclusively to the backend.

33. TESTING

Update/create Flutter tests for the integrated functionality where practical.

At minimum test:

API service
Successful current-weather response parsing
Forecast parsing
Location search parsing
Alerts parsing
Error response handling
UI/state
Loading state
Success state
Error state
Empty alerts state
Location

Test the location-service behavior where practical through mocking/abstraction rather than requiring physical GPS during automated tests.

Do not make automated tests dependent on:

A live FastAPI server
A live WeatherAPI key
Real GPS hardware

Use mocked API responses.

34. MANUAL VERIFICATION

After implementation, run the backend:

cd backend/weathergpt_api
.venv\Scripts\activate
uvicorn app.main:app --reload

Then run Flutter.

For Android emulator, ensure the configured backend host can reach the PC.

Test:

Home
Current weather
Hourly weather
Daily forecast
Alerts preview
Location
Forecast
Hourly
Daily
Temperature chart
Alerts
Real backend alert response
Empty-alert state
Location
Search Madurai
Select Madurai
Weather updates
GPS
Request permission
Allow permission
Weather loads for current coordinates
Error handling

Temporarily make backend unavailable and ensure the app displays a friendly error rather than crashing.

35. DO NOT REQUIRE BACKEND FOR CHAT/CLIMATE/ADVISORY

Because these remain mocked in Phase 4, they should continue to work even when weather API integration is unavailable.

Keep the application modular.

36. DOCUMENTATION UPDATE — MANDATORY

This is a strict requirement.

After implementation, update the relevant .md documentation files.

Do not leave documentation describing Phase 2 mock weather integration when the app now uses real backend data.

At minimum review:

Root README

Update:

Phase 4 completed
Flutter ↔ FastAPI integration completed
Real weather data now displayed in Flutter
Location search implemented
GPS/current location support implemented if actually completed
Error/loading handling
Remaining mocked functionality

Clearly state that:

Current Weather → Real backend
Forecast → Real backend
Hourly → Real backend
Alerts → Real backend
Location Search → Real backend

Chat → Mock
Advisory → Mock
Climate → Mock
Tamil → UI only
Voice → UI only
Frontend README

Update:

API integration
Backend URL configuration
Location configuration
Android emulator instructions
Physical-device instructions
Real vs mock functionality
Error/loading behavior
How to run the frontend with the backend
Architecture

Update:

docs/architecture/ARCHITECTURE.md

to reflect the actual Phase 4 data flow:

Flutter Screen
      ↓
State / Repository
      ↓
ApiService
      ↓
FastAPI
      ↓
WeatherAPI.com

Also document the location flow:

GPS / City Search
       ↓
Flutter
       ↓
FastAPI
       ↓
WeatherAPI
API Contract

Update only if the actual frontend integration reveals a contract issue.

Do not invent endpoints.

Do not casually change backend routes.

Data Models

Update:

docs/api/DATA_MODELS.md

only where the actual Flutter/backend mapping introduced by this phase requires it.

Phase Documentation

Keep the project's phase status accurate.

Clearly distinguish:

Implemented
Mocked
Planned
37. DOCUMENTATION ACCURACY RULE

Never claim:

"GPS implemented"

unless it actually works.

Never claim:

"Flutter is fully integrated"

unless the documented weather endpoints actually work from Flutter.

Never claim:

"All features are live"

because Chat, Advisory, Climate, Tamil, and Voice remain deferred.

Documentation must describe the real repository state after this task.

38. DO NOT MODIFY BACKEND UNNECESSARILY

The Phase 3 backend is already functional.

Do not change backend logic simply to make frontend integration easier.

Only modify backend code if you discover a genuine compatibility problem with the documented contract.

If a backend change is necessary:

Explain why.
Keep the change minimal.
Update relevant backend documentation.
Retest backend functionality.
39. DO NOT REDESIGN THE PHASE 2 UI

This is an integration phase.

Preserve the visual structure already created in Phase 2.

Only make UI changes necessary for:

Live data
Loading
Errors
Location selection
Refresh
Dynamic states

Do not replace the application's visual design.

40. FINAL VERIFICATION

Before reporting completion:

Run:

flutter pub get
flutter analyze
flutter test

Run the application and manually verify the weather integration.

Also verify:

No Dart analyzer errors
No obvious runtime exceptions
No render overflow
No broken navigation
No hardcoded WeatherAPI key
Backend remains functional
.env remains uncommitted
41. FINAL REPORT

When finished, provide:

Implemented

List the actual integration features.

API Endpoints Used

List the actual FastAPI endpoints consumed by Flutter.

Files Created/Modified

List important files.

Real vs Mock

Clearly show:

REAL
MOCK
PLANNED
Location

Explain:

City search
GPS
Selected-location behavior
Persistence if implemented
Error Handling

Explain implemented error states.

Tests

Report:

flutter pub get
flutter analyze
flutter test
Manual testing
Documentation Updated

List every .md file actually modified.

Backend Changes

State whether the backend was left unchanged or modified.

Known Issues

List only genuine issues.

MOST IMPORTANT RULES
This is Phase 4 only.
Connect Flutter to the existing FastAPI backend.
Use the existing API contract as the source of truth.
Do not make Flutter call WeatherAPI directly.
Replace mock weather data with real backend data.
Keep Chat, Advisory, Climate, Tamil, and Voice deferred.
Preserve the Phase 2 visual design.
Support friendly loading/error states.
Support city search and current-location handling where implemented.
Never expose the WeatherAPI key to Flutter.
Do not unnecessarily modify the backend.
Update the relevant .md files after implementation.
Documentation must distinguish real, mocked, and planned functionality.
Test before reporting completion.
Start by inspecting the existing Flutter code, backend API contract, and documentation. Then implement Phase 4 systematically.
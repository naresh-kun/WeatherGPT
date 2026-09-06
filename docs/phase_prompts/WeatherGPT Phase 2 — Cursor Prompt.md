# WeatherGPT — Phase 2: Flutter UI Implementation

You are working on the **WeatherGPT SIH prototype**.

## Project Goal

WeatherGPT is a conversational AI weather application being built as a **decent-looking, functional SIH prototype**, not a production-scale meteorological platform.

Phase 1 (project foundation/scaffold) is already completed and verified.

Your task is to implement **Phase 2 — Flutter UI**.

---

# IMPORTANT SCOPE RULE

This phase is **UI ONLY**.

Do NOT implement:

- Weather API integration
- FastAPI API calls
- LLM integration
- Real authentication
- Database integration
- Real GPS/location integration
- Real alerts engine
- Real climate analysis backend
- Real STT/TTS
- Any production backend logic

Use **realistic local dummy/mock data** wherever data is required.

The purpose of this phase is to create a polished Flutter prototype that can later be connected to the backend.

---

# Existing Project Structure

The Flutter project is located at:

`frontend/weathergpt_app/`

The project already contains the initial scaffold and placeholder files created during Phase 1.

Do NOT unnecessarily restructure the existing project.

Reuse the existing folders and files wherever practical.

---

# PHASE 2 OBJECTIVE

Build a complete and visually polished Flutter UI for WeatherGPT with the following screens:

1. Home
2. WeatherGPT Chat
3. Forecast
4. Alerts
5. Advisory
6. Climate
7. Settings

The application should feel like a cohesive modern weather application rather than a collection of unrelated screens.

---

# DESIGN DIRECTION

Create a modern, clean and visually impressive weather-app interface suitable for an SIH demonstration.

Use:

- Modern Material 3 principles
- Rounded cards
- Good spacing
- Clear typography hierarchy
- Weather-related visual elements
- Subtle gradients where appropriate
- Icons
- Consistent padding and margins
- Consistent corner radius
- Consistent card styles
- Good use of whitespace
- Responsive layouts

The UI should look professional without becoming unnecessarily complex.

Avoid excessive animations or visual effects that could hurt performance.

---

# 1. APP NAVIGATION

Implement the main application navigation.

Use the existing navigation structure where possible.

Create a bottom navigation experience for the primary sections.

Recommended navigation:

- Home
- WeatherGPT
- Alerts
- Advisory
- Climate

Settings can be accessed from the Home/app bar or another appropriate location.

Make navigation functional.

Each tab must open its corresponding screen.

The selected navigation item should have clear visual feedback.

---

# 2. HOME SCREEN

Create the main WeatherGPT dashboard.

The Home screen should contain:

### Location

Show a dummy current location such as:

`Madurai, Tamil Nadu`

Include a location icon.

### Current Weather Card

Display realistic dummy values such as:

- Temperature
- Weather condition
- Feels-like temperature
- Humidity
- Wind speed
- Rain probability
- UV index

Example:

`29°C`
`Partly Cloudy`

Do not hardcode these values throughout multiple widgets.

Create centralized mock data so it can later be replaced by API responses.

### Quick Weather Metrics

Create attractive metric cards for:

- Humidity
- Wind
- Rain
- UV

### Hourly Forecast

Create a horizontally scrollable hourly forecast.

Example:

10 PM → 29°
11 PM → 28°
12 AM → 27°
1 AM → 27°
2 AM → 26°

Use appropriate weather icons.

### 7-Day Preview

Show a compact forecast preview for several days.

Example:

Today
Mon
Tue
Wed
Thu

Display:

- Weather icon
- High/low temperature
- Rain probability

### WeatherGPT Prompt Suggestions

Create tappable suggestion chips/cards such as:

- "Will it rain tomorrow?"
- "Do I need an umbrella?"
- "Is tomorrow good for travelling?"
- "How hot will tomorrow be?"

These do not need real AI functionality yet.

When tapped, they can navigate to the WeatherGPT screen and optionally populate the input field.

### Alerts Preview

Show a small section for active weather warnings.

Example:

`Rain expected tomorrow`

with an appropriate warning icon.

Add a "View all" action that navigates to Alerts.

---

# 3. WEATHERGPT CHAT SCREEN

Create a polished conversational chat interface.

The screen should contain:

### App Bar

Title:

`WeatherGPT`

Subtitle or status:

`Your AI Weather Assistant`

### Chat Area

Display realistic dummy conversation.

Example:

User:

`Will it rain tomorrow in Madurai?`

WeatherGPT:

`There is a high chance of rain tomorrow afternoon. You may want to carry an umbrella if you are going outdoors.`

Add several messages to demonstrate the UI.

Distinguish user and AI messages visually.

### Suggested Questions

Add suggestion chips such as:

- Will it rain tomorrow?
- Is it good for outdoor activities?
- What's the temperature?
- Do I need an umbrella?

### Message Input

Create:

- Text input
- Send button
- Microphone/voice button

The send button does NOT need to call the backend yet.

For this phase, simulate responses or simply demonstrate the interaction.

### Voice Button

Include a microphone button visually, but do NOT implement real speech recognition.

Create the UI in a way that Phase 9 can later connect STT/TTS.

---

# 4. FORECAST SCREEN

Create a dedicated forecast screen.

Include:

### Hourly Forecast

Scrollable hourly forecast with:

- Time
- Temperature
- Weather icon
- Rain probability

### 7-Day Forecast

Create attractive forecast cards/list items containing:

- Day
- Weather condition
- Icon
- High temperature
- Low temperature
- Rain probability

### Temperature Trend

Create a simple temperature chart using an appropriate Flutter chart solution.

Use dummy data.

The chart should visually show temperature variation over the selected period.

Keep the chart architecture modular so real API data can later replace the dummy dataset.

---

# 5. ALERTS SCREEN

Create a weather alerts dashboard.

Include multiple realistic dummy alerts.

Example categories:

### Heavy Rain

`Heavy rainfall expected tomorrow afternoon.`

### Heat

`High temperatures expected during the afternoon.`

### Strong Wind

`Strong winds may affect outdoor activities.`

Each alert should have:

- Severity
- Icon
- Title
- Description
- Time/date
- Optional affected location
- Clear visual severity indication

Use different visual treatments for:

- Informational
- Moderate
- Severe

Do not implement the actual alert rule engine yet.

This is UI only.

---

# 6. ADVISORY SCREEN

Create a weather advisory dashboard.

Categories:

🌾 Farming
✈️ Travel
🏃 Outdoor
🚗 Driving

Each category should have an attractive card.

When the user opens a category, show an example advisory.

Example Farming advisory:

`Tomorrow may not be ideal for spraying pesticides because rain probability is high and wind speeds may increase in the afternoon.`

Clearly indicate:

- Recommendation
- Reason
- Weather factors considered

Use dummy values.

Do NOT implement actual advisory calculations yet.

---

# 7. CLIMATE SCREEN

Create a climate/historical analysis screen.

Use mock historical data.

Include:

### Temperature Trend

Line chart showing a multi-year trend.

### Rainfall Trend

Chart showing historical rainfall variation.

### Summary

Example:

`Average temperature has shown a gradual increase over the selected period.`

### Time Range Selector

Provide options such as:

- 5 Years
- 10 Years
- 20 Years

Changing the selection can switch between prepared mock datasets.

This is only a UI demonstration at this stage.

---

# 8. SETTINGS SCREEN

Create a clean settings interface.

Include:

### Location

Current location:

`Madurai, Tamil Nadu`

### Language

Show:

`English`

Also show Tamil as an available option.

The language switching logic does NOT need to be implemented in this phase.

### Notifications

Toggle:

`Weather Alerts`

### Voice

Toggle:

`Voice Responses`

### Units

Temperature:

`°C`

Wind:

`km/h`

### About

Include:

`WeatherGPT`

`SIH Prototype`

`AI-powered conversational weather assistant`

Keep the settings visually organized into sections.

---

# 9. SPLASH SCREEN

Implement a simple polished splash screen.

Include:

- WeatherGPT logo/icon
- App name
- Short tagline

Example:

`Your Intelligent Weather Assistant`

Use a short transition to the main application.

Do not create a complicated animated splash.

---

# 10. REUSABLE WIDGETS

Use the existing widget structure.

Create reusable widgets where appropriate instead of duplicating UI code.

Potential reusable components:

- WeatherCard
- WeatherMetricCard
- ForecastCard
- AlertCard
- AdvisoryCard
- ChatBubble
- SuggestionChip
- SectionHeader
- LoadingWidget
- ErrorWidget
- EmptyStateWidget
- CommonCard
- TemperatureChart
- RainfallChart

Only create widgets that provide meaningful reuse.

Do not over-engineer.

---

# 11. MOCK DATA ARCHITECTURE

Create a centralized and maintainable place for dummy data.

Do NOT scatter random weather values across UI files.

Mock data should be structured so that Phase 3/4 can replace it with actual backend responses with minimal UI changes.

Use appropriate model classes where the existing project structure expects models.

Keep presentation and mock data reasonably separated.

---

# 12. LOADING, ERROR AND EMPTY STATES

Even though this phase uses dummy data, create reusable UI states for future API integration.

Implement reusable components/screens for:

- Loading
- Error
- Empty data

Demonstrate at least the loading/error components somewhere appropriate if useful, but do not artificially make the app look broken.

---

# 13. THEME

Use the existing:

`core/theme/app_theme.dart`

to define a consistent application theme.

Centralize:

- Colors
- Typography
- Card styling
- Button styling
- Input styling
- Navigation styling
- Common dimensions where appropriate

Do not hardcode the same styling repeatedly across screens.

Use Material 3 where appropriate.

---

# 14. RESPONSIVENESS

The UI must work properly on common Android phone screen sizes.

Avoid:

- Overflow errors
- Fixed-width layouts that break on smaller screens
- Excessive hardcoded positioning
- Unnecessary absolute positioning

Use:

- Expanded
- Flexible
- ListView
- SingleChildScrollView
- LayoutBuilder
- SafeArea

where appropriate.

---

# 15. CODE QUALITY

Follow clean Flutter/Dart practices.

Requirements:

- Null safety
- Meaningful class names
- Meaningful variable names
- Small reusable widgets
- Avoid unnecessary duplication
- Avoid unnecessary packages
- Keep architecture compatible with the existing scaffold
- Do not introduce complex state-management frameworks unless genuinely necessary for this phase

Do not add dependencies simply for visual effects when Flutter's built-in capabilities are sufficient.

---

# 16. FUNCTIONALITY ALLOWED IN THIS PHASE

The UI should feel interactive.

Implement simple local interactions where useful:

- Bottom navigation
- Navigation between screens
- Tapping forecast items
- Tapping alert cards
- Opening advisory categories
- Chat input interaction
- Suggestion chip interaction
- Settings toggles
- Time-range selector
- Basic local state changes

But all data remains dummy/local.

---

# 17. BACKEND BOUNDARY

Do NOT call:

- FastAPI
- Weather APIs
- LLM APIs
- External services

during Phase 2.

The backend remains untouched unless absolutely necessary for compatibility.

The Flutter UI must be designed so that API integration can be added later without redesigning the whole interface.

---

# 18. EXISTING DOCUMENTATION

Before modifying anything, inspect the existing documentation relevant to the Flutter project, especially:

- Root `README.md`
- `frontend/weathergpt_app/README.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/api/API_CONTRACT.md`
- `docs/api/DATA_MODELS.md`

Use the existing documentation as the source of truth for the intended architecture.

Do not contradict documented API contracts.

---

# 19. DOCUMENTATION UPDATE — MANDATORY

This is a strict requirement.

After implementation, update the relevant `.md` files so documentation accurately reflects the actual state of the project.

At minimum, review and update where appropriate:

### Root README

Document:

- Phase 2 completion
- Current frontend status
- Screens implemented
- Current use of mock data
- Explicitly state that API/AI integration has NOT yet been implemented

### Frontend README

Document:

- Implemented screens
- Navigation
- Reusable widgets
- Mock-data approach
- Current limitations
- How to run the Flutter application

### Architecture Documentation

Update:

`docs/architecture/ARCHITECTURE.md`

to accurately describe the current Phase 2 frontend architecture and the fact that the UI currently consumes local/mock data.

### API Documentation

Do NOT invent new backend APIs.

Only update `docs/api/API_CONTRACT.md` if necessary to clarify frontend usage or future integration points.

### Data Models

Update `docs/api/DATA_MODELS.md` only where the actual Flutter model structure introduced by this phase needs to be documented.

### Documentation Accuracy Rule

Do NOT claim that weather APIs, AI, alerts engines, climate processing, multilingual support, or voice functionality are implemented unless they actually are.

Clearly distinguish:

- Implemented
- Mocked
- Planned

---

# 20. DO NOT CHANGE BACKEND FEATURES

Do not implement backend functionality during this task.

Do not create fake endpoints just to make the frontend work.

The backend remains at the Phase 1 scaffold state.

---

# 21. VERIFICATION

After implementation:

1. Run `flutter pub get`
2. Analyze the project
3. Build/run the application
4. Check all major screens
5. Check navigation
6. Check for overflow/layout issues
7. Check that there are no obvious runtime exceptions
8. Check that the application works with dummy data
9. Verify that existing project structure has not been unnecessarily damaged

Fix any issues discovered.

---

# 22. FINAL REPORT

When finished, provide a concise implementation report containing:

### Implemented

List the UI features actually completed.

### Files Created/Modified

List the important files changed.

### Mock Data

Explain where mock data is stored.

### Documentation Updated

List every `.md` file you actually updated.

### Verification

Report:

- `flutter pub get`
- Static analysis
- Application run/test
- Navigation checks
- Any remaining warnings/issues

### Not Implemented Yet

Explicitly list features intentionally deferred to later phases, especially:

- Weather API
- Backend integration
- LLM
- Real alerts
- Real advisory engine
- Real climate backend
- Tamil localization
- STT/TTS

---

# MOST IMPORTANT RULES

1. This is **Phase 2 only**.
2. Focus on creating a **polished Flutter UI**.
3. Use **dummy data**.
4. Do not implement backend/API/AI functionality.
5. Reuse the existing project structure.
6. Avoid unnecessary dependencies and over-engineering.
7. Keep the UI ready for future API integration.
8. **Update the relevant `.md` files after implementation.**
9. Documentation must reflect what is **actually implemented**, not what is planned.
10. Test the application before reporting completion.

Start by inspecting the existing Flutter scaffold and documentation, then implement Phase 2 systematically.
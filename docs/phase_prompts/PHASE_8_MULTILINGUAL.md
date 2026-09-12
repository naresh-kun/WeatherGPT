Phase 8 — Tamil / Multilingual Support Specification

Create:

docs/phase_prompts/PHASE_8_MULTILINGUAL.md

Paste this entire specification into it.

# WeatherGPT — Phase 8: Tamil / Multilingual Support

## Goal

Add robust multilingual support to WeatherGPT, with Tamil as the priority language.

Users must be able to select a preferred language and receive weather-related information in that language across the major WeatherGPT features.

Phase 8 must extend the existing Phase 1–7 implementation without breaking existing English functionality.

---

## Supported Languages

Initial supported languages:

1. English (`en`)
2. Tamil (`ta`)

Design the language layer so additional languages can be added later without major architectural changes.

Do NOT implement additional languages in Phase 8 unless required for architecture/testing.

---

## Core Requirements

Language preference must affect:

- Flutter UI text
- WeatherGPT chat responses
- Smart alerts
- Weather advisories
- Climate insights

English remains the default language.

Tamil must be a real supported language, not a placeholder.

---

# 1. Flutter Localization

Implement proper Flutter localization using the project's existing architecture.

Preferred approach:

- Flutter localization / `gen_l10n`
- ARB translation files
- Avoid hardcoding translated strings throughout widgets

Create an appropriate localization structure such as:

```text
lib/l10n/
    app_en.arb
    app_ta.arb

Use the project's existing Flutter conventions where appropriate.

Translate important user-facing strings including:

Navigation labels
Home screen text
Weather labels
Forecast labels
Alerts
Advisory
Climate
Chat UI
Settings
Loading states
Empty states
Error messages
Retry buttons
Location-related labels
Voice-related labels if already present in the UI

Do NOT translate API URLs, model identifiers, log messages, code identifiers, or developer-only text.

2. Language Preference

Add a language selector to Settings.

Example:

Language

English
தமிழ்

The selected language must:

update the UI
persist locally
survive app restart
default to English

Use the existing lightweight local persistence approach rather than introducing a large state-management dependency.

3. WeatherGPT Chat Language

The chat must respond in the currently selected language.

When Tamil is selected:

User:
"இப்போது வானிலை எப்படி இருக்கிறது?"

WeatherGPT should answer in Tamil.

When English is selected, responses remain in English.

The backend must receive the requested language with the chat request, or otherwise have a reliable way to determine it from the request.

Preferred request structure:

{
  "message": "...",
  "lat": 0.0,
  "lon": 0.0,
  "language": "ta"
}

Use the existing chat architecture.

Do NOT expose the Gemini API key.

4. Gemini Language Instructions

Update the existing WeatherGPT Gemini system instructions so that:

English requests/responses use English
Tamil mode uses natural Tamil
Weather facts must continue to come only from the injected real weather context
The language instruction must not allow the model to invent weather information
Non-weather scope restrictions from Phase 5 remain intact

Do NOT create a separate LLM architecture.

Do NOT replace Gemini 3.7 Flash in Phase 8.

Do NOT implement Gemini fallback in this phase; that belongs to the later reliability/UI phase.

5. Alerts Localization

Smart Alerts from Phase 6 must support Tamil.

Examples:

English:

Extreme Heat Alert
Temperature is dangerously high.

Tamil:

அதிக வெப்ப எச்சரிக்கை
வெப்பநிலை மிகவும் அதிகமாக உள்ளது.

Alert severity, rule logic, thresholds, and sensor values remain unchanged.

Only the user-facing textual content is localized.

Alert decisions MUST remain deterministic and must NOT depend on Gemini.

6. Advisory Localization

Rule-based advisories must support Tamil.

Examples:

English:

Stay hydrated and avoid prolonged exposure to high temperatures.

Tamil:

போதுமான அளவு தண்ணீர் குடித்து, அதிக வெப்பத்தில் நீண்ட நேரம் இருப்பதைத் தவிர்க்கவும்.

Categories such as:

General
Health
Outdoor
Travel
Agriculture

must display appropriately in Tamil when Tamil mode is active.

The advisory rules remain deterministic.

Do NOT use Gemini to generate advisory text.

7. Climate Insight Localization

Phase 7 climate insights must support Tamil.

Example:

English:

Temperature is above the historical baseline.

Tamil:

வெப்பநிலை வரலாற்று சராசரியை விட அதிகமாக உள்ளது.

Climate calculations remain exactly the same.

Only presentation and textual interpretation are localized.

8. Data Model / API Design

Extend existing API request/response models only where required.

Prefer a language code:

en
ta

Keep API fields backward-compatible wherever practical.

Existing clients that do not provide language should continue to work and default to English.

Do NOT break existing Phase 1–7 API contracts.

Document any new fields in:

docs/api/API_CONTRACT.md
9. Translation Strategy

Use human-authored/static translations for UI, alerts, advisories, and climate insights.

Do NOT call Gemini just to translate UI strings.

For dynamic WeatherGPT chat responses:

Gemini may generate the answer in the selected language
Weather facts still come from the existing weather context

Tamil text should be natural and understandable to ordinary users rather than overly literal machine-style translation.

10. Location / Weather Terminology

Use clear Tamil terminology for common weather concepts.

Examples may include:

Temperature → வெப்பநிலை
Feels like → உணரப்படும் வெப்பநிலை
Humidity → ஈரப்பதம்
Rain → மழை
Wind → காற்று
Forecast → வானிலை முன்னறிவிப்பு
Alert → எச்சரிக்கை
Advisory → அறிவுரை
UV Index → UV குறியீடு

Keep units and numerical values unchanged.

Example:

32°C
70% humidity
18 km/h wind

must remain numerically accurate.

11. UI Requirements

The language switch must update without requiring the user to reinstall the app.

Important screens:

Home
Chat
Forecast
Alerts
Advisory
Climate
Settings
Location/search where user-facing strings exist

Ensure Tamil text renders correctly.

Use Flutter's normal Unicode support and verify that the selected fonts/platform can display Tamil characters.

Do not introduce a custom font system unless required.

12. Testing

Add backend tests for:

language field accepted
default language is English
Tamil chat instruction is applied
English chat remains unchanged
invalid language handling
backward compatibility when language is omitted
localized alert/advisory content where generated by backend
localized climate insight output where applicable

Add Flutter tests for:

English default
Tamil selection
language persistence
app restart preference restoration
localized navigation/UI strings
Tamil chat request payload
alert/advisory localization
climate insight localization
fallback to English for missing translations

Run complete existing backend and Flutter test suites.

13. Verification

Backend:

cd backend/weathergpt_api
.venv\Scripts\python.exe -m pytest

Frontend:

cd frontend/weathergpt_app
flutter test

Analyzer:

flutter analyze

Manual verification:

Launch the Flutter app.
Open Settings.
Change language from English to Tamil.
Verify major UI text changes.
Open Chat.
Ask a weather question.
Verify the response is in Tamil and still grounded in real weather data.
Open Alerts.
Open Advisory.
Open Climate.
Verify Tamil content appears correctly.
Switch back to English.
Restart the app and verify the language preference persists.
14. Phase 1–7 Preservation

Do NOT break:

Foundation
Flutter UI
WeatherAPI integration
Flutter ↔ FastAPI integration
Gemini 3.7 Flash chat
Smart Alerts
Advisories
Climate Intelligence

Specifically preserve:

WeatherAPI data accuracy
Alert thresholds/rules
Climate calculations
Gemini weather-grounding
existing API contracts
location and GPS functionality

Do not rewrite previous phases unnecessarily.

15. OUT OF SCOPE

Do NOT implement:

Voice / STT / TTS
Gemini fallback model
Push notifications
Authentication  
RAG / vector database
Climate prediction / machine learning
New weather providers
Major chat UI redesign
APK/deployment work

Those belong to later phases.

16. Documentation

Update:

README.md
backend/weathergpt_api/README.md
docs/api/API_CONTRACT.md
docs/architecture/ARCHITECTURE.md

Update:

docs/phase_prompts/PHASE_8_MULTILINGUAL.md

Clearly mark:

REAL
MOCK
PLANNED

Document the supported languages and language preference behavior.

17. Final Report

Do not claim Phase 8 complete unless implementation and verification succeed.

Report:

Files created/modified
Localization architecture
Supported languages
Language persistence mechanism
Chat language implementation
Alert/advisory localization
Climate localization
Backend tests
Flutter tests
flutter analyze
Manual verification
Phase 1–7 regression status
REAL / MOCK / PLANNED status
Any known limitations

SUCESSFULL IMPLEMENTATION
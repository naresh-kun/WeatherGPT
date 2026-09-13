# WeatherGPT â€” Phase 10: Interactive Chat, AI Fallback & Reliability

## Goal

Upgrade the existing WeatherGPT chat experience into a more interactive, polished, weather-aware assistant while improving AI reliability for real-world demonstration use.

Phase 10 combines:

1. Interactive Chat UI
2. Weather-aware chat components
3. Gemini primary/fallback model handling
4. Better timeout and error handling
5. API-call efficiency improvements
6. Final chat reliability and UX polish

Phase 1â€“9 are already implemented and must be preserved.

---

# 1. CURRENT ARCHITECTURE

Existing system:

Flutter
    â†“
FastAPI
    â†“
WeatherService
    â†“
WeatherAPI
    â†“
real weather context
    â†“
Gemini 3.7 Flash
    â†“
WeatherGPT response

Phase 10 must preserve this architecture.

Do NOT move API keys into Flutter.

Do NOT create a second backend architecture.

---

# 2. PRIMARY AND FALLBACK GEMINI MODELS

## Primary

Use:

gemini-3.7-flash

## Fallback

Use:

gemini-3.6-flash

Both model identifiers must be configurable through backend settings/environment variables.

Suggested configuration:

GEMINI_MODEL=gemini-3.7-flash
GEMINI_FALLBACK_MODEL=gemini-3.6-flash

Do not hardcode the fallback model throughout the code.

---

# 3. GEMINI FALLBACK FLOW

Implement:

User request
    â†“
WeatherAPI weather grounding
    â†“
Primary Gemini 3.7 Flash
    â†“
Success?
    â”œâ”€â”€ YES â†’ return response
    â””â”€â”€ NO transient failure
            â†“
       bounded retry/backoff
            â†“
       still unavailable?
            â†“
       Gemini 3.6 Flash
            â†“
       Success?
          â”œâ”€â”€ YES â†’ return response
          â””â”€â”€ NO â†’ clear AI-unavailable error

Transient errors include where appropriate:

- HTTP 503
- HTTP 429
- temporary timeout/network failures

Do NOT fallback for permanent errors such as:

- invalid API key
- invalid request
- unsupported model
- malformed request

Avoid retry storms.

Maximum retry policy must be bounded and documented.

Do not stack multiple independent retry systems unnecessarily.

Inspect the existing google-genai SDK behavior before adding custom retries. Avoid excessively long waits caused by nested SDK retry + application retry + fallback.

The entire user-visible chat request should have a bounded maximum duration.

---

# 4. SAME WEATHER CONTEXT FOR BOTH MODELS

The fallback model must receive the same verified weather context as the primary model.

Do NOT fetch a second weather source merely because the fallback model is used.

Flow:

WeatherAPI
   â†“
WeatherService
   â†“
weather context
   â”œâ”€â”€ Gemini 3.7 Flash
   â””â”€â”€ Gemini 3.6 Flash

WeatherAPI remains the source of weather facts.

The fallback changes only the language model.

---

# 5. CHAT TIMEOUT

Inspect the current Flutter timeout implementation.

Normal API requests may retain the existing normal timeout.

The WeatherGPT chat request must have a dedicated longer timeout suitable for real Gemini responses.

Target:

Chat timeout = 60 seconds

Do not increase every API request to 60 seconds.

Weather, forecast, alerts and advisory requests should retain appropriate shorter timeouts.

---

# 6. PROVIDER-SPECIFIC ERROR HANDLING

Do NOT use:

"Weather service is temporarily unavailable."

for every server error.

Use clear error categories.

Examples:

WeatherAPI failure:

"We're unable to retrieve current weather right now. Please try again."

Gemini 503 after fallback:

"WeatherGPT is temporarily busy. Please try again."

Gemini 429 after fallback:

"WeatherGPT is temporarily rate-limited. Please try again later."

Chat timeout:

"WeatherGPT is taking longer than expected. Please try again."

Connection failure:

"Unable to reach the WeatherGPT server. Check your connection."

Never expose:
- API keys
- provider credentials
- stack traces
- raw provider error payloads
- internal implementation details

---

# 7. INTERACTIVE CHAT UI

Upgrade the existing ChatScreen without replacing it.

The chat should feel more like a weather assistant than a simple text messaging screen.

Add:

## A. Contextual Quick Actions

Show compact action chips such as:

- What's the temperature?
- Will it rain?
- Any weather alerts?
- Is it good for outdoor activities?
- What is tomorrow's forecast?
- Do I need an umbrella?

Tapping a chip should send the corresponding weather query through the existing ChatProvider.

Avoid excessive hardcoded suggestions.

Suggestions should be context-aware where practical.

---

# 8. WEATHER-AWARE CHAT CARD

Where appropriate, display a compact weather summary card alongside the assistant response.

Example:

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ ðŸ“ Madurai               â”‚
â”‚ ðŸŒ¡ 29Â°C   Feels 31Â°C     â”‚
â”‚ â˜ Overcast              â”‚
â”‚ ðŸ’§ 64% humidity          â”‚
â”‚ ðŸ’¨ 14 km/h               â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

The card must use structured weather data already available from the backend.

Do NOT parse weather numbers out of Gemini's free-form text.

Do NOT let Gemini invent values.

The visual card must come from verified weather data.

---

# 9. FORECAST / WEATHER RESPONSE ENHANCEMENTS

Where appropriate, provide a compact structured card for forecast-related responses.

Example:

Today

Now     2 PM     4 PM     6 PM
29Â°C    31Â°C     30Â°C     27Â°C
â˜       ðŸŒ¤       ðŸŒ§       ðŸŒ§

Use existing WeatherService forecast data.

Do not introduce a second weather provider.

Do not build a large dashboard inside the chat.

Keep the card compact and readable.

If determining whether a forecast card is appropriate requires complex natural-language intent detection, prefer a simple deterministic approach or explicit quick-action triggers instead of adding a new LLM call.

---

# 10. TYPING / THINKING UX

Improve the waiting state.

While waiting for a chat response, display:

WeatherGPT is checking the weather...
or an equivalent localized message.

Use a subtle animated typing/processing indicator.

Disable duplicate sends while the current request is in progress.

Allow cancellation only if it can be implemented safely without breaking the request lifecycle.

---

# 11. RESPONSE BUBBLE INTERACTION

Assistant message bubbles should support:

- Speak
- Stop speaking
- optional Replay where appropriate

This must preserve Phase 9 voice functionality.

User messages remain visually distinct.

Keep scrolling behavior smooth.

When a new response arrives:
- scroll to the relevant message
- do not unexpectedly jump the user to unrelated content

---

# 12. LOCATION INTERACTION

Show the active weather location clearly in ChatScreen.

Example:

ðŸ“ Madurai

Provide an easy route to change the selected location.

Do not create a second location-management system.

Reuse existing LocationProvider and location search functionality.

Changing location should affect subsequent weather chat requests.

---

# 13. TAMIL / ENGLISH SUPPORT

Preserve Phase 8.

All interactive chat additions must support:

English:
en

Tamil:
ta

Quick action labels must be localized.

Loading/error text must be localized.

Weather card labels must be localized.

Forecast cards must support Tamil labels where applicable.

Gemini primary/fallback responses must use the currently selected language.

Do not break Tamil voice functionality from Phase 9.

---

# 14. API REQUEST EFFICIENCY

Inspect recent WeatherAPI logs.

There have been multiple repeated requests such as:

- current weather
- forecast days=1
- forecast days=7
- alert-related forecast
- advisory-related current weather
- chat-related current weather

Determine which calls are genuinely necessary.

Do not blindly remove required requests.

Where exact duplicate requests are made within a short period for the same location, reuse/cache them where safe.

The goal is:

- fewer redundant API calls
- faster UI
- lower provider usage
- no stale data problems

Use a lightweight short-lived cache only if it fits the existing architecture.

Do not introduce Redis or another external caching system.

---

# 15. API KEY / LOG SECURITY

Verify that WeatherAPI and Gemini API keys are never exposed in:

- Flutter source
- API responses
- application logs
- exception messages
- debug output

HTTP request logging must redact:

?key=<actual key>

as:

?key=***

or:

?key=[REDACTED]

Gemini credentials must also never appear in logs.

Do not disable all useful HTTP logging merely to hide credentials.

Prefer targeted redaction.

---

# 16. AFC WARNING

Inspect the existing google-genai integration.

The current project has previously shown:

"Direct use of automatic function calling (AFC) in Models.generate_content is not recommended."

Determine whether AFC is actually required.

The current WeatherGPT architecture already retrieves WeatherAPI data in WeatherService and injects it into the Gemini prompt.

If AFC is not required:
- disable unnecessary AFC behavior
- keep the existing Generate Content flow
- do not migrate the entire architecture merely to remove a harmless warning

If AFC is genuinely used:
- use the recommended google-genai pattern
- make the smallest required change

Do not introduce function calling merely for Phase 10.

---

# 17. FALLBACK TRANSPARENCY

The user does not need to see which model answered.

For normal operation:
"WeatherGPT" remains the assistant identity.

Internally log:

Primary:
gemini-3.7-flash â†’ success

or:

Primary:
gemini-3.7-flash â†’ 503
Fallback:
gemini-3.6-flash â†’ success

Do not expose model identifiers unnecessarily in the normal UI.

Do not falsely claim that the primary model answered if fallback handled the request.

---

# 18. TESTING â€” BACKEND

Add/update tests for:

- primary Gemini success
- primary Gemini 503
- primary retry
- fallback success
- primary + fallback failure
- Gemini 429 handling
- permanent Gemini error without fallback
- timeout handling
- provider-specific error responses
- API key redaction
- log sanitization
- same weather context passed to primary and fallback
- configured model selection
- configured fallback model selection

Do not perform real Gemini calls inside unit tests unless there is a specific live integration test.

---

# 19. TESTING â€” FLUTTER

Add/update tests for:

- chat success
- chat timeout
- Gemini-specific busy error
- rate-limit error
- weather-service error
- connection error
- quick action chip sending
- weather card rendering
- forecast card rendering
- loading/typing state
- duplicate-send prevention
- Tamil quick actions
- Tamil error/loading strings
- location display
- location change behavior
- voice Speak/Stop regression

---

# 20. FULL REGRESSION

Run:

Backend:

cd backend/weathergpt_api
.venv\Scripts\python.exe -m pytest

Frontend:

cd frontend/weathergpt_app
flutter test

Analyzer:

flutter analyze

Verify all previous phases:

Phase 1 â€” Foundation
Phase 2 â€” Flutter UI
Phase 3 â€” WeatherAPI
Phase 4 â€” Flutter â†” FastAPI
Phase 5 â€” Gemini WeatherGPT
Phase 6 â€” Smart Alerts
Phase 7 â€” Climate Intelligence
Phase 8 â€” Tamil/English
Phase 9 â€” Voice

Nothing from these phases may regress.

---

# 21. MANUAL VERIFICATION

Perform manual verification if the environment permits.

## Chat success

Ask:

"What's the weather right now?"

Confirm:
- real response
- real weather data
- weather card where appropriate

## Fallback

Cause or simulate a primary-model transient failure.

Confirm:

Primary 3.7 failure
â†’ fallback 3.6
â†’ user receives normal response

Do not require repeatedly hammering a real API to trigger the failure.

A controlled/mock verification is acceptable for fallback behavior.

## Timeout

Verify a slow backend response does not fail before the configured 60-second chat timeout.

## Tamil

Switch to Tamil.

Test:
"à®®à®¤à¯à®°à¯ˆà®¯à®¿à®²à¯ à®‡à®ªà¯à®ªà¯‹à®¤à¯ à®µà®¾à®©à®¿à®²à¯ˆ à®Žà®ªà¯à®ªà®Ÿà®¿ à®‡à®°à¯à®•à¯à®•à®¿à®±à®¤à¯?"

Confirm:
- Tamil response
- localized UI
- Tamil weather card labels
- voice functionality remains available

## Quick Actions

Tap at least two suggestion chips and verify messages are sent.

---

# 22. OUT OF SCOPE

Do NOT implement:

- new weather providers
- RAG/vector database
- authentication
- push notifications
- climate prediction
- major backend rewrite
- full redesign of non-chat screens
- new Phase 11/12 deployment work
- APK release work
- machine-learning prediction
- autonomous agents

Keep the work focused on Chat UX + reliability.

---

# 23. DOCUMENTATION

Update relevant:

README.md
backend/weathergpt_api/README.md
docs/api/API_CONTRACT.md
docs/architecture/ARCHITECTURE.md

Document:

- primary model
- fallback model
- retry behavior
- timeout behavior
- provider-specific errors
- interactive chat components
- caching/duplicate-request handling
- credential log redaction

Clearly mark:

REAL
MOCK
PLANNED

---

# 24. FINAL REPORT

Do not claim Phase 10 complete unless implementation and verification actually pass.

Report:

1. Files created/modified
2. Interactive UI features
3. Primary Gemini model
4. Fallback Gemini model
5. Retry behavior
6. Timeout behavior
7. Error mappings
8. API-call optimization findings
9. Logging/security result
10. AFC decision
11. Backend test results
12. Flutter test results
13. flutter analyze results
14. Manual verification
15. Phase 1â€“9 regression status
16. REAL / MOCK / PLANNED status
17. Known limitations

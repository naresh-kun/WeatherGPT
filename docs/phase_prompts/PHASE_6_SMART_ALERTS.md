Phase 6 — Smart Alerts & Advisories
Goal

Build a real, deterministic alert engine that uses the existing live WeatherAPI data to identify important weather conditions and generate alerts/advisories.

Architecture
Flutter
   ↓
FastAPI
   ↓
WeatherService
   ↓
WeatherAPI.com
   ↓
Alert Engine
   ↓
Rules / Thresholds
   ↓
Alert + Advisory
   ↓
Flutter Alerts screen
Core principle

The alert decision must NOT depend on Gemini.

Gemini can eventually help explain an alert conversationally, but whether an alert exists should be determined by deterministic rules.

For example:

Temperature ≥ threshold
        → Extreme Heat Alert

Rain probability ≥ threshold
        → Heavy Rain / Rain Advisory

Wind speed ≥ threshold
        → Strong Wind Alert

UV index ≥ threshold
        → High UV Advisory

We'll keep those thresholds configurable rather than hardcoding them throughout the application.

What Phase 6 should contain
Backend

Add an alert/advisory engine that:

consumes the existing WeatherService data
evaluates current and forecast weather
generates structured alerts
assigns severity such as:
info
warning
danger
includes:
alert type
title
description
severity
location
relevant value
threshold
timestamp
handles multiple simultaneous alerts
avoids duplicate alerts where practical
returns clean JSON through the existing API architecture

Potential endpoint:

GET /api/v1/alerts

which already exists from Phase 3, so reuse and upgrade it rather than creating unnecessary duplicate endpoints.

Initial alert rules

Keep the first version practical:

Extreme Heat

temperature >= configurable threshold

Heavy Rain

precipitation / rain probability >= configurable threshold

Strong Wind

wind speed >= configurable threshold

High UV

UV index >= configurable threshold

Thunderstorm

weather condition indicates thunderstorm

The exact numeric thresholds should be chosen from the available WeatherAPI fields and documented clearly rather than invented randomly.

Flutter

Make the existing Alerts screen real:

Loading
   ↓
Fetch /api/v1/alerts
   ↓
Display real alerts

Include:

severity indicator
alert icon
title
short explanation
relevant weather value
location/time
empty state when no alerts exist
loading state
retry/error state

The screen should no longer depend on mock alert data once Phase 6 is complete.

Advisory

The existing Advisory screen can use the same underlying alert/weather engine to display practical recommendations such as:

High temperature detected. Stay hydrated and avoid prolonged exposure during peak afternoon hours.

Keep this rule-based for now.

Do not turn the advisory system into an LLM project during Phase 6.

Notifications

Don't implement a full push-notification infrastructure yet.

For Phase 6, an alert being generated and displayed inside the app is enough.

Later we can decide whether actual device notifications are worthwhile.

Things explicitly OUT OF SCOPE

Antigravity must not implement:

❌ Tamil localization
❌ Voice / STT / TTS
❌ Climate intelligence
❌ RAG / vector database
❌ User authentication
❌ Push notification infrastructure
❌ Long-term conversation memory
❌ New LLM architecture

Gemini 3.7 Flash remains the Phase 5 chat system.

Testing requirements

This one is important.

For the alert engine, we want actual rule tests such as:

Normal temperature
→ no heat alert

High temperature
→ heat warning

Extreme temperature
→ heat danger

Low rain probability
→ no rain alert

High rain probability
→ rain alert

High wind
→ wind alert

High UV
→ UV alert

Also test:

multiple alerts at once
no alerts
invalid/missing weather fields
API failure

And preserve all existing tests.

Documentation

At the end, Antigravity must update the relevant .md files:

docs/api/API_CONTRACT.md
docs/architecture/ARCHITECTURE.md
README.md
backend/weathergpt_api/README.md

and clearly label:

REAL
MOCK
PLANNED

### Important Implementation Rules

1. Use the existing WeatherAPI response models and actual field locations.
   Do not assume field names or nesting without inspecting the existing WeatherService/models.

2. Normalize percentage values consistently.
   Rain thresholds should use 0–100 percentage values internally.

3. Prefer WeatherAPI structured condition codes/categories for
   thunderstorm detection; fall back to condition text matching only if necessary.

4. Alert decisions must be deterministic and must not call Gemini.

5. Advisory text must come from deterministic rule-based templates.
   Gemini must not be used for advisory generation in Phase 6.

6. When combining Smart Alert Engine results with WeatherAPI-native alerts,
   preserve distinct alerts and avoid only genuine duplicates.

7. Use explicit severity mapping:
   minor → informational
   moderate → warning threshold
   severe → danger threshold
   extreme → reserved for exceptionally dangerous conditions.

8. Preserve backward compatibility with existing API response structures
   wherever practical. Do not rename/remove existing enum values unless
   every backend and Flutter usage is updated and tested.
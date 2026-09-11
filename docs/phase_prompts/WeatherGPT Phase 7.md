Phase 7 — Climate Intelligence
Goal

Extend WeatherGPT from real-time weather, AI chat, alerts, and advisories into historical climate analysis and understandable climate insights.

Phase 7 must use real/curated historical weather data and deterministic calculations to identify trends, comparisons, and anomalies.

The output should be presented through the existing Flutter Climate screen with clear charts and simple explanations.

Architecture
Flutter Climate Screen
        ↓
FastAPI Climate API
        ↓
Climate Service
        ↓
Historical Climate Dataset
        ↓
Deterministic Analysis
        ↓
Trends / Averages / Anomalies
        ↓
Climate Response
        ↓
Flutter Charts + Insights
Core principle

Climate calculations must be deterministic and data-driven.

Do NOT use Gemini to calculate or invent climate trends.

Gemini may remain available through the existing Phase 5 chat system, but Phase 7 climate analysis must work independently of Gemini.

Historical Data

For the prototype, use a local curated historical dataset rather than introducing another external API dependency.

Create a dedicated dataset such as:

backend/weathergpt_api/data/climate/

The dataset should contain representative historical weather information for relevant locations.

Initial locations can include:

Madurai
Chennai
Coimbatore
Tirunelveli

Use a clearly documented reference period and consistent units.

Each record should contain enough information for:

location
year
month
average_temperature_c
maximum_temperature_c
minimum_temperature_c
rainfall_mm

Do not fabricate individual real-world claims and present them as official observations. Clearly identify the dataset as prototype/reference historical data in the documentation.

Backend
New files

Create something similar to:

app/services/climate/service.py
app/schemas/climate.py
data/climate/historical_weather.csv
tests/test_climate.py

Use the existing project architecture and naming conventions where appropriate.

Climate Data Model

Create structured models for:

Historical Climate Record
location
year
month
average_temperature_c
maximum_temperature_c
minimum_temperature_c
rainfall_mm
Climate Trend

Include:

location
metric
period
values
Climate Comparison

Include:

metric
current_value
historical_average
difference
difference_percent
interpretation
Climate Response

The API should return structured data suitable for Flutter charts and summary cards.

Climate Analysis

Implement deterministic calculations for at least:

1. Temperature Trend

Calculate monthly or yearly average temperature trends.

Example:

Historical average → 31.2°C
Recent/reference average → 32.1°C
Difference → +0.9°C
2. Rainfall Trend

Calculate:

monthly rainfall
seasonal rainfall
historical rainfall average
rainfall difference
3. Temperature Anomaly

Calculate:

anomaly = observed/reference value - historical baseline

Example:

+1.2°C above historical baseline
4. Rainfall Anomaly

Calculate:

rainfall anomaly = observed/reference rainfall - historical average rainfall

Clearly indicate whether rainfall is:

above average
near average
below average
5. Seasonal Analysis

Support broad seasons relevant to the prototype:

Winter
Summer
Southwest Monsoon
Northeast Monsoon

Keep the mapping documented and easy to modify.

Climate Insights

Generate rule-based textual insights from calculated values.

Examples:

"Temperature is above the historical average."

"Rainfall is below the historical average."

"Recent temperatures are relatively stable compared with the baseline."

"Rainfall during the selected period is higher than the historical average."

Do NOT ask Gemini to generate these statements.

The insight must be reproducible from the underlying values.

API

Add a climate endpoint under the existing API versioning.

For example:

GET /api/v1/climate

Support at least:

location
metric
period/year range

Use sensible defaults so Flutter can request a useful overview without requiring many parameters.

Example:

GET /api/v1/climate?location=Madurai

The response should provide enough data for:

temperature chart
rainfall chart
historical comparison
climate insight

Add additional endpoints only when genuinely necessary.

Do NOT create unnecessary APIs.

Flutter
Climate Screen

Replace the existing mock climate data with real backend data.

The screen should include:

Location
Madurai
Temperature Trend

A fl_chart line chart showing historical/reference temperature trends.

Rainfall Trend

A bar chart showing rainfall over the selected period.

Historical Comparison

Example:

Temperature
32.1°C
+0.9°C vs historical average

and:

Rainfall
82 mm
-14% vs historical average
Climate Insight

Display a simple rule-based insight.

Example:

Temperature is slightly above the historical baseline for this period.

Flutter Architecture

Reuse the existing architecture:

Climate Screen
      ↓
Climate Provider
      ↓
ApiService
      ↓
FastAPI

Add a dedicated provider only if the existing WeatherProvider is not appropriate.

Do not introduce a heavyweight state-management framework.

UI Requirements

The Climate screen must support:

Loading state
Empty state
Error state
Retry
Successful data display

Charts must remain readable on both:

mobile
web

Do not overcomplicate the screen.

Filtering

Provide simple user controls for:

Location
Year / period
Metric

Do not build an elaborate analytics dashboard.

Testing

Create comprehensive backend tests covering:

valid climate data
temperature calculations
rainfall calculations
temperature anomaly
rainfall anomaly
seasonal analysis
multiple locations
empty dataset
invalid location
missing values
API response structure

Flutter tests should cover:

climate model parsing
API service
provider loading
provider success
provider error
empty state
Climate screen rendering

Run the complete existing test suites as well.

Verification

Run:

cd backend/weathergpt_api
.venv\Scripts\python.exe -m pytest
cd frontend/weathergpt_app
flutter test
flutter analyze

Manual verification:

Start FastAPI.
Request:
GET /api/v1/climate?location=Madurai
Confirm valid structured climate data.
Open Flutter Climate screen.
Confirm charts display.
Change location/filter if implemented.
Verify loading/error/empty states.
Phase 1–6 Preservation

This is extremely important.

Do NOT break:

Phase 1 — Foundation
Phase 2 — Flutter UI
Phase 3 — WeatherAPI
Phase 4 — Flutter ↔ FastAPI
Phase 5 — WeatherGPT AI Chat
Phase 6 — Smart Alerts & Advisories

Especially preserve:

WeatherGPT chat
WeatherAPI integration
AlertEngine
Alerts screen
Advisory screen
existing API architecture

Do not rewrite those systems unnecessarily.

OUT OF SCOPE

Do NOT implement:

❌ Tamil / multilingual support
❌ Voice / STT / TTS
❌ Push notifications
❌ Authentication
❌ RAG / vector database
❌ New LLM architecture
❌ Predictive climate forecasting
❌ Machine-learning climate prediction
❌ Satellite/weather imagery analysis

Phase 7 is historical climate analysis, not climate prediction.

Documentation

Update:

README.md
backend/weathergpt_api/README.md
docs/api/API_CONTRACT.md
docs/architecture/ARCHITECTURE.md

Clearly mark functionality as:

REAL
MOCK
PLANNED

The historical dataset must be explicitly described as a prototype/reference dataset rather than being represented as a live government or meteorological feed.

Final Report

Do not claim Phase 7 is complete unless everything is implemented and verified.

Report:

1. Files created/modified
2. Historical dataset structure
3. Climate calculations implemented
4. API endpoints
5. Flutter screens/widgets
6. Backend test results
7. Flutter test results
8. flutter analyze results
9. Manual verification result
10. Phase 1–6 regression status
11. REAL / MOCK / PLANNED status
# WeatherGPT â€” Phase 12: Android APK & Production Mobile Release

## Goal

Prepare the existing Flutter application for Android production use, connect release builds to the deployed Railway FastAPI backend, build a release APK, and verify the complete mobile application end-to-end.

Phase 1â€“11 functionality must remain preserved.

---

## 1. Production Architecture

Final mobile architecture:

Android APK
    â†“ HTTPS
Railway FastAPI
    â”œâ”€â”€ WeatherAPI
    â”œâ”€â”€ Gemini 3.7 Flash
    â”œâ”€â”€ Gemini 3.6 Flash fallback
    â””â”€â”€ Climate dataset

The Android application must NOT contain:
- WEATHER_API_KEY
- GEMINI_API_KEY
- Railway secrets
- Provider credentials

---

## 2. Production Backend URL

Use the currently verified Railway backend:

https://weathergpt-production-84b3.up.railway.app/api/v1

Do not hardcode this URL throughout the Flutter project.

Use the existing centralized configuration mechanism.

Development should continue to support:

http://127.0.0.1:8000/api/v1

Production/release should use the Railway HTTPS URL.

Prefer:

--dart-define=API_BASE_URL=...

for release builds where appropriate.

---

## 3. App Configuration

Inspect the current:

lib/core/config/app_config.dart

Ensure:

- development configuration remains usable
- production configuration uses Railway HTTPS
- no secrets are present
- configuration is centralized
- release builds do not accidentally point to localhost

Do not modify unrelated configuration.

---

## 4. Android Configuration

Inspect the current Android project.

Verify:

- application ID / package name is valid
- application label is WeatherGPT
- Internet permission is present
- RECORD_AUDIO permission remains for Phase 9 voice
- location permissions remain correct for GPS
- Android configuration is compatible with the existing Flutter/Dart version

Do not add unnecessary permissions.

---

## 5. HTTPS / Networking

The production backend uses HTTPS.

Therefore:

- Android release traffic must use HTTPS.
- Do not configure production networking to depend on local HTTP.
- Preserve local development support where necessary.

Do not disable Android network security safeguards globally.

---

## 6. App Icon / Branding

Inspect the existing app branding.

Ensure:

- WeatherGPT app name is correct
- launcher icon is present and reasonable
- no development/debug branding remains in the release configuration

Do not spend excessive effort redesigning the entire visual identity.

---

## 7. Release Configuration

Inspect Gradle configuration and determine the safest release configuration for the project.

Do not make assumptions about:
- signing
- minSdk
- targetSdk
- Java/Kotlin versions

Inspect the current project first and only change what is required for a successful release build.

Prepare release signing configuration appropriately.

IMPORTANT:
Never commit a private signing keystore or signing passwords/secrets.

For a demo APK, a secure local signing setup is acceptable.

---

## 8. APK Build

Build a production APK using the Railway backend:

flutter build apk --release --dart-define=API_BASE_URL=https://weathergpt-production-84b3.up.railway.app/api/v1

Verify that the APK is generated successfully.

Record the APK output path and size.

Do not use a debug APK as the final release artifact.

---

## 9. Android Installation Test

Install the generated APK on an Android device or emulator.

Verify:

### App startup
- launches successfully
- no crash
- branding correct

### Home
- live weather loads
- location works
- forecast works

### Chat
- real WeatherGPT response
- Gemini primary/fallback works
- weather cards work
- quick actions work
- Tamil works
- voice works

### Alerts
- live Smart Alerts

### Advisory
- live advisories

### Climate
- historical climate dataset response from Railway

### Settings
- language switching works
- preferences persist

---

## 10. Location Verification

Verify Android location behavior:

- permission requested only when needed
- GPS location is obtained correctly
- selected location and displayed location remain consistent
- changing location updates dependent features
- language switching does not alter location

Do not request location permission unnecessarily.

---

## 11. Voice Verification

Verify Phase 9 on Android:

English:
- STT
- chat
- TTS

Tamil:
- STT where supported
- Tamil response
- TTS where supported

If Tamil voice is unavailable:
- show graceful fallback
- text chat remains fully functional

Do not treat device-specific voice availability as an application crash.

---

## 12. Backend Verification From APK

The APK must communicate with the deployed Railway backend rather than localhost.

Confirm network requests originate from the release app to:

https://weathergpt-production-84b3.up.railway.app

Verify:

- health/backend connectivity
- weather
- forecast
- alerts
- advisory
- climate
- chat

---

## 13. Regression Testing

Run:

Backend:
cd backend/weathergpt_api
.venv\Scripts\python.exe -m pytest

Frontend:
cd frontend/weathergpt_app
flutter test

Analyzer:
flutter analyze

Preserve all Phase 1â€“11 tests and behavior.

---

## 14. Release Artifact

Produce:

- release APK
- optional APK checksum
- build/version information

Do not upload the APK to a public repository unless explicitly required.

---

## 15. Security

Verify:

- no API keys in Flutter source
- no API keys in APK assets/source
- no Railway secrets in Flutter
- no local .env bundled into APK
- HTTPS backend used in production
- signing credentials not committed

---

## 16. Documentation

Update:

- README.md
- frontend/weathergpt_app/README.md if present
- docs/architecture/ARCHITECTURE.md
- docs/api/API_CONTRACT.md where production URL information belongs

Document:

- development vs production API URL
- Railway backend
- release APK build command
- Android permissions
- APK installation/testing procedure

Clearly mark REAL / MOCK / PLANNED.

---

## 17. OUT OF SCOPE

Do NOT implement:

- Play Store publishing
- iOS release
- Firebase analytics
- push notification infrastructure
- major UI redesign
- new AI models
- new weather providers
- authentication
- new product features

---

## 18. Final Report

Do not claim Phase 12 complete unless the release APK builds successfully and has been tested.

Report:

1. Files modified
2. Package/application ID
3. Production API URL configuration
4. Android permissions
5. Signing configuration
6. APK build command
7. APK output path
8. APK size
9. Installation result
10. Home/weather result
11. Chat result
12. Gemini fallback result
13. Tamil result
14. Voice result
15. Alerts/advisory result
16. Climate result
17. Backend tests
18. Flutter tests
19. flutter analyze
20. Security verification
21. Phase 1â€“11 regression status
22. REAL / MOCK / PLANNED status
23. Known device-specific limitations

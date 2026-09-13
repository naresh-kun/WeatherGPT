Phase 9 = Voice Interaction. We should keep this phase focused on speech-to-text + text-to-speech, while preserving everything already working.

Create:

docs/phase_prompts/PHASE_9_VOICE.md

Paste this specification into it:

# WeatherGPT — Phase 9: Voice Interaction

## Goal

Add voice interaction to WeatherGPT so users can speak their weather questions and hear WeatherGPT responses aloud.

Phase 9 must integrate with the existing Phase 5 chat pipeline and Phase 8 multilingual support.

The core flow is:

User speaks
    ↓
Speech-to-Text
    ↓
Existing WeatherGPT Chat API
    ↓
Gemini 3.7 Flash
    ↓
Text response
    ↓
Text-to-Speech
    ↓
User hears response

Voice must work with both supported languages:
- English (`en`)
- Tamil (`ta`)

---

# 1. Scope

Implement:

- Voice input using Speech-to-Text (STT)
- Voice output using Text-to-Speech (TTS)
- Microphone controls in Chat screen
- Listening state
- Processing state
- Speaking state
- Stop/cancel controls
- Tamil voice support where supported by the device/platform
- Integration with existing ChatProvider
- Accessibility-friendly error handling
- Android support as the primary target
- Web compatibility only where naturally supported by chosen packages

Do NOT rewrite the existing chat architecture.

---

# 2. Package Selection

Inspect the current Flutter project and use well-maintained Flutter packages compatible with the existing Dart/Flutter version.

Prefer lightweight packages.

Possible packages to evaluate:

- `speech_to_text`
- `flutter_tts`

Do not add multiple overlapping voice packages.

Before implementation:
- Check compatibility with the current Flutter/Dart setup.
- Prefer the simplest stable solution.
- Document the exact package versions selected.

---

# 3. Voice Input — Speech-to-Text

Use the device microphone to convert spoken input to text.

Expected flow:

```text
Tap microphone
      ↓
Request microphone permission if needed
      ↓
Listening
      ↓
User speaks
      ↓
Recognized text appears in chat input
      ↓
User can edit
      ↓
Press Send

Important:

Do NOT automatically send the message immediately after speech recognition unless the existing UX explicitly supports that.

Default behavior:

Speech populates the chat input.
User can review/edit.
User presses Send.
4. Listening UI

When microphone mode is active, clearly show:

Listening indicator
Microphone animation/icon
Recognized partial text where supported
Stop button
Cancel option

Example:

🎙 Listening...
"Will it rain today?"
[Stop]

Do not make the UI cluttered.

5. Voice Output — Text-to-Speech

After a successful WeatherGPT response:

AI response received
      ↓
TTS
      ↓
Speak response aloud

Add controls:

Play/speak response
Stop speaking
Optional replay

The assistant response must still appear as normal text.

Voice output should never replace visual text.

6. Language Integration

Use the existing Phase 8 language state.

When language is:

en

STT should request English speech recognition where supported.

TTS should use an English voice where available.

When language is:

ta

STT should request Tamil (ta-IN) where supported.

TTS should request Tamil (ta-IN) where supported.

Do not hardcode a single voice independently of the selected app language.

7. Platform Limitations

Voice support depends on device/platform capabilities.

Implement graceful fallback when:

microphone permission is denied
speech recognition unavailable
Tamil STT unavailable
Tamil TTS unavailable
device has no suitable voice
STT initialization fails
TTS initialization fails

The app must continue working as a normal text chat application.

Voice failure must never break WeatherGPT chat.

8. Android Permissions

Configure Android permissions required for microphone usage.

At minimum inspect whether the project requires:

RECORD_AUDIO

Do not add unnecessary permissions.

Ensure runtime permission handling is graceful.

Do not request microphone permission on app startup.

Request microphone permission only when the user activates voice input.

9. Chat Screen Integration

Integrate voice into the existing ChatScreen rather than creating a separate voice screen.

Recommended input bar:

[ + ]  Ask WeatherGPT...     🎙️

During listening:

[ + ]  Listening...           ⏹

For assistant messages:

WeatherGPT response

[🔊 Speak]

or an equivalent clean icon-based control.

Do not redesign the entire chat UI in Phase 9.

Phase 10 will handle broader interactive chat UI improvements.

10. ChatProvider Integration

Extend the existing ChatProvider only where appropriate.

It may expose state such as:

isListening
isSpeaking
recognizedText
voiceError

Keep network/chat state separate from voice state where practical.

Do not move existing API communication into the voice service.

11. Voice Services

Create dedicated lightweight services where useful, for example:

lib/services/voice/speech_service.dart
lib/services/voice/tts_service.dart

Responsibilities:

SpeechService
initialize STT
request permission when needed
start listening
stop listening
cancel listening
return recognized text
expose availability/errors
TTSService
initialize TTS
select language
speak
stop
replay
expose availability/errors

Keep platform-specific handling isolated.

12. Error Messages

Provide clear user-facing errors.

Examples:

Microphone denied:

Microphone permission is required for voice input.

Speech unavailable:

Voice input is not available on this device.

Tamil speech unavailable:

Tamil voice input is not supported on this device.
You can continue using text chat.

TTS unavailable:

Voice playback is unavailable.

Do not expose stack traces or provider internals.

13. Tamil Handling

Tamil support must use the existing Phase 8 language selection.

Use:

ta-IN

for speech/TTS where the underlying platform supports it.

Do not assume all Android devices have Tamil voices installed.

If Tamil voice support is unavailable:

keep Tamil text chat fully functional
show a clear message
allow the user to continue using text

Do not silently switch the user to English voice.

14. Voice + Existing Weather Grounding

Voice must use the exact same WeatherGPT chat pipeline.

Example:

User speaks:
"மதுரையில் இன்று மழை பெய்யுமா?"

        ↓

STT → Tamil text

        ↓

ChatProvider

        ↓

POST /api/v1/chat
language = "ta"

        ↓

WeatherService
        ↓
WeatherAPI
        ↓
real weather context

        ↓

Gemini 3.7 Flash

        ↓

Tamil response

        ↓

ChatScreen

        ↓

Tamil TTS

Do NOT create a separate voice-specific AI backend.

15. Interruptions and Control

Handle:

user stops listening
user cancels listening
TTS stopped manually
user starts a new message while TTS is speaking
navigation away from ChatScreen
app lifecycle interruptions where practical

TTS should stop when leaving the chat screen where appropriate.

Avoid overlapping multiple TTS playback requests.

16. Testing

Add Flutter tests for:

SpeechService initialization
unavailable STT
microphone permission failure
listening state
stop/cancel behavior
recognized text updates
TTS initialization
speaking state
stop speaking
unavailable TTS
language-specific STT locale selection
language-specific TTS locale selection
ChatProvider integration
voice error handling

Do not write tests that require an actual physical microphone unless the project's test environment supports it.

Use mocks/fakes for platform voice APIs where necessary.

Run all existing tests too.

17. Android Verification

If an Android emulator/device is available:

Verify:

App launches.
Chat opens normally.
Tap microphone.
Android microphone permission appears only when needed.
Speak an English weather question.
Recognized text appears.
Send message.
WeatherGPT returns response.
Tap speak.
Response is spoken aloud.
Switch app language to Tamil.
Repeat with a Tamil weather question.
Verify Tamil STT/TTS where supported.
Verify graceful fallback where Tamil voice is unavailable.

Voice failure must not prevent normal text chat.

18. Regression Testing

Preserve:

Phase 1 — Foundation
Phase 2 — Flutter UI
Phase 3 — WeatherAPI
Phase 4 — Flutter ↔ FastAPI
Phase 5 — Gemini 3.7 Flash Chat
Phase 6 — Smart Alerts & Advisories
Phase 7 — Climate Intelligence
Phase 8 — Tamil / Multilingual

Specifically verify:

WeatherAPI still works
Chat still works without voice
Tamil text chat still works
Alerts/advisories remain functional
Climate screen remains functional
19. OUT OF SCOPE

Do NOT implement:

Interactive chat redesign
Advanced weather cards
Forecast timeline UI
Gemini fallback model
Offline AI
Push notifications
Authentication
RAG/vector database
Backend deployment
APK release process

Those belong to later phases.

20. Documentation

Update:

README.md
backend/weathergpt_api/README.md
docs/api/API_CONTRACT.md
docs/architecture/ARCHITECTURE.md

Document:

selected STT package
selected TTS package
package versions
Android permissions
English/Tamil voice support
known platform limitations

Clearly mark:

REAL
MOCK
PLANNED

21. Final Report

Do not claim Phase 9 complete unless the implementation and verification actually pass.

Report:

Files created/modified
STT package and version
TTS package and version
Android permissions added
Voice state architecture
English voice behavior
Tamil voice behavior
Error/fallback handling
Backend test results
Flutter test results
flutter analyze results
Android manual verification
Phase 1–8 regression status
REAL / MOCK / PLANNED status
Known device/platform limitations

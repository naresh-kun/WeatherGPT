/// WeatherGPT — Voice Service (Phase 9)
/// Unified exports and helper facade for Speech-to-Text and Text-to-Speech.
library;

import 'speech_service.dart';
import 'tts_service.dart';

export 'speech_service.dart';
export 'tts_service.dart';

/// Facade combining speech recognition and text-to-speech.
///
/// [REAL — Phase 9]
class VoiceService {
  final SpeechService speechService;
  final TtsService ttsService;

  VoiceService({
    SpeechService? speechService,
    TtsService? ttsService,
  })  : speechService = speechService ?? SpeechService(),
        ttsService = ttsService ?? TtsService();

  Future<void> textToSpeech(String text, {String languageCode = 'en'}) async {
    await ttsService.speak(text, languageCode: languageCode);
  }

  Future<void> stopSpeaking() async {
    await ttsService.stop();
  }
}

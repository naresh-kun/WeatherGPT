/// WeatherGPT — Text-to-Speech Service Tests (Phase 9)
/// Tests for TtsService:
/// - initialization (available / unavailable)
/// - markdown stripping / sanitization
/// - locale resolution (en-US, ta-IN)
/// - language availability checks
/// - speak, stop, and callback lifecycle
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:weathergpt_app/services/voice/tts_service.dart';

class FakeFlutterTts extends Fake implements FlutterTts {
  bool initThrows = false;
  dynamic languagesList = ['en-US', 'en-IN', 'ta-IN'];
  @override
  VoidCallback? startHandler;
  @override
  VoidCallback? completionHandler;
  @override
  VoidCallback? cancelHandler;
  @override
  ErrorHandler? errorHandler;

  String? lastSpokenText;
  String? lastSetLanguage;
  bool isSpeakingState = false;
  bool stopCalled = false;
  dynamic speakReturnValue = 1;

  @override
  void setStartHandler(VoidCallback callback) {
    startHandler = callback;
  }

  @override
  void setCompletionHandler(VoidCallback callback) {
    completionHandler = callback;
  }

  @override
  void setCancelHandler(VoidCallback callback) {
    cancelHandler = callback;
  }

  @override
  void setErrorHandler(ErrorHandler handler) {
    errorHandler = handler;
  }

  @override
  Future<dynamic> get getLanguages async => languagesList;

  @override
  Future<dynamic> setSpeechRate(double rate) async => 1;

  @override
  Future<dynamic> setVolume(double volume) async => 1;

  @override
  Future<dynamic> setPitch(double pitch) async => 1;

  @override
  Future<dynamic> setLanguage(String language) async {
    lastSetLanguage = language;
    return 1;
  }

  @override
  Future<dynamic> isLanguageAvailable(String language) async {
    if (languagesList is List) {
      final exists = (languagesList as List)
          .any((l) => l.toString().toLowerCase() == language.toLowerCase());
      return exists ? 1 : 0;
    }
    return 0;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    lastSpokenText = text;
    isSpeakingState = true;
    startHandler?.call();
    return speakReturnValue;
  }

  @override
  Future<dynamic> stop() async {
    stopCalled = true;
    isSpeakingState = false;
    cancelHandler?.call();
    return 1;
  }
}

void main() {
  group('TtsService.initialize', () {
    test('initializes successfully with supported languages', () async {
      final fake = FakeFlutterTts();
      final service = TtsService(tts: fake);

      expect(service.isInitialized, isFalse);
      final ok = await service.initialize();

      expect(ok, isTrue);
      expect(service.isInitialized, isTrue);
      expect(service.isAvailable, isTrue);
    });

    test('handles exceptions gracefully', () async {
      final fake = FakeFlutterTts()..languagesList = Exception('TTS Engine crashed');
      final service = TtsService(tts: fake);

      final ok = await service.initialize();
      // Service handles language query failure gracefully
      expect(ok, isTrue);
      expect(service.isAvailable, isTrue);
    });
  });

  group('TtsService text sanitization', () {
    test('cleans markdown symbols from speech text', () {
      final service = TtsService(tts: FakeFlutterTts());

      const raw = 'The **temperature** is *31°C* with # clear skies and `20%` humidity. [More](http://example.com)';
      final clean = service.sanitizeForSpeech(raw);

      expect(clean, isNot(contains('**')));
      expect(clean, isNot(contains('*31°C*')));
      expect(clean, isNot(contains('#')));
      expect(clean, isNot(contains('`')));
      expect(clean, isNot(contains('http://example.com')));
      expect(clean, equals('The temperature is 31°C with clear skies and 20% humidity. More'));
    });
  });

  group('TtsService language resolution', () {
    test('resolves English and Tamil TTS language tags', () async {
      final fake = FakeFlutterTts();
      final service = TtsService(tts: fake);
      await service.initialize();

      expect(service.resolveTtsLanguage('en'), equals('en-US'));
      expect(service.resolveTtsLanguage('ta'), equals('ta-IN'));
      expect(await service.isLanguageAvailable('en'), isTrue);
      expect(await service.isLanguageAvailable('ta'), isTrue);
    });

    test('detects when Tamil voice is not available in engine', () async {
      final fake = FakeFlutterTts()..languagesList = ['en-US'];
      final service = TtsService(tts: fake);
      await service.initialize();

      expect(await service.isLanguageAvailable('ta'), isFalse);
    });
  });

  group('TtsService.speak and stop', () {
    test('speaks text and selects corresponding language', () async {
      final fake = FakeFlutterTts();
      final service = TtsService(tts: fake);

      bool startCalled = false;
      final ok = await service.speak(
        'It is sunny today.',
        languageCode: 'en',
        onStart: () => startCalled = true,
      );

      expect(ok, isTrue);
      expect(fake.lastSetLanguage, equals('en-US'));
      expect(fake.lastSpokenText, equals('It is sunny today.'));
      expect(service.isSpeaking, isTrue);
      expect(startCalled, isTrue);
    });

    test('speaks Tamil text with ta-IN language', () async {
      final fake = FakeFlutterTts();
      final service = TtsService(tts: fake);

      final ok = await service.speak(
        'இன்று வெயில் அதிகமாக இருக்கும்.',
        languageCode: 'ta',
      );

      expect(ok, isTrue);
      expect(fake.lastSetLanguage, equals('ta-IN'));
      expect(fake.lastSpokenText, equals('இன்று வெயில் அதிகமாக இருக்கும்.'));
    });

    test('stops active playback cleanly', () async {
      final fake = FakeFlutterTts();
      final service = TtsService(tts: fake);
      await service.speak('Some long text to read');

      expect(service.isSpeaking, isTrue);
      await service.stop();

      expect(fake.stopCalled, isTrue);
      expect(service.isSpeaking, isFalse);
    });
  });
}

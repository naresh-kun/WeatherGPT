/// WeatherGPT — Speech Service Tests (Phase 9)
/// Tests for SpeechService:
/// - initialization (available / unavailable)
/// - locale resolution (en-US, ta-IN)
/// - Tamil unsupported handling
/// - listening state lifecycle (start, onResult, stop, cancel)
/// - error handling
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:weathergpt_app/services/voice/speech_service.dart';

class FakeSpeechToText extends Fake implements stt.SpeechToText {
  bool initResult = true;
  bool throwsOnInit = false;
  bool isListeningState = false;
  List<stt.LocaleName> mockLocales = [
    stt.LocaleName('en_US', 'English (United States)'),
    stt.LocaleName('ta_IN', 'Tamil (India)'),
  ];
  stt.SpeechResultListener? capturedOnResult;
  stt.SpeechListenOptions? capturedOptions;
  bool stopCalled = false;
  bool cancelCalled = false;

  @override
  bool get isListening => isListeningState;

  @override
  Future<bool> initialize({
    stt.SpeechErrorListener? onError,
    stt.SpeechStatusListener? onStatus,
    dynamic debugLogging = false,
    List<stt.SpeechConfigOption>? options,
    Duration? finalTimeout,
  }) async {
    if (throwsOnInit) {
      throw Exception('Hardware mic initialization failed');
    }
    return initResult;
  }

  @override
  Future<List<stt.LocaleName>> locales() async {
    return mockLocales;
  }

  @override
  Future<void> listen({
    stt.SpeechResultListener? onResult,
    stt.SpeechListenOptions? listenOptions,
    String? localeId,
    dynamic onDevice,
    Duration? pauseFor,
    Duration? listenFor,
    dynamic cancelOnError,
    dynamic partialResults,
    dynamic onSoundLevelChange,
    dynamic listenMode,
    dynamic sampleRate,
  }) async {
    capturedOnResult = onResult;
    capturedOptions = listenOptions;
    isListeningState = true;
  }

  @override
  Future<void> stop() async {
    stopCalled = true;
    isListeningState = false;
  }

  @override
  Future<void> cancel() async {
    cancelCalled = true;
    isListeningState = false;
  }
}

void main() {
  group('SpeechService.initialize', () {
    test('initializes successfully when available', () async {
      final fake = FakeSpeechToText();
      final service = SpeechService(speech: fake);

      expect(service.isInitialized, isFalse);
      final ok = await service.initialize();

      expect(ok, isTrue);
      expect(service.isInitialized, isTrue);
      expect(service.isAvailable, isTrue);
      expect(service.availableLocales.length, 2);
    });

    test('handles initialization failure gracefully', () async {
      final fake = FakeSpeechToText()..initResult = false;
      final service = SpeechService(speech: fake);

      final ok = await service.initialize();

      expect(ok, isFalse);
      expect(service.isInitialized, isTrue);
      expect(service.isAvailable, isFalse);
    });

    test('handles exceptions during initialization gracefully', () async {
      final fake = FakeSpeechToText()..throwsOnInit = true;
      final service = SpeechService(speech: fake);

      final ok = await service.initialize();

      expect(ok, isFalse);
      expect(service.isAvailable, isFalse);
      expect(service.lastError, contains('Hardware mic initialization failed'));
    });
  });

  group('SpeechService locale resolution', () {
    test('resolves English and Tamil locales accurately', () async {
      final fake = FakeSpeechToText();
      final service = SpeechService(speech: fake);
      await service.initialize();

      expect(service.resolveLocaleId('en'), equals('en_US'));
      expect(service.resolveLocaleId('ta'), equals('ta_IN'));
      expect(service.isLanguageSupported('en'), isTrue);
      expect(service.isLanguageSupported('ta'), isTrue);
    });

    test('returns null for Tamil when device lacks Tamil STT locale', () async {
      final fake = FakeSpeechToText()
        ..mockLocales = [stt.LocaleName('en_US', 'English')];
      final service = SpeechService(speech: fake);
      await service.initialize();

      expect(service.resolveLocaleId('ta'), isNull);
      expect(service.isLanguageSupported('ta'), isFalse);
    });
  });

  group('SpeechService.startListening', () {
    test('starts listening and updates recognized words on speech events', () async {
      final fake = FakeSpeechToText();
      final service = SpeechService(speech: fake);

      String? recognized;
      bool? isFinalResult;

      final started = await service.startListening(
        languageCode: 'en',
        onResult: (words, isFinal) {
          recognized = words;
          isFinalResult = isFinal;
        },
      );

      expect(started, isTrue);
      expect(service.isListening, isTrue);
      expect(fake.capturedOptions?.localeId, equals('en_US'));

      // Simulate recognition event
      final mockSpeechResult = SpeechRecognitionResult(
        [
          const SpeechRecognitionWords(
            'What is the weather in Chennai',
            ['What is the weather in Chennai'],
            0.95,
          ),
        ],
        2,
      );
      fake.capturedOnResult?.call(mockSpeechResult);

      expect(recognized, equals('What is the weather in Chennai'));
      expect(isFinalResult, isTrue);
      expect(service.lastWords, equals('What is the weather in Chennai'));
    });

    test('fails gracefully when Tamil is requested but device lacks Tamil voice', () async {
      final fake = FakeSpeechToText()
        ..mockLocales = [stt.LocaleName('en_US', 'English')];
      final service = SpeechService(speech: fake);

      final started = await service.startListening(
        languageCode: 'ta',
        onResult: (_, __) {},
      );

      expect(started, isFalse);
      expect(service.lastError, contains('Tamil speech recognition is not supported'));
    });

    test('stopListening stops speech recognition', () async {
      final fake = FakeSpeechToText();
      final service = SpeechService(speech: fake);
      await service.startListening(onResult: (_, __) {});

      expect(service.isListening, isTrue);
      await service.stopListening();

      expect(fake.stopCalled, isTrue);
      expect(service.isListening, isFalse);
    });

    test('cancelListening cancels speech recognition and resets last words', () async {
      final fake = FakeSpeechToText();
      final service = SpeechService(speech: fake);
      await service.startListening(onResult: (_, __) {});

      await service.cancelListening();

      expect(fake.cancelCalled, isTrue);
      expect(service.lastWords, isEmpty);
      expect(service.isListening, isFalse);
    });
  });
}

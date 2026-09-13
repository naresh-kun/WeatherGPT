/// WeatherGPT — Voice Provider Tests (Phase 9)
/// Tests for VoiceProvider state management:
/// - Initial state
/// - startListening, stopListening, cancelListening
/// - speak, stopSpeaking, toggle off
/// - Interruption handling (speech interrupts TTS and vice versa)
/// - Tamil unsupported errors
/// - Error dismissal
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:weathergpt_app/providers/voice_provider.dart';
import 'package:weathergpt_app/services/voice/speech_service.dart';
import 'package:weathergpt_app/services/voice/tts_service.dart';
import '../services/speech_service_test.dart';
import '../services/tts_service_test.dart';

void main() {
  group('VoiceProvider state management', () {
    test('initializes with idle state and clean properties', () {
      final provider = VoiceProvider(
        speechService: SpeechService(speech: FakeSpeechToText()),
        ttsService: TtsService(tts: FakeFlutterTts()),
      );

      expect(provider.state, equals(VoiceState.idle));
      expect(provider.isIdle, isTrue);
      expect(provider.isListening, isFalse);
      expect(provider.isSpeaking, isFalse);
      expect(provider.recognizedText, isEmpty);
      expect(provider.voiceError, isNull);
      expect(provider.activeSpeakingId, isNull);
    });

    test('startListening transitions to listening and receives recognized words', () async {
      final fakeStt = FakeSpeechToText();
      final provider = VoiceProvider(
        speechService: SpeechService(speech: fakeStt),
        ttsService: TtsService(tts: FakeFlutterTts()),
      );

      final states = <VoiceState>[];
      provider.addListener(() => states.add(provider.state));

      String? wordsCallbackValue;
      final ok = await provider.startListening(
        languageCode: 'en',
        onWordsUpdated: (words) => wordsCallbackValue = words,
      );

      expect(ok, isTrue);
      expect(provider.isListening, isTrue);
      expect(states, contains(VoiceState.listening));

      // Simulate recognized words from microphone
      final result = SpeechRecognitionResult(
        [
          const SpeechRecognitionWords(
            'Will it rain tomorrow?',
            ['Will it rain tomorrow?'],
            0.9,
          ),
        ],
        1,
      );
      fakeStt.capturedOnResult?.call(result);

      expect(provider.recognizedText, equals('Will it rain tomorrow?'));
      expect(wordsCallbackValue, equals('Will it rain tomorrow?'));

      // Stop listening
      final text = await provider.stopListening();
      expect(text, equals('Will it rain tomorrow?'));
      expect(provider.isListening, isFalse);
      expect(provider.isIdle, isTrue);
    });

    test('cancelListening discards recognized text and returns to idle', () async {
      final fakeStt = FakeSpeechToText();
      final provider = VoiceProvider(
        speechService: SpeechService(speech: fakeStt),
        ttsService: TtsService(tts: FakeFlutterTts()),
      );

      await provider.startListening(languageCode: 'en');
      fakeStt.capturedOnResult?.call(
        SpeechRecognitionResult(
          [
            const SpeechRecognitionWords(
              'Discard me',
              ['Discard me'],
              0.9,
            ),
          ],
          1,
        ),
      );
      expect(provider.recognizedText, equals('Discard me'));

      await provider.cancelListening();
      expect(provider.recognizedText, isEmpty);
      expect(provider.isIdle, isTrue);
    });

    test('speak transitions to speaking state and assigns activeSpeakingId', () async {
      final fakeTts = FakeFlutterTts();
      final provider = VoiceProvider(
        speechService: SpeechService(speech: FakeSpeechToText()),
        ttsService: TtsService(tts: fakeTts),
      );

      await provider.speak(
        'Today will be warm with light breezes.',
        languageCode: 'en',
        messageId: 'msg_1',
      );

      expect(provider.isSpeaking, isTrue);
      expect(provider.activeSpeakingId, equals('msg_1'));
      expect(fakeTts.lastSpokenText, equals('Today will be warm with light breezes.'));

      // Tapping speak on the same active message should toggle it off (stop)
      await provider.speak(
        'Today will be warm with light breezes.',
        languageCode: 'en',
        messageId: 'msg_1',
      );

      expect(provider.isSpeaking, isFalse);
      expect(provider.activeSpeakingId, isNull);
      expect(fakeTts.stopCalled, isTrue);
    });

    test('starting listening stops any active TTS playback', () async {
      final fakeTts = FakeFlutterTts();
      final fakeStt = FakeSpeechToText();
      final provider = VoiceProvider(
        speechService: SpeechService(speech: fakeStt),
        ttsService: TtsService(tts: fakeTts),
      );

      await provider.speak('Assistant is currently speaking', messageId: 'msg_1');
      expect(provider.isSpeaking, isTrue);

      // User presses mic to speak
      await provider.startListening(languageCode: 'en');

      expect(fakeTts.stopCalled, isTrue);
      expect(provider.isListening, isTrue);
    });

    test('starting TTS cancels any active listening session', () async {
      final fakeTts = FakeFlutterTts();
      final fakeStt = FakeSpeechToText();
      final provider = VoiceProvider(
        speechService: SpeechService(speech: fakeStt),
        ttsService: TtsService(tts: fakeTts),
      );

      await provider.startListening(languageCode: 'en');
      expect(provider.isListening, isTrue);

      // Assistant begins speaking
      await provider.speak('New response', messageId: 'msg_2');

      expect(fakeStt.cancelCalled, isTrue);
      expect(provider.isSpeaking, isTrue);
    });

    test('handles Tamil STT unavailable with user-friendly error', () async {
      final fakeStt = FakeSpeechToText()..mockLocales = [stt.LocaleName('en_US', 'English')];
      final provider = VoiceProvider(
        speechService: SpeechService(speech: fakeStt),
        ttsService: TtsService(tts: FakeFlutterTts()),
      );

      final ok = await provider.startListening(languageCode: 'ta');

      expect(ok, isFalse);
      expect(provider.state, equals(VoiceState.error));
      expect(
        provider.voiceError,
        contains('Tamil voice input is not supported on this device'),
      );

      provider.dismissError();
      expect(provider.voiceError, isNull);
      expect(provider.isIdle, isTrue);
    });
  });
}

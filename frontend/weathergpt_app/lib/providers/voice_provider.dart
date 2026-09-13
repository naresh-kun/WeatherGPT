/// WeatherGPT — Voice Provider (Phase 9)
/// Reactive state management for voice interactions (STT & TTS).
/// Keeps voice lifecycle separate from ChatProvider.
library;

import 'package:flutter/foundation.dart';
import 'package:weathergpt_app/services/voice/speech_service.dart';
import 'package:weathergpt_app/services/voice/tts_service.dart';

enum VoiceState { idle, listening, speaking, error }

/// Manages voice input (STT) and voice output (TTS) states.
///
/// [REAL — Phase 9]
class VoiceProvider extends ChangeNotifier {
  final SpeechService _speechService;
  final TtsService _ttsService;

  VoiceProvider({
    SpeechService? speechService,
    TtsService? ttsService,
  })  : _speechService = speechService ?? SpeechService(),
        _ttsService = ttsService ?? TtsService();

  VoiceState _state = VoiceState.idle;
  VoiceState get state => _state;

  bool get isListening => _state == VoiceState.listening;
  bool get isSpeaking => _state == VoiceState.speaking;
  bool get isIdle => _state == VoiceState.idle;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  String? _voiceError;
  String? get voiceError => _voiceError;

  String? _activeSpeakingId;
  String? get activeSpeakingId => _activeSpeakingId;

  /// Start listening for speech input.
  ///
  /// - [languageCode]: 'en' or 'ta'
  /// - [onWordsUpdated]: callback when partial or final words arrive
  Future<bool> startListening({
    String languageCode = 'en',
    ValueChanged<String>? onWordsUpdated,
  }) async {
    // If TTS is active, stop it before listening
    if (_state == VoiceState.speaking) {
      await stopSpeaking();
    }

    _recognizedText = '';
    _voiceError = null;
    _state = VoiceState.listening;
    notifyListeners();

    final ok = await _speechService.startListening(
      languageCode: languageCode,
      onResult: (words, isFinal) {
        _recognizedText = words;
        onWordsUpdated?.call(words);
        notifyListeners();
      },
      onError: (errorMsg) {
        _voiceError = _formatVoiceError(errorMsg, languageCode);
        _state = VoiceState.error;
        notifyListeners();
      },
    );

    if (!ok) {
      _voiceError = _speechService.lastError != null
          ? _formatVoiceError(_speechService.lastError!, languageCode)
          : (languageCode == 'ta'
              ? 'Tamil voice input is not supported on this device. You can continue using text chat.'
              : 'Voice input is not available on this device.');
      _state = VoiceState.error;
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Stop listening and finalize current recognized text.
  Future<String> stopListening() async {
    if (_state == VoiceState.listening) {
      await _speechService.stopListening();
      _state = VoiceState.idle;
      notifyListeners();
    }
    return _recognizedText;
  }

  /// Cancel listening and discard recognized text.
  Future<void> cancelListening() async {
    if (_state == VoiceState.listening) {
      await _speechService.cancelListening();
      _recognizedText = '';
      _state = VoiceState.idle;
      notifyListeners();
    }
  }

  /// Speaks text aloud using TTS.
  ///
  /// - [text]: Plain or markdown text of assistant response
  /// - [languageCode]: 'en' or 'ta'
  /// - [messageId]: Optional identifier to mark the speaking message bubble
  Future<void> speak(
    String text, {
    String languageCode = 'en',
    String? messageId,
  }) async {
    // If currently speaking this exact message, toggle it off (stop)
    if (_state == VoiceState.speaking && _activeSpeakingId == messageId && messageId != null) {
      await stopSpeaking();
      return;
    }

    // Stop listening if active
    if (_state == VoiceState.listening) {
      await cancelListening();
    }

    // Stop existing speech
    if (_state == VoiceState.speaking) {
      await stopSpeaking();
    }

    _voiceError = null;
    _activeSpeakingId = messageId;
    _state = VoiceState.speaking;
    notifyListeners();

    final ok = await _ttsService.speak(
      text,
      languageCode: languageCode,
      onStart: () {
        _state = VoiceState.speaking;
        notifyListeners();
      },
      onComplete: () {
        _state = VoiceState.idle;
        _activeSpeakingId = null;
        notifyListeners();
      },
      onError: (errorMsg) {
        _voiceError = 'Voice playback is unavailable.';
        _state = VoiceState.error;
        _activeSpeakingId = null;
        notifyListeners();
      },
    );

    if (!ok) {
      _voiceError = languageCode == 'ta'
          ? 'Tamil voice playback is not supported on this device.'
          : 'Voice playback is unavailable.';
      _state = VoiceState.error;
      _activeSpeakingId = null;
      notifyListeners();
    }
  }

  /// Stop current TTS playback.
  Future<void> stopSpeaking() async {
    await _ttsService.stop();
    _activeSpeakingId = null;
    if (_state == VoiceState.speaking) {
      _state = VoiceState.idle;
    }
    notifyListeners();
  }

  /// Dismiss the active voice error.
  void dismissError() {
    _voiceError = null;
    if (_state == VoiceState.error) {
      _state = VoiceState.idle;
    }
    notifyListeners();
  }

  String _formatVoiceError(String rawError, String languageCode) {
    final lower = rawError.toLowerCase();
    if (lower.contains('permission') || lower.contains('denied')) {
      return 'Microphone permission is required for voice input.';
    }
    if (languageCode == 'ta' && (lower.contains('tamil') || lower.contains('locale') || lower.contains('not supported'))) {
      return 'Tamil voice input is not supported on this device. You can continue using text chat.';
    }
    if (lower.contains('not available') || lower.contains('unavailable')) {
      return 'Voice input is not available on this device.';
    }
    return rawError.isNotEmpty ? rawError : 'Voice input is not available on this device.';
  }

  @override
  void dispose() {
    _speechService.cancelListening();
    _ttsService.stop();
    super.dispose();
  }
}

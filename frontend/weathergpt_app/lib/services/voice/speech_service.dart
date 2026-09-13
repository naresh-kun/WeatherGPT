/// WeatherGPT — Speech Service (Phase 9)
/// Speech-to-Text wrapper using speech_to_text.
/// Supports English ('en') and Tamil ('ta-IN') voice recognition.
library;

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Speech-to-text service with locale resolution and lifecycle management.
///
/// [REAL — Phase 9]
class SpeechService {
  final stt.SpeechToText _speech;

  bool _isInitialized = false;
  bool _isAvailable = false;
  String? _lastError;
  String _lastWords = '';
  List<stt.LocaleName> _locales = [];

  SpeechService({stt.SpeechToText? speech})
      : _speech = speech ?? stt.SpeechToText();

  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  bool get isListening => _speech.isListening;
  String get lastWords => _lastWords;
  String? get lastError => _lastError;
  List<stt.LocaleName> get availableLocales => List.unmodifiable(_locales);

  /// Initializes the speech recognition engine.
  /// Safe to call multiple times.
  Future<bool> initialize({
    Function(String error)? onError,
    Function(String status)? onStatus,
  }) async {
    if (_isInitialized && _isAvailable) {
      return true;
    }

    try {
      _lastError = null;
      _isAvailable = await _speech.initialize(
        onError: (errorNotification) {
          _lastError = errorNotification.errorMsg;
          onError?.call(errorNotification.errorMsg);
        },
        onStatus: (status) {
          onStatus?.call(status);
        },
        debugLogging: kDebugMode,
      );

      _isInitialized = true;

      if (_isAvailable) {
        try {
          _locales = await _speech.locales();
        } catch (_) {
          _locales = [];
        }
      }

      return _isAvailable;
    } catch (e) {
      _isInitialized = true;
      _isAvailable = false;
      _lastError = e.toString();
      return false;
    }
  }

  /// Resolves the best locale ID for the given language code ('en' or 'ta').
  ///
  /// For Tamil ('ta'): searches for a locale matching 'ta_IN', 'ta-IN', or starting with 'ta'.
  /// For English ('en'): searches for 'en_US', 'en-US', or starting with 'en'.
  String? resolveLocaleId(String languageCode) {
    if (_locales.isEmpty) {
      // Fallback defaults if locales list could not be queried
      return languageCode == 'ta' ? 'ta_IN' : 'en_US';
    }

    final targetPrefix = languageCode.toLowerCase();
    if (targetPrefix == 'ta') {
      // Look for ta_IN specifically first, then any ta locale
      for (final loc in _locales) {
        final id = loc.localeId.toLowerCase().replaceAll('-', '_');
        if (id == 'ta_in') return loc.localeId;
      }
      for (final loc in _locales) {
        if (loc.localeId.toLowerCase().startsWith('ta')) return loc.localeId;
      }
      return null; // Tamil not available on device
    }

    // Default to English
    for (final loc in _locales) {
      final id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id == 'en_us' || id == 'en_in' || id == 'en_gb') return loc.localeId;
    }
    for (final loc in _locales) {
      if (loc.localeId.toLowerCase().startsWith('en')) return loc.localeId;
    }

    return _locales.isNotEmpty ? _locales.first.localeId : null;
  }

  /// Checks whether a language code ('en' or 'ta') is supported for STT.
  bool isLanguageSupported(String languageCode) {
    if (!_isAvailable) return false;
    if (_locales.isEmpty) return true; // Optimistic if locale list unavailable
    return resolveLocaleId(languageCode) != null;
  }

  /// Starts listening for speech in the requested language.
  ///
  /// - [onResult]: invoked whenever recognized words are received.
  /// - [languageCode]: 'en' or 'ta'
  /// - [onError]: optional callback on recognition failure
  Future<bool> startListening({
    required Function(String words, bool isFinal) onResult,
    String languageCode = 'en',
    Function(String error)? onError,
  }) async {
    _lastWords = '';
    _lastError = null;

    if (!_isInitialized) {
      final ok = await initialize(onError: onError);
      if (!ok) {
        _lastError = 'Speech recognition unavailable';
        return false;
      }
    }

    if (!_isAvailable) {
      _lastError = 'Speech recognition unavailable';
      return false;
    }

    final localeId = resolveLocaleId(languageCode);
    if (languageCode == 'ta' && localeId == null) {
      _lastError = 'Tamil speech recognition is not supported on this device';
      return false;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(result.recognizedWords, result.finalResult);
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
          localeId: localeId,
        ),
      );
      return true;
    } catch (e) {
      _lastError = e.toString();
      onError?.call(_lastError!);
      return false;
    }
  }

  /// Stops listening and returns any recognized text so far.
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Cancels listening and discards current recognition session.
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
    _lastWords = '';
  }
}

/// WeatherGPT — Text-to-Speech Service (Phase 9)
/// TTS wrapper using flutter_tts.
/// Supports English ('en-US') and Tamil ('ta-IN') voice playback.
library;

import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech service with language selection and playback controls.
///
/// [REAL — Phase 9]
class TtsService {
  final FlutterTts _tts;

  bool _isInitialized = false;
  bool _isAvailable = false;
  bool _isSpeaking = false;
  String? _lastError;
  List<dynamic> _availableLanguages = [];

  TtsService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  bool get isSpeaking => _isSpeaking;
  String? get lastError => _lastError;

  /// Initializes the TTS engine.
  Future<bool> initialize({
    Function()? onStart,
    Function()? onComplete,
    Function(String error)? onError,
  }) async {
    if (_isInitialized && _isAvailable) {
      return true;
    }

    try {
      _lastError = null;

      _tts.setStartHandler(() {
        _isSpeaking = true;
        onStart?.call();
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        onComplete?.call();
      });

      _tts.setCancelHandler(() {
        _isSpeaking = false;
        onComplete?.call();
      });

      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
        _lastError = msg.toString();
        onError?.call(_lastError!);
      });

      // Query available languages
      try {
        final langs = await _tts.getLanguages;
        if (langs is List) {
          _availableLanguages = langs;
        }
      } catch (_) {
        _availableLanguages = [];
      }

      await _tts.setSpeechRate(0.5); // Natural speaking rate
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _isInitialized = true;
      _isAvailable = true;
      return true;
    } catch (e) {
      _isInitialized = true;
      _isAvailable = false;
      _lastError = e.toString();
      return false;
    }
  }

  /// Resolves the locale tag for the TTS engine ('en-US' or 'ta-IN').
  String resolveTtsLanguage(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code == 'ta') {
      // Check if Tamil is in available languages list
      for (final lang in _availableLanguages) {
        final str = lang.toString().toLowerCase().replaceAll('_', '-');
        if (str == 'ta-in' || str.startsWith('ta')) {
          return lang.toString();
        }
      }
      return 'ta-IN';
    }

    // Default English
    for (final lang in _availableLanguages) {
      final str = lang.toString().toLowerCase().replaceAll('_', '-');
      if (str == 'en-us' || str == 'en-in' || str.startsWith('en')) {
        return lang.toString();
      }
    }
    return 'en-US';
  }

  /// Checks if the language is available on this device's TTS engine.
  Future<bool> isLanguageAvailable(String languageCode) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (!_isAvailable) return false;

    final target = resolveTtsLanguage(languageCode);
    try {
      final result = await _tts.isLanguageAvailable(target);
      if (result == 1 || result == true) {
        return true;
      }
      // If language query is inconclusive but availableLanguages has it:
      if (_availableLanguages.any((l) =>
          l.toString().toLowerCase().startsWith(languageCode.toLowerCase()))) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Prepares clean text for speech (strips Markdown symbols like ** or #).
  String sanitizeForSpeech(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m[1] ?? '') // bold
        .replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m[1] ?? '') // italics
        .replaceAll(RegExp(r'#+\s*'), '') // headings
        .replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m[1] ?? '') // inline code
        .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m[1] ?? '') // links
        .replaceAll(RegExp(r'[\r\n]+'), ' ') // collapse newlines
        .trim();
  }

  /// Speaks the given text in the specified language ('en' or 'ta').
  Future<bool> speak(
    String text, {
    String languageCode = 'en',
    Function()? onStart,
    Function()? onComplete,
    Function(String error)? onError,
  }) async {
    final cleanText = sanitizeForSpeech(text);
    if (cleanText.isEmpty) return false;

    if (!_isInitialized) {
      final ok = await initialize(
        onStart: onStart,
        onComplete: onComplete,
        onError: onError,
      );
      if (!ok) {
        _lastError = 'Text-to-speech is unavailable';
        onError?.call(_lastError!);
        return false;
      }
    }

    if (!_isAvailable) {
      _lastError = 'Text-to-speech is unavailable';
      onError?.call(_lastError!);
      return false;
    }

    // Stop any existing speech before starting
    if (_isSpeaking) {
      await stop();
    }

    final ttsLang = resolveTtsLanguage(languageCode);
    try {
      await _tts.setLanguage(ttsLang);
      final result = await _tts.speak(cleanText);
      if (result == 1 || result == true) {
        _isSpeaking = true;
        return true;
      }
      return false;
    } catch (e) {
      _lastError = e.toString();
      _isSpeaking = false;
      onError?.call(_lastError!);
      return false;
    }
  }

  /// Stops current speech output.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isSpeaking = false;
  }
}

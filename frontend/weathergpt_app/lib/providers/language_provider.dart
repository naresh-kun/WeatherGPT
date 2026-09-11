/// WeatherGPT — Language Provider (Phase 8: Multilingual)
/// Manages application locale state and local persistence.
library;

import 'package:flutter/material.dart';
import 'package:weathergpt_app/services/storage/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  static const String storageKey = 'app_language_code';

  final StorageService _storage;

  LanguageProvider({StorageService? storage})
      : _storage = storage ?? StorageService();

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;
  String get languageCode => _currentLocale.languageCode;
  bool get isTamil => _currentLocale.languageCode == 'ta';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  /// Initialise language preference from persistent storage.
  /// Falls back to English if nothing is stored or value is invalid.
  Future<void> init() async {
    try {
      final storedCode = await _storage.getString(storageKey);
      if (storedCode == 'ta') {
        _currentLocale = const Locale('ta');
      } else {
        _currentLocale = const Locale('en');
      }
    } catch (_) {
      _currentLocale = const Locale('en');
    }
    notifyListeners();
  }

  /// Change application locale and persist to storage.
  Future<void> setLocale(Locale locale) async {
    final code = locale.languageCode.toLowerCase() == 'ta' ? 'ta' : 'en';
    if (_currentLocale.languageCode == code) return;

    _currentLocale = Locale(code);
    notifyListeners();

    try {
      await _storage.saveString(storageKey, code);
    } catch (_) {
      // Best-effort persistence
    }
  }

  /// Convenience method to set language by code ('en' or 'ta').
  Future<void> setLanguageCode(String code) => setLocale(Locale(code));
}

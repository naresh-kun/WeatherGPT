/// WeatherGPT — Language Provider Unit Tests (Phase 8)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/providers/language_provider.dart';
import 'package:weathergpt_app/services/storage/storage_service.dart';

class FakeStorageService extends StorageService {
  final Map<String, String> _store = {};
  bool throwOnSave = false;
  bool throwOnGet = false;

  @override
  Future<void> saveString(String key, String value) async {
    if (throwOnSave) throw Exception('Disk write error');
    _store[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    if (throwOnGet) throw Exception('Disk read error');
    return _store[key];
  }
}

void main() {
  group('LanguageProvider', () {
    late FakeStorageService fakeStorage;
    late LanguageProvider provider;

    setUp(() {
      fakeStorage = FakeStorageService();
      provider = LanguageProvider(storage: fakeStorage);
    });

    test('defaults to English before init', () {
      expect(provider.languageCode, equals('en'));
      expect(provider.isEnglish, isTrue);
      expect(provider.isTamil, isFalse);
      expect(provider.currentLocale, equals(const Locale('en')));
    });

    test('init() loads English when storage is empty', () async {
      await provider.init();
      expect(provider.languageCode, equals('en'));
      expect(provider.isEnglish, isTrue);
      expect(provider.isTamil, isFalse);
    });

    test('init() loads Tamil when stored in storage', () async {
      fakeStorage._store[LanguageProvider.storageKey] = 'ta';
      await provider.init();
      expect(provider.languageCode, equals('ta'));
      expect(provider.isTamil, isTrue);
      expect(provider.isEnglish, isFalse);
    });

    test('init() falls back to English when invalid code is in storage', () async {
      fakeStorage._store[LanguageProvider.storageKey] = 'es';
      await provider.init();
      expect(provider.languageCode, equals('en'));
      expect(provider.isEnglish, isTrue);
    });

    test('init() handles storage exceptions gracefully', () async {
      fakeStorage.throwOnGet = true;
      await provider.init();
      expect(provider.languageCode, equals('en'));
    });

    test('setLanguageCode("ta") updates state, notifies listeners, and persists', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.setLanguageCode('ta');

      expect(notified, isTrue);
      expect(provider.languageCode, equals('ta'));
      expect(provider.isTamil, isTrue);
      expect(provider.isEnglish, isFalse);
      expect(fakeStorage._store[LanguageProvider.storageKey], equals('ta'));
    });

    test('setLanguageCode normalizes unknown codes to English', () async {
      await provider.setLanguageCode('ta');
      expect(provider.isTamil, isTrue);

      await provider.setLanguageCode('de');
      expect(provider.languageCode, equals('en'));
      expect(provider.isEnglish, isTrue);
      expect(fakeStorage._store[LanguageProvider.storageKey], equals('en'));
    });

    test('setting the same language does not re-notify or write storage', () async {
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      // Already 'en'
      await provider.setLanguageCode('en');
      expect(notifyCount, equals(0));
      expect(fakeStorage._store.containsKey(LanguageProvider.storageKey), isFalse);
    });

    test('setLanguageCode handles storage write exceptions gracefully', () async {
      fakeStorage.throwOnSave = true;

      // Should not throw
      await provider.setLanguageCode('ta');
      expect(provider.languageCode, equals('ta'));
    });
  });
}

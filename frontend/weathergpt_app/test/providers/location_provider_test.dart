/// WeatherGPT — Location Provider & Model Tests
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weathergpt_app/models/location.dart';
import 'package:weathergpt_app/providers/location_provider.dart';
import 'package:weathergpt_app/services/api/api_service.dart';
import 'package:weathergpt_app/services/location/location_service.dart';
import 'package:weathergpt_app/services/storage/storage_service.dart';

class FakeLocationService extends LocationService {
  Map<String, double>? mockCoords;

  @override
  Future<Map<String, double>?> getCurrentLocation() async => mockCoords;
}

class FakeStorageService extends StorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _store[key];
  }
}

void main() {
  group('Location Model', () {
    test('displayName returns city, country when both present', () {
      const loc = Location(lat: 9.92, lon: 78.11, city: 'Madurai', country: 'Tamil Nadu');
      expect(loc.displayName, equals('Madurai, Tamil Nadu'));
    });

    test('displayName returns city when country is null', () {
      const loc = Location(lat: 9.92, lon: 78.11, city: 'Madurai');
      expect(loc.displayName, equals('Madurai'));
    });

    test('displayName returns formatted coordinates when city is null', () {
      const loc = Location(lat: 9.5712, lon: 77.9623);
      expect(loc.displayName, equals('9.57, 77.96'));
    });

    test('displayName returns formatted coordinates when city is whitespace', () {
      const loc = Location(lat: 9.5712, lon: 77.9623, city: '   ');
      expect(loc.displayName, equals('9.57, 77.96'));
    });

    test('shortDisplayName returns city when present', () {
      const loc = Location(lat: 9.92, lon: 78.11, city: 'Madurai', country: 'Tamil Nadu');
      expect(loc.shortDisplayName, equals('Madurai'));
    });

    test('shortDisplayName returns formatted coordinates when city is null', () {
      const loc = Location(lat: 9.5712, lon: 77.9623);
      expect(loc.shortDisplayName, equals('9.57, 77.96'));
    });

    test('round-trip JSON serialization preserves all fields', () {
      const original = Location(
        lat: 9.57,
        lon: 77.96,
        city: 'Virudhunagar',
        country: 'Tamil Nadu, India',
        timezone: 'Asia/Kolkata',
      );
      final jsonString = original.toJsonString();
      final restored = Location.fromJsonString(jsonString);

      expect(restored.lat, equals(original.lat));
      expect(restored.lon, equals(original.lon));
      expect(restored.city, equals(original.city));
      expect(restored.country, equals(original.country));
      expect(restored.timezone, equals(original.timezone));
      expect(restored.displayName, equals(original.displayName));
    });
  });

  group('LocationProvider', () {
    late FakeLocationService fakeLocationService;
    late FakeStorageService fakeStorageService;

    setUp(() {
      fakeLocationService = FakeLocationService();
      fakeStorageService = FakeStorageService();
    });

    test('init restores persisted location from storage', () async {
      const saved = Location(lat: 13.08, lon: 80.27, city: 'Chennai', country: 'Tamil Nadu');
      await fakeStorageService.saveString('selected_location', saved.toJsonString());

      final provider = LocationProvider(
        locationService: fakeLocationService,
        storageService: fakeStorageService,
      );

      await provider.init();

      expect(provider.selectedLocation.city, equals('Chennai'));
      expect(provider.selectedLocation.displayName, equals('Chennai, Tamil Nadu'));
      expect(provider.selectedLocation.lat, equals(13.08));
      expect(provider.selectedLocation.lon, equals(80.27));
    });

    test('useCurrentLocation resolves city via reverse search when available', () async {
      fakeLocationService.mockCoords = {'lat': 9.9252, 'lon': 78.1198};

      final client = MockClient((request) async {
        if (request.url.path.contains('/weather/search')) {
          return http.Response(
            jsonEncode([
              {
                'name': 'Madurai',
                'region': 'Tamil Nadu',
                'country': 'India',
                'lat': 9.9252,
                'lon': 78.1198,
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('[]', 200);
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = LocationProvider(
        locationService: fakeLocationService,
        storageService: fakeStorageService,
        apiService: api,
      );

      await provider.useCurrentLocation();

      expect(provider.selectedLocation.city, equals('Madurai'));
      expect(provider.selectedLocation.country, equals('Tamil Nadu, India'));
      expect(provider.selectedLocation.displayName, equals('Madurai, Tamil Nadu, India'));
      expect(provider.selectedLocation.shortDisplayName, equals('Madurai'));
    });

    test('useCurrentLocation falls back to coordinates when reverse search fails or returns empty', () async {
      fakeLocationService.mockCoords = {'lat': 9.57, 'lon': 77.96};

      final client = MockClient((request) async {
        return http.Response('[]', 200, headers: {'content-type': 'application/json'});
      });

      final api = ApiService(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final provider = LocationProvider(
        locationService: fakeLocationService,
        storageService: fakeStorageService,
        apiService: api,
      );

      await provider.useCurrentLocation();

      // Must NOT invent or hardcode 'Madurai'
      expect(provider.selectedLocation.city, isNull);
      expect(provider.selectedLocation.displayName, equals('9.57, 77.96'));
      expect(provider.selectedLocation.shortDisplayName, equals('9.57, 77.96'));
      expect(provider.selectedLocation.lat, equals(9.57));
      expect(provider.selectedLocation.lon, equals(77.96));
    });

    test('selectLocation updates location, clears results, and persists', () async {
      final provider = LocationProvider(
        locationService: fakeLocationService,
        storageService: fakeStorageService,
      );

      const result = LocationSearchResult(
        name: 'Coimbatore',
        region: 'Tamil Nadu',
        country: 'India',
        lat: 11.0168,
        lon: 76.9558,
      );

      await provider.selectLocation(result);

      expect(provider.selectedLocation.city, equals('Coimbatore'));
      expect(provider.selectedLocation.displayName, equals('Coimbatore, Tamil Nadu, India'));
      expect(provider.selectedLocation.shortDisplayName, equals('Coimbatore'));
      expect(provider.searchResults, isEmpty);

      // Verify persistence
      final stored = await fakeStorageService.getString('selected_location');
      expect(stored, isNotNull);
      final decoded = Location.fromJsonString(stored!);
      expect(decoded.city, equals('Coimbatore'));
    });

    test('setLocation updates location and persists', () async {
      final provider = LocationProvider(
        locationService: fakeLocationService,
        storageService: fakeStorageService,
      );

      const newLoc = Location(lat: 8.71, lon: 77.75, city: 'Tirunelveli', country: 'Tamil Nadu');
      await provider.setLocation(newLoc);

      expect(provider.selectedLocation, equals(newLoc));

      final stored = await fakeStorageService.getString('selected_location');
      expect(stored, isNotNull);
      expect(Location.fromJsonString(stored!).city, equals('Tirunelveli'));
    });
  });
}

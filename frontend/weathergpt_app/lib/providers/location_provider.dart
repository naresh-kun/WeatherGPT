/// WeatherGPT — Location Provider
/// Manages selected location, GPS, city search, and persistence.
library;

import 'package:flutter/foundation.dart';
import 'package:weathergpt_app/models/models.dart';
import 'package:weathergpt_app/services/api/api_service.dart';
import 'package:weathergpt_app/services/location/location_service.dart';
import 'package:weathergpt_app/services/storage/storage_service.dart';

const _storageKey = 'selected_location';

/// Default fallback location (Madurai, Tamil Nadu).
const Location _defaultLocation = Location(
  lat: 9.9252,
  lon: 78.1198,
  city: 'Madurai',
  country: 'Tamil Nadu',
  timezone: 'Asia/Kolkata',
);

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;
  final StorageService _storageService;
  final ApiService _apiService;

  LocationProvider({
    LocationService? locationService,
    StorageService? storageService,
    ApiService? apiService,
  })  : _locationService = locationService ?? LocationService(),
        _storageService = storageService ?? StorageService(),
        _apiService = apiService ?? ApiService();

  Location _selectedLocation = _defaultLocation;
  Location get selectedLocation => _selectedLocation;

  List<LocationSearchResult> _searchResults = [];
  List<LocationSearchResult> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _gpsLoading = false;
  bool get gpsLoading => _gpsLoading;

  String? _locationError;
  String? get locationError => _locationError;

  /// Initialise: load saved location or attempt GPS.
  Future<void> init() async {
    // 1. Try loading a persisted location.
    final stored = await _storageService.getString(_storageKey);
    if (stored != null) {
      try {
        _selectedLocation = Location.fromJsonString(stored);
        notifyListeners();
        return;
      } catch (_) {
        // corrupted — fall through
      }
    }

    // 2. Try GPS.
    await useCurrentLocation();
  }

  /// Attempt to get the current GPS position.
  Future<void> useCurrentLocation() async {
    _gpsLoading = true;
    _locationError = null;
    notifyListeners();

    final coords = await _locationService.getCurrentLocation();
    if (coords != null) {
      final lat = coords['lat']!;
      final lon = coords['lon']!;
      String? resolvedCity;
      String? resolvedCountry;

      try {
        final results = await _apiService.searchLocations('$lat,$lon');
        if (results.isNotEmpty && results.first.name.trim().isNotEmpty) {
          resolvedCity = results.first.name.trim();
          final region = results.first.region.trim();
          final country = results.first.country.trim();
          final parts = [if (region.isNotEmpty) region, if (country.isNotEmpty) country];
          resolvedCountry = parts.isNotEmpty ? parts.join(', ') : null;
        }
      } catch (_) {
        // Reverse-resolution failed or offline: keep city null to display coordinates
      }

      _selectedLocation = Location(
        lat: lat,
        lon: lon,
        city: resolvedCity,
        country: resolvedCountry,
      );
      await _persist();
    } else {
      _locationError =
          'Could not get current location. Using default location.';
      _selectedLocation = _defaultLocation;
    }
    _gpsLoading = false;
    notifyListeners();
  }

  /// Search locations via backend.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchLocations(query);
    } catch (_) {
      _searchResults = [];
    }
    _isSearching = false;
    notifyListeners();
  }

  /// Select a location from search results.
  Future<void> selectLocation(LocationSearchResult result) async {
    _selectedLocation = Location(
      lat: result.lat,
      lon: result.lon,
      city: result.name,
      country: '${result.region}, ${result.country}',
    );
    _searchResults = [];
    await _persist();
    notifyListeners();
  }

  /// Manually set a location.
  Future<void> setLocation(Location location) async {
    _selectedLocation = location;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      await _storageService.saveString(
          _storageKey, _selectedLocation.toJsonString());
    } catch (_) {
      // non-critical
    }
  }
}

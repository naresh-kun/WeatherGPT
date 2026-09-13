/// WeatherGPT — Climate Provider (Phase 7)
/// Lightweight ChangeNotifier state management for deterministic climate data.
library;

import 'package:flutter/foundation.dart';
import 'package:weathergpt_app/models/models.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

enum ClimateState { initial, loading, success, error }

class ClimateStation {
  final String name;
  final double lat;
  final double lon;

  const ClimateStation({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

const List<ClimateStation> supportedClimateStations = [
  ClimateStation(name: 'Madurai', lat: 9.9252, lon: 78.1198),
  ClimateStation(name: 'Chennai', lat: 13.0827, lon: 80.2707),
  ClimateStation(name: 'Coimbatore', lat: 11.0168, lon: 76.9558),
  ClimateStation(name: 'Tirunelveli', lat: 8.7139, lon: 77.7567),
];

class ClimateProvider extends ChangeNotifier {
  final ApiService _api;

  ClimateProvider({ApiService? api}) : _api = api ?? ApiService();

  ClimateState _state = ClimateState.initial;
  ClimateState get state => _state;

  ClimateResponse? _climateResponse;
  ClimateResponse? get climateResponse => _climateResponse;

  Location? _activeLocation;
  Location? get activeLocation => _activeLocation;

  String? _selectedLocation;
  String get selectedLocation =>
      _selectedLocation ??
      (_activeLocation != null
          ? findNearestStationName(
              _activeLocation!.lat, _activeLocation!.lon, _activeLocation!.city)
          : supportedClimateStations.first.name);

  /// Helper to check whether active live location exactly matches the selected climate station.
  bool get isExactMatch =>
      _activeLocation != null &&
      isStationExactMatch(_activeLocation!, selectedLocation);

  /// Map coordinates/city to the closest supported climate station.
  static String findNearestStationName(double lat, double lon, [String? cityName]) {
    if (cityName != null && cityName.trim().isNotEmpty) {
      final query = cityName.trim().toLowerCase();
      for (final s in supportedClimateStations) {
        if (s.name.toLowerCase() == query) {
          return s.name;
        }
      }
    }

    ClimateStation nearest = supportedClimateStations.first;
    double minDistanceSq = double.infinity;
    for (final s in supportedClimateStations) {
      final dLat = lat - s.lat;
      final dLon = lon - s.lon;
      final distSq = dLat * dLat + dLon * dLon;
      if (distSq < minDistanceSq) {
        minDistanceSq = distSq;
        nearest = s;
      }
    }
    return nearest.name;
  }

  /// Check whether a Location matches a climate station exactly.
  static bool isStationExactMatch(Location loc, String stationName) {
    if (loc.city != null && loc.city!.trim().isNotEmpty) {
      if (loc.city!.trim().toLowerCase() == stationName.trim().toLowerCase()) {
        return true;
      }
    }
    final station = supportedClimateStations.firstWhere(
      (s) => s.name.toLowerCase() == stationName.trim().toLowerCase(),
      orElse: () => supportedClimateStations.first,
    );
    final dLat = (loc.lat - station.lat).abs();
    final dLon = (loc.lon - station.lon).abs();
    return dLat < 0.05 && dLon < 0.05;
  }

  int _yearFrom = 2000;
  int get yearFrom => _yearFrom;

  int _yearTo = 2023;
  int get yearTo => _yearTo;

  int? _selectedMonth;
  int? get selectedMonth => _selectedMonth;

  String? _loadedLocation;
  int? _loadedYearFrom;
  int? _loadedYearTo;
  int? _loadedMonth;

  String? _activeLanguage;
  String? get activeLanguage => _activeLanguage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> get availableLocations =>
      _climateResponse?.availableLocations.isNotEmpty == true
          ? _climateResponse!.availableLocations
          : const ['Madurai', 'Chennai', 'Coimbatore', 'Tirunelveli'];

  DateTime? _lastFetched;
  DateTime? get lastFetched => _lastFetched;

  /// Default TTL for cached climate data (10 minutes).
  static const Duration defaultTtl = Duration(minutes: 10);

  /// Check whether existing loaded climate data is still fresh.
  bool isFresh([Duration ttl = defaultTtl]) {
    if (_state != ClimateState.success || _climateResponse == null || _lastFetched == null) {
      return false;
    }
    return DateTime.now().difference(_lastFetched!) < ttl;
  }

  /// Load climate analysis from the backend API.
  ///
  /// Reuses fresh existing data if location and period parameters have not changed
  /// and [force] is false.
  Future<void> loadClimate({
    String? location,
    int? yearFrom,
    int? yearTo,
    int? month,
    String? language,
    bool force = false,
  }) async {
    final targetLocation = location ?? selectedLocation;
    final targetYearFrom = yearFrom ?? _yearFrom;
    final targetYearTo = yearTo ?? _yearTo;

    // Reuse valid, fresh existing data when parameters are unchanged and not forced
    if (!force &&
        isFresh() &&
        targetLocation == _loadedLocation &&
        targetYearFrom == _loadedYearFrom &&
        targetYearTo == _loadedYearTo &&
        month == _loadedMonth) {
      _activeLanguage = language ?? _activeLanguage;
      return;
    }

    _selectedLocation = targetLocation;
    _yearFrom = targetYearFrom;
    _yearTo = targetYearTo;
    _selectedMonth = month;
    if (language != null) _activeLanguage = language;

    _state = ClimateState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getClimate(
        location: _selectedLocation!,
        yearFrom: _yearFrom,
        yearTo: _yearTo,
        month: _selectedMonth,
        language: _activeLanguage,
      );

      _climateResponse = response;
      _loadedLocation = _selectedLocation;
      _loadedYearFrom = _yearFrom;
      _loadedYearTo = _yearTo;
      _loadedMonth = _selectedMonth;
      _lastFetched = DateTime.now();
      _state = ClimateState.success;
    } on LocationNotFoundException {
      _errorMessage = 'Historical climate data for "$_selectedLocation" was not found.';
      _state = ClimateState.error;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ClimateState.error;
    } catch (e) {
      _errorMessage = 'Failed to load climate data. Please try again.';
      _state = ClimateState.error;
    }
    notifyListeners();
  }

  /// Synchronize climate provider with the active app location from LocationProvider.
  /// Automatically maps arbitrary coordinates or cities to the nearest supported climate dataset station.
  Future<void> syncWithLocation(Location loc, {String? language, bool force = false}) async {
    _activeLocation = loc;
    final nearestStation = findNearestStationName(loc.lat, loc.lon, loc.city);
    _selectedLocation = nearestStation;
    await loadClimate(location: nearestStation, language: language ?? _activeLanguage, force: force);
  }

  /// Change the selected location and fetch updated climate intelligence.
  Future<void> setLocation(String location) async {
    if (_loadedLocation == location && _state == ClimateState.success && isFresh()) return;
    _selectedLocation = location;
    await loadClimate(location: location, language: _activeLanguage);
  }

  /// Change the year range and reload data.
  Future<void> setYearRange(int from, int to) async {
    _yearFrom = from;
    _yearTo = to;
    await loadClimate(yearFrom: from, yearTo: to, language: _activeLanguage);
  }

  /// Change the month filter and reload data.
  Future<void> setMonth(int? month) async {
    await loadClimate(month: month, language: _activeLanguage);
  }

  /// Retry the last climate fetch.
  Future<void> retry() => loadClimate(language: _activeLanguage, force: true);

  /// Refresh climate data.
  Future<void> refresh({String? language}) => loadClimate(language: language ?? _activeLanguage, force: true);
}

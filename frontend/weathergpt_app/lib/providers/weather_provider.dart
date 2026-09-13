/// WeatherGPT — Weather Provider
/// Lightweight ChangeNotifier state management for weather data.
library;

import 'package:flutter/foundation.dart';
import 'package:weathergpt_app/models/models.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

enum WeatherState { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  final ApiService _api;

  WeatherProvider({ApiService? api}) : _api = api ?? ApiService();

  WeatherState _state = WeatherState.initial;
  WeatherState get state => _state;

  WeatherCurrent? _currentWeather;
  WeatherCurrent? get currentWeather => _currentWeather;

  WeatherForecast? _forecast;
  WeatherForecast? get forecast => _forecast;

  List<WeatherAlert> _alerts = [];
  List<WeatherAlert> get alerts => _alerts;

  List<WeatherAdvisory> _advisories = [];
  List<WeatherAdvisory> get advisories => _advisories;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double? _activeLat;
  double? _activeLon;
  String? _activeLanguage;

  DateTime? _lastFetched;
  DateTime? get lastFetched => _lastFetched;

  /// Default TTL for cached weather data (5 minutes).
  static const Duration defaultTtl = Duration(minutes: 5);

  /// Check whether existing loaded weather data is still fresh.
  bool isFresh([Duration ttl = defaultTtl]) {
    if (_state != WeatherState.success || _currentWeather == null || _lastFetched == null) {
      return false;
    }
    return DateTime.now().difference(_lastFetched!) < ttl;
  }

  /// Load all weather data for the given coordinates.
  /// Fetches current weather, forecast (hourly + daily), alerts, and advisories
  /// concurrently to minimize latency.
  ///
  /// If data for the exact same coordinates is already loaded and fresh (within [defaultTtl]),
  /// and [force] is false, existing data is reused without unnecessary API calls.
  Future<void> loadWeather(
    double lat,
    double lon, {
    String? language,
    bool force = false,
  }) async {
    // Reuse valid, fresh existing data when location is unchanged and not forced
    if (!force && isFresh() && _activeLat == lat && _activeLon == lon) {
      _activeLanguage = language ?? _activeLanguage;
      return;
    }

    // Guard against duplicate in-flight requests for the exact same location and language
    if (_state == WeatherState.loading &&
        _activeLat == lat &&
        _activeLon == lon &&
        _activeLanguage == language) {
      return;
    }
    _activeLat = lat;
    _activeLon = lon;
    _activeLanguage = language;

    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch current, forecast, alerts, and advisories concurrently.
      final results = await Future.wait([
        _api.getCurrentWeather(lat, lon),
        _api.getForecast(lat, lon),
        _api.getAlerts(lat, lon, language: language),
        _api.getAdvisories(lat, lon, language: language),
      ]);

      _currentWeather = results[0] as WeatherCurrent;
      _forecast = results[1] as WeatherForecast;
      final alertsResponse = results[2] as WeatherAlertsResponse;
      _alerts = alertsResponse.alerts;
      final advisoriesResponse = results[3] as WeatherAdvisoriesResponse;
      _advisories = advisoriesResponse.advisories;
      _lastFetched = DateTime.now();
      _state = WeatherState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = WeatherState.error;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = WeatherState.error;
    }
    notifyListeners();
  }

  /// Get advisories filtered by a specific category.
  List<WeatherAdvisory> advisoriesForCategory(AdvisoryCategory category) {
    return _advisories.where((a) => a.category == category).toList();
  }

  /// Refresh weather data for the same location (forces fresh network fetch).
  Future<void> refresh(double lat, double lon, {String? language}) =>
      loadWeather(lat, lon, language: language ?? _activeLanguage, force: true);
}

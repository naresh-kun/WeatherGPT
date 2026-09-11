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

  /// Load all weather data for the given coordinates.
  /// Fetches current weather, forecast (hourly + daily), alerts, and advisories
  /// concurrently to minimize latency.
  Future<void> loadWeather(double lat, double lon, {String? language}) async {
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

  /// Refresh weather data for the same location.
  Future<void> refresh(double lat, double lon, {String? language}) =>
      loadWeather(lat, lon, language: language ?? _activeLanguage);
}

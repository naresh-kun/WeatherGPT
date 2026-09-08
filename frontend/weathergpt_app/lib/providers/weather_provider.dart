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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Load all weather data for the given coordinates.
  /// Fetches current weather, forecast (hourly + daily), and alerts
  /// reusing the forecast response for hourly to minimize API calls.
  Future<void> loadWeather(double lat, double lon) async {
    _state = WeatherState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch current, forecast, and alerts concurrently.
      final results = await Future.wait([
        _api.getCurrentWeather(lat, lon),
        _api.getForecast(lat, lon),
        _api.getAlerts(lat, lon),
      ]);

      _currentWeather = results[0] as WeatherCurrent;
      _forecast = results[1] as WeatherForecast;
      final alertsResponse = results[2] as WeatherAlertsResponse;
      _alerts = alertsResponse.alerts;
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

  /// Refresh weather data for the same location.
  Future<void> refresh(double lat, double lon) => loadWeather(lat, lon);
}

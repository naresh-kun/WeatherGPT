/// WeatherGPT — Climate Provider (Phase 7)
/// Lightweight ChangeNotifier state management for deterministic climate data.
library;

import 'package:flutter/foundation.dart';
import 'package:weathergpt_app/models/models.dart';
import 'package:weathergpt_app/services/api/api_service.dart';

enum ClimateState { initial, loading, success, error }

class ClimateProvider extends ChangeNotifier {
  final ApiService _api;

  ClimateProvider({ApiService? api}) : _api = api ?? ApiService();

  ClimateState _state = ClimateState.initial;
  ClimateState get state => _state;

  ClimateResponse? _climateResponse;
  ClimateResponse? get climateResponse => _climateResponse;

  String _selectedLocation = 'Madurai';
  String get selectedLocation => _selectedLocation;

  int _yearFrom = 2000;
  int get yearFrom => _yearFrom;

  int _yearTo = 2023;
  int get yearTo => _yearTo;

  int? _selectedMonth;
  int? get selectedMonth => _selectedMonth;

  String? _activeLanguage;
  String? get activeLanguage => _activeLanguage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> get availableLocations =>
      _climateResponse?.availableLocations.isNotEmpty == true
          ? _climateResponse!.availableLocations
          : const ['Madurai', 'Chennai', 'Coimbatore', 'Tirunelveli'];

  /// Load climate analysis from the backend API.
  Future<void> loadClimate({
    String? location,
    int? yearFrom,
    int? yearTo,
    int? month,
    String? language,
  }) async {
    if (location != null) _selectedLocation = location;
    if (yearFrom != null) _yearFrom = yearFrom;
    if (yearTo != null) _yearTo = yearTo;
    if (language != null) _activeLanguage = language;
    _selectedMonth = month; // Can be set or set back to null

    _state = ClimateState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getClimate(
        location: _selectedLocation,
        yearFrom: _yearFrom,
        yearTo: _yearTo,
        month: _selectedMonth,
        language: _activeLanguage,
      );

      _climateResponse = response;
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

  /// Change the selected location and fetch updated climate intelligence.
  Future<void> setLocation(String location) async {
    if (_selectedLocation == location && _state == ClimateState.success) return;
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
    _selectedMonth = month;
    await loadClimate(month: month, language: _activeLanguage);
  }

  /// Retry the last climate fetch.
  Future<void> retry() => loadClimate(language: _activeLanguage);

  /// Refresh climate data.
  Future<void> refresh({String? language}) => loadClimate(language: language ?? _activeLanguage);
}

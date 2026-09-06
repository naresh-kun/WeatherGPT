/// Weather models aligned with docs/api/DATA_MODELS.md.

import 'package:weathergpt_app/models/location.dart';

class WeatherCurrent {
  const WeatherCurrent({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.description,
    required this.icon,
    required this.timestamp,
    this.uvIndex,
    this.visibility,
    this.rainProbability,
  });

  final Location location;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final String description;
  final String icon;
  final double? uvIndex;
  final double? visibility;
  final double? rainProbability;
  final int timestamp;
}

class HourlyForecast {
  const HourlyForecast({
    required this.timestamp,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.precipitationProbability,
    this.displayTime,
  });

  final int timestamp;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double precipitationProbability;

  /// UI-friendly time label (e.g. "10 PM") — populated by mock/API layer.
  final String? displayTime;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.precipitationProbability,
    this.displayDay,
  });

  final String date;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final int sunrise;
  final int sunset;
  final double precipitationProbability;

  /// UI-friendly day label (e.g. "Mon") — populated by mock/API layer.
  final String? displayDay;
}

class WeatherForecast {
  const WeatherForecast({
    required this.location,
    required this.hourly,
    required this.daily,
    required this.units,
  });

  final Location location;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final String units;
}

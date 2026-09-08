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

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) {
    return WeatherCurrent(
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['wind_speed'] as num).toDouble(),
      windDirection: (json['wind_direction'] as num).toInt(),
      description: json['description'] as String,
      icon: json['icon'] as String,
      uvIndex: (json['uv_index'] as num?)?.toDouble(),
      visibility: (json['visibility'] as num?)?.toDouble(),
      rainProbability: (json['rain_probability'] as num?)?.toDouble(),
      timestamp: (json['timestamp'] as num).toInt(),
    );
  }
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

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final ts = (json['timestamp'] as num).toInt();
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    final hour = date.hour;
    final display = hour == 0
        ? '12 AM'
        : (hour < 12 ? '$hour AM' : (hour == 12 ? '12 PM' : '${hour - 12} PM'));

    return HourlyForecast(
      timestamp: ts,
      temperature: (json['temperature'] as num).toDouble(),
      feelsLike: (json['feels_like'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['wind_speed'] as num).toDouble(),
      description: json['description'] as String,
      icon: json['icon'] as String,
      precipitationProbability:
          (json['precipitation_probability'] as num).toDouble(),
      displayTime: display,
    );
  }
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

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String;
    final dt = DateTime.parse(dateStr);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final display = days[dt.weekday - 1];

    return DailyForecast(
      date: dateStr,
      tempMin: (json['temp_min'] as num).toDouble(),
      tempMax: (json['temp_max'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['wind_speed'] as num).toDouble(),
      description: json['description'] as String,
      icon: json['icon'] as String,
      sunrise: (json['sunrise'] as num).toInt(),
      sunset: (json['sunset'] as num).toInt(),
      precipitationProbability:
          (json['precipitation_probability'] as num).toDouble(),
      displayDay: display,
    );
  }
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

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      hourly: (json['hourly'] as List<dynamic>)
          .map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
          .toList(),
      daily: (json['daily'] as List<dynamic>)
          .map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
          .toList(),
      units: json['units'] as String? ?? 'metric',
    );
  }
}

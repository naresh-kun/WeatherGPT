/// Weather icon and formatting utilities.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/models/alert.dart';

class WeatherUtils {
  WeatherUtils._();

  /// Maps a backend weather icon/description string to a Material icon.
  /// Handles both Phase 2 mock codes ('sunny', 'cloudy') and
  /// Phase 3 backend codes (WeatherAPI condition text or icon URLs).
  static IconData iconForCondition(String iconCode) {
    final lc = iconCode.toLowerCase();
    if (lc.contains('sunny') || lc.contains('clear') || lc.contains('113')) {
      return Icons.wb_sunny_outlined;
    } else if (lc.contains('partly') || lc.contains('116')) {
      return Icons.wb_cloudy;
    } else if (lc.contains('cloudy') || lc.contains('overcast') ||
        lc.contains('119') || lc.contains('122')) {
      return Icons.cloud_outlined;
    } else if (lc.contains('rain') || lc.contains('drizzle') ||
        lc.contains('shower') || lc.contains('176') || lc.contains('296') ||
        lc.contains('308') || lc.contains('353')) {
      return Icons.water_drop_outlined;
    } else if (lc.contains('thunder') || lc.contains('storm') ||
        lc.contains('386') || lc.contains('389')) {
      return Icons.thunderstorm_outlined;
    } else if (lc.contains('wind') || lc.contains('mist') ||
        lc.contains('fog') || lc.contains('143') || lc.contains('248')) {
      return Icons.air;
    } else if (lc.contains('snow') || lc.contains('sleet') ||
        lc.contains('ice') || lc.contains('blizzard')) {
      return Icons.ac_unit;
    }
    return Icons.wb_cloudy;
  }

  static Color iconColorForCondition(String iconCode) {
    final lc = iconCode.toLowerCase();
    if (lc.contains('sunny') || lc.contains('clear') || lc.contains('113')) {
      return Colors.amber.shade600;
    } else if (lc.contains('rain') || lc.contains('shower') ||
        lc.contains('thunder') || lc.contains('storm') ||
        lc.contains('176') || lc.contains('308') || lc.contains('386')) {
      return AppColors.primary;
    }
    return AppColors.textSecondary;
  }

  static IconData iconForAlertType(String alertType) {
    switch (alertType) {
      case 'rain':
      case 'flood':
        return Icons.water_drop;
      case 'heatwave':
        return Icons.thermostat;
      case 'wind':
      case 'cyclone':
        return Icons.air;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'fog':
        return Icons.cloud;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  static Color colorForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.minor:
        return AppColors.severityInfo;
      case AlertSeverity.moderate:
        return AppColors.severityModerate;
      case AlertSeverity.severe:
      case AlertSeverity.extreme:
        return AppColors.severitySevere;
    }
  }

  static String labelForSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.minor:
        return 'Informational';
      case AlertSeverity.moderate:
        return 'Moderate';
      case AlertSeverity.severe:
        return 'Severe';
      case AlertSeverity.extreme:
        return 'Extreme';
    }
  }

  static String formatPercent(double probability) =>
      '${(probability * 100).round()}%';

  static String formatTemperature(double temp) => '${temp.round()}°';
}

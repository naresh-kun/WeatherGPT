/// Weather icon and formatting utilities.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/models/alert.dart';

class WeatherUtils {
  WeatherUtils._();

  static IconData iconForCondition(String iconCode) {
    switch (iconCode) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny_outlined;
      case 'partly_cloudy':
        return Icons.wb_cloudy;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud_outlined;
      case 'rain':
      case 'light_rain':
        return Icons.water_drop_outlined;
      case 'thunderstorm':
        return Icons.thunderstorm_outlined;
      case 'wind':
        return Icons.air;
      default:
        return Icons.wb_cloudy;
    }
  }

  static Color iconColorForCondition(String iconCode) {
    switch (iconCode) {
      case 'sunny':
      case 'clear':
        return Colors.amber.shade600;
      case 'rain':
      case 'light_rain':
      case 'thunderstorm':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData iconForAlertType(String alertType) {
    switch (alertType) {
      case 'rain':
        return Icons.water_drop;
      case 'heatwave':
        return Icons.thermostat;
      case 'wind':
        return Icons.air;
      case 'thunderstorm':
        return Icons.thunderstorm;
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

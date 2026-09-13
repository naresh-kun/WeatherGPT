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

  static String labelForSeverity(AlertSeverity severity, {bool isTamil = false}) {
    if (isTamil) {
      switch (severity) {
        case AlertSeverity.minor:
          return 'தகவல்';
        case AlertSeverity.moderate:
          return 'மிதமான';
        case AlertSeverity.severe:
          return 'கடுமையான';
        case AlertSeverity.extreme:
          return 'தீவிரமான';
      }
    }
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

  static const Map<String, String> _tamilConditions = {
    'sunny': 'வெயில்',
    'clear': 'தெளிவான வானம்',
    'partly cloudy': 'பகுதி மேகமூட்டம்',
    'cloudy': 'மேகமூட்டம்',
    'overcast': 'மந்தமான வானம்',
    'mist': 'பனிமூட்டம்',
    'fog': 'அடர்ந்த மூடுபனி',
    'freezing fog': 'உறைபனி மூட்டம்',
    'patchy rain nearby': 'அங்கொன்றும் இங்கொன்றுமான மழை',
    'patchy snow nearby': 'அங்கொன்றும் இங்கொன்றுமான பனிப்பொழிவு',
    'patchy sleet nearby': 'அங்கொன்றும் இங்கொன்றுமான ஆலங்கட்டி மழை',
    'patchy freezing drizzle nearby': 'உறைபனி சாரல்',
    'thundery outbreaks nearby': 'இடியுடன் கூடிய வானிலை',
    'blowing snow': 'காற்றுடன் கூடிய பனிப்பொழிவு',
    'blizzard': 'பனிப்புயல்',
    'patchy light drizzle': 'லேசான சாரல்',
    'light drizzle': 'லேசான சாரல்',
    'freezing drizzle': 'உறைபனி சாரல்',
    'heavy freezing drizzle': 'கடும் உறைபனி சாரல்',
    'patchy light rain': 'லேசான மழை',
    'light rain': 'லேசான மழை',
    'moderate rain at times': 'அவ்வப்போது மிதமான மழை',
    'moderate rain': 'மிதமான மழை',
    'heavy rain at times': 'அவ்வப்போது பலத்த மழை',
    'heavy rain': 'பலத்த மழை',
    'light freezing rain': 'லேசான உறைபனி மழை',
    'moderate or heavy freezing rain': 'மிதமான அல்லது பலத்த உறைபனி மழை',
    'light sleet': 'லேசான ஆலங்கட்டி மழை',
    'moderate or heavy sleet': 'மிதமான அல்லது பலத்த ஆலங்கட்டி மழை',
    'patchy light snow': 'லேசான பனிப்பொழிவு',
    'light snow': 'லேசான பனிப்பொழிவு',
    'patchy moderate snow': 'மிதமான பனிப்பொழிவு',
    'moderate snow': 'மிதமான பனிப்பொழிவு',
    'patchy heavy snow': 'பலத்த பனிப்பொழிவு',
    'heavy snow': 'பலத்த பனிப்பொழிவு',
    'ice pellets': 'பனிக்கட்டிகள்',
    'light rain shower': 'லேசான மழைச்சாரல்',
    'moderate or heavy rain shower': 'மிதமான அல்லது பலத்த மழைச்சாரல்',
    'torrential rain shower': 'கொட்டும் கனமழை',
    'light sleet showers': 'லேசான ஆலங்கட்டி மழைச்சாரல்',
    'moderate or heavy sleet showers': 'மிதமான அல்லது பலத்த ஆலங்கட்டி மழைச்சாரல்',
    'light snow showers': 'லேசான பனிச்சாரல்',
    'moderate or heavy snow showers': 'மிதமான அல்லது பலத்த பனிச்சாரல்',
    'light showers of ice pellets': 'லேசான பனிக்கட்டி பொழிவு',
    'moderate or heavy showers of ice pellets': 'மிதமான அல்லது பலத்த பனிக்கட்டி பொழிவு',
    'patchy light rain with thunder': 'இடியுடன் கூடிய லேசான மழை',
    'moderate or heavy rain with thunder': 'இடியுடன் கூடிய பலத்த மழை',
    'patchy light snow with thunder': 'இடியுடன் கூடிய லேசான பனிப்பொழிவு',
    'moderate or heavy snow with thunder': 'இடியுடன் கூடிய பலத்த பனிப்பொழிவு',
    'thundershower': 'இடிமழை',
    'thunderstorm': 'இடிமின்னலுடன் புயல்',
  };

  /// Deterministically localizes WeatherAPI condition text to Tamil when [isTamil] is true.
  /// When [isTamil] is false, returns original [condition] unchanged.
  static String localizeCondition(String condition, {bool isTamil = false}) {
    if (!isTamil) return condition;
    final trimmed = condition.trim().toLowerCase();
    if (_tamilConditions.containsKey(trimmed)) {
      return _tamilConditions[trimmed]!;
    }
    for (final entry in _tamilConditions.entries) {
      if (trimmed.contains(entry.key)) {
        return entry.value;
      }
    }
    return condition;
  }

  /// Maps day abbreviations and relative days (e.g. Mon, Today) to Tamil.
  static String localizeDay(String? day, {bool isTamil = false}) {
    if (day == null) return '';
    if (!isTamil) return day;
    switch (day.toLowerCase()) {
      case 'mon':
      case 'monday':
        return 'திங்கள்';
      case 'tue':
      case 'tuesday':
        return 'செவ்வாய்';
      case 'wed':
      case 'wednesday':
        return 'புதன்';
      case 'thu':
      case 'thursday':
        return 'வியாழன்';
      case 'fri':
      case 'friday':
        return 'வெள்ளி';
      case 'sat':
      case 'saturday':
        return 'சனி';
      case 'sun':
      case 'sunday':
        return 'ஞாயிறு';
      case 'today':
        return 'இன்று';
      case 'tomorrow':
        return 'நாளை';
      default:
        return day;
    }
  }

  static String formatPercent(double probability) =>
      '${(probability * 100).round()}%';

  static String formatTemperature(double temp) => '${temp.round()}°';
}

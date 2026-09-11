// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WeatherGPT';

  @override
  String get navHome => 'Home';

  @override
  String get navChat => 'WeatherGPT';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navAdvisory => 'Advisory';

  @override
  String get navClimate => 'Climate';

  @override
  String get retry => 'Retry';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get loading => 'Loading...';

  @override
  String get viewAll => 'View all';

  @override
  String get fetchingWeather => 'Fetching weather...';

  @override
  String get unableToFetchWeather =>
      'Unable to fetch weather right now.\nPlease check your connection and try again.';

  @override
  String get hourlyForecast => 'Hourly Forecast';

  @override
  String get fullForecast => 'Full forecast';

  @override
  String get sevenDayPreview => '7-Day Preview';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get humidity => 'Humidity';

  @override
  String get wind => 'Wind';

  @override
  String get rain => 'Rain';

  @override
  String get uvIndex => 'UV Index';

  @override
  String get feelsLike => 'Feels like';

  @override
  String get forecastTitle => 'Forecast';

  @override
  String get loadingForecast => 'Loading forecast...';

  @override
  String get sevenDayForecast => '7-Day Forecast';

  @override
  String get alertsTitle => 'Weather Alerts';

  @override
  String get fetchingAlerts => 'Fetching alerts...';

  @override
  String get noActiveAlerts => 'No active weather alerts';

  @override
  String allClearFor(String location) {
    return 'All clear for $location';
  }

  @override
  String alertsForLocation(String location) {
    return 'Alerts for $location';
  }

  @override
  String activeAlertsSummary(int count, String location) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'alerts',
      one: 'alert',
    );
    return '$count active $_temp0 for $location';
  }

  @override
  String get advisoryTitle => 'Weather Advisory';

  @override
  String get fetchingAdvisories => 'Fetching advisories...';

  @override
  String get noAdvisories => 'No weather advisories';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOutdoor => 'Outdoor';

  @override
  String get categoryAgriculture => 'Agriculture';

  @override
  String get recommendation => 'Recommendation';

  @override
  String get reason => 'Reason';

  @override
  String get weatherFactors => 'Weather factors considered';

  @override
  String get climateTitle => 'Climate Intelligence';

  @override
  String get analyzingClimate => 'Analyzing historical climate records...';

  @override
  String get refreshClimate => 'Refresh Climate Data';

  @override
  String get historicalComparison =>
      'Historical Comparison vs 2000–2023 Baseline';

  @override
  String get temperature => 'Temperature';

  @override
  String get rainfall => 'Rainfall';

  @override
  String get aboveAvg => 'Above Avg';

  @override
  String get belowAvg => 'Below Avg';

  @override
  String get nearAvg => 'Near Avg';

  @override
  String get climateInsightTitle => 'Climate Intelligence Insight';

  @override
  String get aiAssistantSubtitle => 'Your AI Weather Assistant';

  @override
  String get weatherGptThinking => 'WeatherGPT is thinking...';

  @override
  String get askWeatherHint => 'Ask about the weather...';

  @override
  String get voiceNotAvailable =>
      'Voice input will be available in a future phase.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get locationSection => 'Location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get languageSection => 'Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get weatherAlerts => 'Weather Alerts';

  @override
  String get receiveWeatherAlerts => 'Receive weather alert notifications';

  @override
  String get voiceSection => 'Voice';

  @override
  String get voiceResponses => 'Voice Responses';

  @override
  String get enableTts => 'Enable text-to-speech for WeatherGPT';

  @override
  String get unitsSection => 'Units';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutSubtitle =>
      'SIH Prototype\nAI-powered conversational weather assistant';
}

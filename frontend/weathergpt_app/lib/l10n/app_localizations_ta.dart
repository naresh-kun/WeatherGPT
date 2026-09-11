// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'WeatherGPT';

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navChat => 'WeatherGPT';

  @override
  String get navAlerts => 'எச்சரிக்கைகள்';

  @override
  String get navAdvisory => 'அறிவுரைகள்';

  @override
  String get navClimate => 'காலநிலை';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get dismiss => 'நீக்கு';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get viewAll => 'அனைத்தும்';

  @override
  String get fetchingWeather => 'வானிலை தரவு பெறப்படுகிறது...';

  @override
  String get unableToFetchWeather =>
      'வானிலை தரவை இப்போது பெற முடியவில்லை.\nஉங்கள் இணைய இணைப்பை சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get hourlyForecast => 'மணிநேர முன்னறிவிப்பு';

  @override
  String get fullForecast => 'முழு முன்னறிவிப்பு';

  @override
  String get sevenDayPreview => '7-நாள் முன்னோட்டம்';

  @override
  String get useCurrentLocation => 'தற்போதைய இருப்பிடத்தைப் பயன்படுத்து';

  @override
  String get humidity => 'ஈரப்பதம்';

  @override
  String get wind => 'காற்று';

  @override
  String get rain => 'மழை';

  @override
  String get uvIndex => 'UV குறியீடு';

  @override
  String get feelsLike => 'உணரப்படும் வெப்பநிலை';

  @override
  String get forecastTitle => 'வானிலை முன்னறிவிப்பு';

  @override
  String get loadingForecast => 'முன்னறிவிப்பு ஏற்றப்படுகிறது...';

  @override
  String get sevenDayForecast => '7-நாள் முன்னறிவிப்பு';

  @override
  String get alertsTitle => 'வானிலை எச்சரிக்கைகள்';

  @override
  String get fetchingAlerts => 'எச்சரிக்கைகள் பெறப்படுகின்றன...';

  @override
  String get noActiveAlerts => 'செயலில் உள்ள வானிலை எச்சரிக்கைகள் இல்லை';

  @override
  String allClearFor(String location) {
    return '$location பகுதியில் அனைத்தும் பாதுகாப்பாக உள்ளது';
  }

  @override
  String alertsForLocation(String location) {
    return '$location பகுதிக்கான எச்சரிக்கைகள்';
  }

  @override
  String activeAlertsSummary(int count, String location) {
    return '$location பகுதிக்கு $count செயலில் உள்ள எச்சரிக்கைகள்';
  }

  @override
  String get advisoryTitle => 'வானிலை அறிவுரை';

  @override
  String get fetchingAdvisories => 'அறிவுரைகள் பெறப்படுகின்றன...';

  @override
  String get noAdvisories => 'வானிலை அறிவுரைகள் எதுவும் இல்லை';

  @override
  String get categoryAll => 'அனைத்தும்';

  @override
  String get categoryGeneral => 'பொதுவானவை';

  @override
  String get categoryTravel => 'பயணம்';

  @override
  String get categoryHealth => 'சுகாதாரம்';

  @override
  String get categoryOutdoor => 'வெளிப்புறம்';

  @override
  String get categoryAgriculture => 'விவசாயம்';

  @override
  String get recommendation => 'பரிந்துரை';

  @override
  String get reason => 'காரணம்';

  @override
  String get weatherFactors => 'கருத்தில் கொள்ளப்பட்ட வானிலை காரணிகள்';

  @override
  String get climateTitle => 'காலநிலை நுண்ணறிவு';

  @override
  String get analyzingClimate =>
      'வரலாற்று காலநிலை பதிவுகள் பகுப்பாய்வு செய்யப்படுகின்றன...';

  @override
  String get refreshClimate => 'காலநிலை தரவை புதுப்பிக்கவும்';

  @override
  String get historicalComparison => '2000–2023 வரலாற்று சராசரியுடன் ஒப்பீடு';

  @override
  String get temperature => 'வெப்பநிலை';

  @override
  String get rainfall => 'மழைப்பொழிவு';

  @override
  String get aboveAvg => 'சராசரியை விட அதிகம்';

  @override
  String get belowAvg => 'சராசரியை விட குறைவு';

  @override
  String get nearAvg => 'சராசரிக்கு அருகில்';

  @override
  String get climateInsightTitle => 'காலநிலை நுண்ணறிவு தகவல்';

  @override
  String get aiAssistantSubtitle => 'உங்கள் AI வானிலை உதவியாளர்';

  @override
  String get weatherGptThinking => 'WeatherGPT யோசிக்கிறது...';

  @override
  String get askWeatherHint => 'வானிலை பற்றி கேளுங்கள்...';

  @override
  String get voiceNotAvailable =>
      'குரல் உள்ளீடு எதிர்கால கட்டத்தில் கிடைக்கும்.';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get locationSection => 'இருப்பிடம்';

  @override
  String get currentLocation => 'தற்போதைய இருப்பிடம்';

  @override
  String get languageSection => 'மொழி';

  @override
  String get english => 'English';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get notificationsSection => 'அறிவிப்புகள்';

  @override
  String get weatherAlerts => 'வானிலை எச்சரிக்கைகள்';

  @override
  String get receiveWeatherAlerts =>
      'வானிலை எச்சரிக்கை அறிவிப்புகளைப் பெறுங்கள்';

  @override
  String get voiceSection => 'குரல்';

  @override
  String get voiceResponses => 'குரல் பதில்கள்';

  @override
  String get enableTts => 'WeatherGPT-க்கான குரல் வெளியீட்டை இயக்கு';

  @override
  String get unitsSection => 'அலகுகள்';

  @override
  String get aboutSection => 'பற்றி';

  @override
  String get aboutSubtitle =>
      'SIH மாதிரி வடிவம்\nசெயற்கை நுண்ணறிவு வானிலை உதவியாளர்';
}

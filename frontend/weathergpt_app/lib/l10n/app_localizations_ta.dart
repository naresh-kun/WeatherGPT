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
  String get voiceListening => 'கேட்கிறது...';

  @override
  String get voiceTapToSpeak => 'பேச தட்டவும்';

  @override
  String get voiceStopListening => 'கேட்பதை நிறுத்து';

  @override
  String get voiceCancelListening => 'ரத்துசெய்';

  @override
  String get voiceSpeakResponse => 'பதிலை வாசி';

  @override
  String get voiceStopSpeaking => 'பேசுவதை நிறுத்து';

  @override
  String get voiceMicPermissionDenied =>
      'குரல் உள்ளீட்டிற்கு மைக்ரோஃபோன் அனுமதி தேவை.';

  @override
  String get voiceUnavailable => 'இந்த சாதனத்தில் குரல் உள்ளீடு கிடைக்கவில்லை.';

  @override
  String get voiceTamilUnavailable =>
      'இந்த சாதனத்தில் தமிழ் குரல் உள்ளீடு ஆதரிக்கப்படவில்லை. நீங்கள் உரை அரட்டையைப் பயன்படுத்தலாம்.';

  @override
  String get voiceTtsUnavailable => 'குரல் பின்னணி கிடைக்கவில்லை.';

  @override
  String get voiceTtsTamilUnavailable =>
      'இந்த சாதனத்தில் தமிழ் குரல் பின்னணி ஆதரிக்கப்படவில்லை.';

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

  @override
  String get weatherGptCheckingWeather =>
      'WeatherGPT வானிலையை சரிபார்க்கிறது...';

  @override
  String get quickActionTemperature => 'வெப்பநிலை என்ன?';

  @override
  String get quickActionRain => 'மழை பெய்யுமா?';

  @override
  String get quickActionAlerts => 'வானிலை எச்சரிக்கைகள் உள்ளதா?';

  @override
  String get quickActionOutdoor => 'வெளிப்புற நடவடிக்கைகளுக்கு ஏற்றதா?';

  @override
  String get quickActionForecast => 'நாளை வானிலை முன்னறிவிப்பு என்ன?';

  @override
  String get quickActionUmbrella => 'எனக்கு குடை தேவையா?';

  @override
  String get changeLocation => 'இருப்பிடத்தை மாற்று';

  @override
  String get activeLocation => 'செயலில் உள்ள இருப்பிடம்';

  @override
  String get errorWeatherUnavailable =>
      'தற்போது வானிலை தரவை பெற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorGeminiBusy =>
      'WeatherGPT தற்போது பிஸியாக உள்ளது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorRateLimit =>
      'WeatherGPT கோரிக்கை வரம்பை எட்டியுள்ளது. பின்னர் முயற்சிக்கவும்.';

  @override
  String get errorChatTimeout =>
      'WeatherGPT பதிலளிக்க அதிக நேரம் எடுக்கிறது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get errorConnection =>
      'WeatherGPT சேவையகத்தை தொடர்பு கொள்ள முடியவில்லை. உங்கள் இணைப்பை சரிபார்க்கவும்.';

  @override
  String get chatWelcomeMessage =>
      'வணக்கம்! 👋 நான் WeatherGPT. இன்று வானிலை பற்றி நான் உங்களுக்கு எப்படி உதவலாம்?';

  @override
  String get askWeatherGpt => 'WeatherGPT-யிடம் கேளுங்கள்';

  @override
  String get activeWarnings => 'செயலில் உள்ள எச்சரிக்கைகள்';

  @override
  String get noAlertsForLocation =>
      'இந்த இடத்திற்கு செயலில் உள்ள வானிலை எச்சரிக்கைகள் இல்லை.';

  @override
  String get temperatureTrend => 'வெப்பநிலை போக்கு';

  @override
  String get noHourlyData => 'மணிநேர தரவு எதுவும் கிடைக்கவில்லை';

  @override
  String get noDailyData => 'தினசரி முன்னறிவிப்பு கிடைக்கவில்லை';

  @override
  String get observedLabel => 'கண்டறியப்பட்டது';

  @override
  String get thresholdLabel => 'வரம்பு';

  @override
  String guidanceForLocation(String location) {
    return '$location பகுதிக்கான வானிலை வழிகாட்டுதல்';
  }

  @override
  String allClearConditions(String location) {
    return '$location பகுதியில் அனைத்து நிலைகளும் சீராக உள்ளன';
  }

  @override
  String advisoriesAvailable(int count) {
    return '$count அறிவுரைகள் உள்ளன';
  }

  @override
  String get failedToLoadClimate => 'காலநிலை தரவை ஏற்றுவதில் தோல்வி';

  @override
  String get noClimateRecords => 'காலநிலை பதிவுகள் எதுவும் கிடைக்கவில்லை.';

  @override
  String get locationLabel => 'இருப்பிடம்:';

  @override
  String get periodRange => 'கால வரம்பு';

  @override
  String annualAvgTemp(String period) {
    return 'ஆண்டு சராசரி வெப்பநிலை ($period)';
  }

  @override
  String get annualRainfallTrend => 'ஆண்டு மழைப்பொழிவு போக்கு';

  @override
  String annualPrecipitation(String period) {
    return 'ஆண்டு மொத்த மழைப்பொழிவு ($period)';
  }

  @override
  String get anomaly => 'மாறுபாடு';

  @override
  String get averageAbbr => 'சராசரி';

  @override
  String homeSuggestionRain(String location) {
    return 'இன்று $location-ல் மழை பெய்யுமா?';
  }

  @override
  String get homeSuggestionWear => 'இன்று என்ன உடை அணியலாம்?';

  @override
  String get homeSuggestionFarming => 'இன்று விவசாயத்திற்கு ஏற்ற நாளா?';
}

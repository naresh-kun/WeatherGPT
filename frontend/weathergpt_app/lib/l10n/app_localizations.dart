import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'WeatherGPT'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'WeatherGPT'**
  String get navChat;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navAdvisory.
  ///
  /// In en, this message translates to:
  /// **'Advisory'**
  String get navAdvisory;

  /// No description provided for @navClimate.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get navClimate;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @fetchingWeather.
  ///
  /// In en, this message translates to:
  /// **'Fetching weather...'**
  String get fetchingWeather;

  /// No description provided for @unableToFetchWeather.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch weather right now.\nPlease check your connection and try again.'**
  String get unableToFetchWeather;

  /// No description provided for @hourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Hourly Forecast'**
  String get hourlyForecast;

  /// No description provided for @fullForecast.
  ///
  /// In en, this message translates to:
  /// **'Full forecast'**
  String get fullForecast;

  /// No description provided for @sevenDayPreview.
  ///
  /// In en, this message translates to:
  /// **'7-Day Preview'**
  String get sevenDayPreview;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @uvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV Index'**
  String get uvIndex;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like'**
  String get feelsLike;

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecastTitle;

  /// No description provided for @loadingForecast.
  ///
  /// In en, this message translates to:
  /// **'Loading forecast...'**
  String get loadingForecast;

  /// No description provided for @sevenDayForecast.
  ///
  /// In en, this message translates to:
  /// **'7-Day Forecast'**
  String get sevenDayForecast;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get alertsTitle;

  /// No description provided for @fetchingAlerts.
  ///
  /// In en, this message translates to:
  /// **'Fetching alerts...'**
  String get fetchingAlerts;

  /// No description provided for @noActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'No active weather alerts'**
  String get noActiveAlerts;

  /// No description provided for @allClearFor.
  ///
  /// In en, this message translates to:
  /// **'All clear for {location}'**
  String allClearFor(String location);

  /// No description provided for @alertsForLocation.
  ///
  /// In en, this message translates to:
  /// **'Alerts for {location}'**
  String alertsForLocation(String location);

  /// No description provided for @activeAlertsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} active {count, plural, =1{alert} other{alerts}} for {location}'**
  String activeAlertsSummary(int count, String location);

  /// No description provided for @advisoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather Advisory'**
  String get advisoryTitle;

  /// No description provided for @fetchingAdvisories.
  ///
  /// In en, this message translates to:
  /// **'Fetching advisories...'**
  String get fetchingAdvisories;

  /// No description provided for @noAdvisories.
  ///
  /// In en, this message translates to:
  /// **'No weather advisories'**
  String get noAdvisories;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Outdoor'**
  String get categoryOutdoor;

  /// No description provided for @categoryAgriculture.
  ///
  /// In en, this message translates to:
  /// **'Agriculture'**
  String get categoryAgriculture;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @weatherFactors.
  ///
  /// In en, this message translates to:
  /// **'Weather factors considered'**
  String get weatherFactors;

  /// No description provided for @climateTitle.
  ///
  /// In en, this message translates to:
  /// **'Climate Intelligence'**
  String get climateTitle;

  /// No description provided for @analyzingClimate.
  ///
  /// In en, this message translates to:
  /// **'Analyzing historical climate records...'**
  String get analyzingClimate;

  /// No description provided for @refreshClimate.
  ///
  /// In en, this message translates to:
  /// **'Refresh Climate Data'**
  String get refreshClimate;

  /// No description provided for @historicalComparison.
  ///
  /// In en, this message translates to:
  /// **'Historical Comparison vs 2000–2023 Baseline'**
  String get historicalComparison;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @rainfall.
  ///
  /// In en, this message translates to:
  /// **'Rainfall'**
  String get rainfall;

  /// No description provided for @aboveAvg.
  ///
  /// In en, this message translates to:
  /// **'Above Avg'**
  String get aboveAvg;

  /// No description provided for @belowAvg.
  ///
  /// In en, this message translates to:
  /// **'Below Avg'**
  String get belowAvg;

  /// No description provided for @nearAvg.
  ///
  /// In en, this message translates to:
  /// **'Near Avg'**
  String get nearAvg;

  /// No description provided for @climateInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Climate Intelligence Insight'**
  String get climateInsightTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI Weather Assistant'**
  String get aiAssistantSubtitle;

  /// No description provided for @weatherGptThinking.
  ///
  /// In en, this message translates to:
  /// **'WeatherGPT is thinking...'**
  String get weatherGptThinking;

  /// No description provided for @askWeatherHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about the weather...'**
  String get askWeatherHint;

  /// No description provided for @voiceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input will be available in a future phase.'**
  String get voiceNotAvailable;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @locationSection.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationSection;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @weatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Weather Alerts'**
  String get weatherAlerts;

  /// No description provided for @receiveWeatherAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive weather alert notifications'**
  String get receiveWeatherAlerts;

  /// No description provided for @voiceSection.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceSection;

  /// No description provided for @voiceResponses.
  ///
  /// In en, this message translates to:
  /// **'Voice Responses'**
  String get voiceResponses;

  /// No description provided for @enableTts.
  ///
  /// In en, this message translates to:
  /// **'Enable text-to-speech for WeatherGPT'**
  String get enableTts;

  /// No description provided for @unitsSection.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsSection;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SIH Prototype\nAI-powered conversational weather assistant'**
  String get aboutSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

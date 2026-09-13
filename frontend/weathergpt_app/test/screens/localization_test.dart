/// WeatherGPT — Localization Tests (Phase 8: Multilingual)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/core/utils/weather_utils.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/models/advisory.dart';
import 'package:weathergpt_app/models/alert.dart';
import 'package:weathergpt_app/screens/settings/settings_screen.dart';
import 'package:weathergpt_app/widgets/advisory/advisory_card.dart';

Widget _createLocalizedApp({
  required Locale locale,
  required Widget child,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  group('Multilingual UI Localization', () {
    testWidgets('English AppLocalizations loads correct strings', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        _createLocalizedApp(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return Text(l10n.alertsTitle);
            },
          ),
        ),
      );

      expect(find.text('Weather Alerts'), findsOneWidget);
      expect(l10n.navHome, equals('Home'));
      expect(l10n.navChat, equals('WeatherGPT'));
      expect(l10n.navAlerts, equals('Alerts'));
      expect(l10n.navAdvisory, equals('Advisory'));
      expect(l10n.navClimate, equals('Climate'));
      expect(l10n.settingsTitle, equals('Settings'));
      expect(l10n.languageSection, equals('Language'));
      expect(l10n.hourlyForecast, equals('Hourly Forecast'));
      expect(l10n.recommendation, equals('Recommendation'));
      expect(l10n.climateTitle, equals('Climate Intelligence'));
    });

    testWidgets('Tamil AppLocalizations loads correct human-authored strings', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        _createLocalizedApp(
          locale: const Locale('ta'),
          child: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return Text(l10n.alertsTitle);
            },
          ),
        ),
      );

      expect(find.text('வானிலை எச்சரிக்கைகள்'), findsOneWidget);
      expect(l10n.navHome, equals('முகப்பு'));
      expect(l10n.navAlerts, equals('எச்சரிக்கைகள்'));
      expect(l10n.navAdvisory, equals('அறிவுரைகள்'));
      expect(l10n.navClimate, equals('காலநிலை'));
      expect(l10n.settingsTitle, equals('அமைப்புகள்'));
      expect(l10n.languageSection, equals('மொழி'));
      expect(l10n.english, equals('English'));
      expect(l10n.tamil, equals('தமிழ்'));
      expect(l10n.hourlyForecast, equals('மணிநேர முன்னறிவிப்பு'));
      expect(l10n.recommendation, equals('பரிந்துரை'));
      expect(l10n.climateTitle, equals('காலநிலை நுண்ணறிவு'));
    });

    testWidgets('AdvisoryCard localizes category and recommendation in Tamil', (tester) async {
      final advisory = WeatherAdvisory(
        advisoryId: 'adv-001',
        category: AdvisoryCategory.health,
        title: 'அதிக வெப்ப எச்சரிக்கை',
        message: '40.5°C வெப்பநிலை பதிவாகியுள்ளது.',
        recommendation: 'நிழலில் இருக்கவும், நீர் அருந்தவும்.',
        validUntil: 1756224000,
      );

      await tester.pumpWidget(
        _createLocalizedApp(
          locale: const Locale('ta'),
          child: Scaffold(
            body: AdvisoryCard(advisory: advisory),
          ),
        ),
      );

      expect(find.text('அதிக வெப்ப எச்சரிக்கை'), findsOneWidget);
      expect(find.text('சுகாதாரம்'), findsOneWidget); // Localized category
      expect(find.text('பரிந்துரை'), findsOneWidget); // Localized "Recommendation"
      expect(find.text('நிழலில் இருக்கவும், நீர் அருந்தவும்.'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays language options and respects current locale', (tester) async {
      await languageProvider.setLanguageCode('en');
      expect(languageProvider.languageCode, equals('en'));

      await tester.pumpWidget(
        _createLocalizedApp(
          locale: const Locale('en'),
          child: const SettingsScreen(),
        ),
      );

      // Verify language section header and tiles
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);

      // Test with Tamil locale
      await tester.pumpWidget(
        _createLocalizedApp(
          locale: const Locale('ta'),
          child: const SettingsScreen(),
        ),
      );

      expect(find.text('மொழி'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
    });

    test('Tamil AppLocalizations contains complete UI labels', () async {
      final l10nTa = await AppLocalizations.delegate.load(const Locale('ta'));
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));

      // Core weather metrics
      expect(l10nTa.humidity, equals('ஈரப்பதம்'));
      expect(l10nTa.wind, equals('காற்று'));
      expect(l10nTa.rain, equals('மழை'));
      expect(l10nTa.uvIndex, equals('UV குறியீடு'));
      expect(l10nTa.feelsLike, equals('உணரப்படும் வெப்பநிலை'));

      // Headers & sections
      expect(l10nTa.askWeatherGpt, equals('WeatherGPT-யிடம் கேளுங்கள்'));
      expect(l10nTa.activeWarnings, equals('செயலில் உள்ள எச்சரிக்கைகள்'));
      expect(l10nTa.temperatureTrend, equals('வெப்பநிலை போக்கு'));
      expect(l10nTa.forecastTitle, equals('வானிலை முன்னறிவிப்பு'));

      // Empty & error states
      expect(l10nTa.noAlertsForLocation, equals('இந்த இடத்திற்கு செயலில் உள்ள வானிலை எச்சரிக்கைகள் இல்லை.'));
      expect(l10nTa.noHourlyData, equals('மணிநேர தரவு எதுவும் கிடைக்கவில்லை'));
      expect(l10nTa.noDailyData, equals('தினசரி முன்னறிவிப்பு கிடைக்கவில்லை'));

      // Welcome message
      expect(l10nTa.chatWelcomeMessage, equals('வணக்கம்! 👋 நான் WeatherGPT. இன்று வானிலை பற்றி நான் உங்களுக்கு எப்படி உதவலாம்?'));
      expect(l10nEn.chatWelcomeMessage, equals("Hey! 👋 I'm WeatherGPT. How can I help you with the weather today?"));
    });

    test('Deterministic WeatherAPI condition mapping in Tamil vs English', () {
      // In Tamil
      expect(WeatherUtils.localizeCondition('Sunny', isTamil: true), equals('வெயில்'));
      expect(WeatherUtils.localizeCondition('Clear', isTamil: true), equals('தெளிவான வானம்'));
      expect(WeatherUtils.localizeCondition('Partly cloudy', isTamil: true), equals('பகுதி மேகமூட்டம்'));
      expect(WeatherUtils.localizeCondition('Overcast', isTamil: true), equals('மந்தமான வானம்'));
      expect(WeatherUtils.localizeCondition('Light rain', isTamil: true), equals('லேசான மழை'));
      expect(WeatherUtils.localizeCondition('Moderate rain', isTamil: true), equals('மிதமான மழை'));
      expect(WeatherUtils.localizeCondition('Heavy rain', isTamil: true), equals('பலத்த மழை'));
      expect(WeatherUtils.localizeCondition('Thunderstorm', isTamil: true), equals('இடிமின்னலுடன் புயல்'));

      // In English (must remain completely unchanged)
      expect(WeatherUtils.localizeCondition('Sunny', isTamil: false), equals('Sunny'));
      expect(WeatherUtils.localizeCondition('Partly cloudy', isTamil: false), equals('Partly cloudy'));
      expect(WeatherUtils.localizeCondition('Overcast', isTamil: false), equals('Overcast'));
      expect(WeatherUtils.localizeCondition('Light rain', isTamil: false), equals('Light rain'));
    });

    test('Deterministic Day name mapping in Tamil vs English', () {
      // In Tamil
      expect(WeatherUtils.localizeDay('Mon', isTamil: true), equals('திங்கள்'));
      expect(WeatherUtils.localizeDay('Tue', isTamil: true), equals('செவ்வாய்'));
      expect(WeatherUtils.localizeDay('Wed', isTamil: true), equals('புதன்'));
      expect(WeatherUtils.localizeDay('Thu', isTamil: true), equals('வியாழன்'));
      expect(WeatherUtils.localizeDay('Fri', isTamil: true), equals('வெள்ளி'));
      expect(WeatherUtils.localizeDay('Sat', isTamil: true), equals('சனி'));
      expect(WeatherUtils.localizeDay('Sun', isTamil: true), equals('ஞாயிறு'));
      expect(WeatherUtils.localizeDay('Today', isTamil: true), equals('இன்று'));
      expect(WeatherUtils.localizeDay('Tomorrow', isTamil: true), equals('நாளை'));

      // In English (must remain completely unchanged)
      expect(WeatherUtils.localizeDay('Mon', isTamil: false), equals('Mon'));
      expect(WeatherUtils.localizeDay('Today', isTamil: false), equals('Today'));
      expect(WeatherUtils.localizeDay('Tomorrow', isTamil: false), equals('Tomorrow'));
    });

    test('Deterministic Alert severity label mapping in Tamil vs English', () {
      // In Tamil
      expect(WeatherUtils.labelForSeverity(AlertSeverity.minor, isTamil: true), equals('தகவல்'));
      expect(WeatherUtils.labelForSeverity(AlertSeverity.moderate, isTamil: true), equals('மிதமான'));
      expect(WeatherUtils.labelForSeverity(AlertSeverity.severe, isTamil: true), equals('கடுமையான'));
      expect(WeatherUtils.labelForSeverity(AlertSeverity.extreme, isTamil: true), equals('தீவிரமான'));

      // In English
      expect(WeatherUtils.labelForSeverity(AlertSeverity.minor, isTamil: false), equals('Informational'));
      expect(WeatherUtils.labelForSeverity(AlertSeverity.moderate, isTamil: false), equals('Moderate'));
      expect(WeatherUtils.labelForSeverity(AlertSeverity.severe, isTamil: false), equals('Severe'));
      expect(WeatherUtils.labelForSeverity(AlertSeverity.extreme, isTamil: false), equals('Extreme'));
    });

    test('Numeric values and unit symbols remain exact', () {
      expect(WeatherUtils.formatTemperature(28.7), equals('29°'));
      expect(WeatherUtils.formatTemperature(0.0), equals('0°'));
      expect(WeatherUtils.formatTemperature(-3.2), equals('-3°'));
      expect(WeatherUtils.formatPercent(0.45), equals('45%'));
      expect(WeatherUtils.formatPercent(1.0), equals('100%'));
      expect(WeatherUtils.formatPercent(0.0), equals('0%'));
    });
  });
}

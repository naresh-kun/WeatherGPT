/// WeatherGPT — Localization Tests (Phase 8: Multilingual)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_app/l10n/app_localizations.dart';
import 'package:weathergpt_app/main.dart';
import 'package:weathergpt_app/models/advisory.dart';
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
  });
}

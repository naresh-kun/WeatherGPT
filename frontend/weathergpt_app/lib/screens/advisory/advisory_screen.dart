/// WeatherGPT — Advisory Screen
/// Weather-based advisories dashboard with category detail views.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/models/advisory.dart';
import 'package:weathergpt_app/widgets/advisory/advisory_widgets.dart';

class AdvisoryScreen extends StatelessWidget {
  const AdvisoryScreen({super.key});

  WeatherAdvisory _advisoryForCategory(AdvisoryCategory category) {
    return MockData.advisories.firstWhere((a) => a.category == category);
  }

  void _openCategory(BuildContext context, AdvisoryCategory category) {
    final advisory = _advisoryForCategory(category);
    final emoji = MockData.advisoryCategoryEmojis[category] ?? '';
    final label = MockData.advisoryCategoryLabels[category] ?? category.name;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('$emoji $label Advisory'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: AdvisoryDetailCard(advisory: advisory),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = AdvisoryCategory.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Advisory'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          Text(
            'Personalized advisories for ${MockData.currentLocation.displayName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AdvisoryCategoryCard(
                category: category,
                onTap: () => _openCategory(context, category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

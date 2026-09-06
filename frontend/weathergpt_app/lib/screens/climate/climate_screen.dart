/// WeatherGPT — Climate Screen
/// Historical climate trend charts with time range selector.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/widgets/climate/climate_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  late String _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = MockData.climateRangeOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    final dataset = MockData.climateForRange(_selectedRange);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Climate Trends'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              MockData.currentLocation.displayName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            SegmentedButton<String>(
              segments: MockData.climateRangeOptions
                  .map((range) => ButtonSegment(value: range, label: Text(range)))
                  .toList(),
              selected: {_selectedRange},
              onSelectionChanged: (selection) {
                setState(() => _selectedRange = selection.first);
              },
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            CommonCard(
              color: AppColors.primary.withValues(alpha: 0.06),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dataset.summary,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            const SectionHeader(title: 'Temperature Trend'),
            CommonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataset.temperatureTrend.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  ClimateLineChart(trend: dataset.temperatureTrend),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            const SectionHeader(title: 'Rainfall Trend'),
            CommonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dataset.rainfallTrend.summary,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  RainfallChart(trend: dataset.rainfallTrend),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

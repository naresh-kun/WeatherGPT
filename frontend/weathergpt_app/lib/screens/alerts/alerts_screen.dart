/// WeatherGPT — Alerts Screen
/// Active weather alerts dashboard with mock data.

import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/data/mock_data.dart';
import 'package:weathergpt_app/models/alert.dart';
import 'package:weathergpt_app/widgets/alerts/alert_widgets.dart';
import 'package:weathergpt_app/widgets/common/common_widgets.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  void _showAlertDetail(BuildContext context, WeatherAlert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXLarge),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            AlertCard(alert: alert),
            const SizedBox(height: AppDimensions.paddingMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = MockData.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          Text(
            '${alerts.length} active alerts for ${MockData.currentLocation.displayName}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ...alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AlertCard(
                alert: alert,
                onTap: () => _showAlertDetail(context, alert),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          const SectionHeader(title: 'State Components'),
          const CommonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reusable state widgets (for future API integration)',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12),
                SizedBox(height: 80, child: LoadingWidget(message: 'Fetching alerts...')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

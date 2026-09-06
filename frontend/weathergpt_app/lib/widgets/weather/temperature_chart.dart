import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/models/weather.dart';

class TemperatureChart extends StatelessWidget {
  const TemperatureChart({
    super.key,
    required this.hourlyData,
    this.height = 200,
  });

  final List<HourlyForecast> hourlyData;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data available')),
      );
    }

    final spots = hourlyData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperature);
    }).toList();

    final minY = hourlyData.map((e) => e.temperature).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = hourlyData.map((e) => e.temperature).reduce((a, b) => a > b ? a : b) + 2;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  '${value.round()}°',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= hourlyData.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      hourlyData[index].displayTime ?? '',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (hourlyData.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.surface,
                  strokeWidth: 2,
                  strokeColor: AppColors.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

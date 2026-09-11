/// WeatherGPT — Climate Trend Charts
/// Interactive LineChart for temperature and BarChart for rainfall using fl_chart.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weathergpt_app/core/theme/app_theme.dart';
import 'package:weathergpt_app/models/climate.dart';

class ClimateLineChart extends StatelessWidget {
  const ClimateLineChart({
    super.key,
    required this.trend,
    this.height = 220,
    this.lineColor = AppColors.primary,
  });

  final ClimateTrend trend;
  final double height;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    final points = trend.values;
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No historical temperature data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final values = points.map((e) => e.value).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final diff = maxY - minY;
    final padding = diff > 0 ? diff * 0.15 : 1.0;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(
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
                reservedSize: 42,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)}°',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: points.length > 8 ? 2 : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${points[index].year}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (points.length - 1).toDouble() > 0 ? (points.length - 1).toDouble() : 1.0,
          minY: minY - padding,
          maxY: maxY + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: points.length > 2,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: points.length <= 15),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RainfallChart extends StatelessWidget {
  const RainfallChart({
    super.key,
    required this.trend,
    this.height = 220,
  });

  final ClimateTrend trend;
  final double height;

  @override
  Widget build(BuildContext context) {
    final points = trend.values;
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No historical rainfall data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final rawMax = points.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = rawMax > 0 ? rawMax * 1.15 : 100.0;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(
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
                reservedSize: 42,
                getTitlesWidget: (value, meta) => Text(
                  '${value.round()}mm',
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${points[index].year}',
                      style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: points.asMap().entries.map((entry) {
            final barWidth = points.length > 15 ? 8.0 : (points.length > 8 ? 12.0 : 16.0);
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  color: AppColors.accent,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

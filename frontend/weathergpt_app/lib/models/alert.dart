/// Alert model aligned with docs/api/DATA_MODELS.md.
library;

enum AlertSeverity { minor, moderate, severe, extreme }

class WeatherAlert {
  const WeatherAlert({
    required this.alertId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.description,
    required this.area,
    required this.startTime,
    this.endTime,
    this.source,
    this.relevantValue,
    this.threshold,
    this.displayDate,
  });

  final String alertId;
  final String alertType;
  final AlertSeverity severity;
  final String title;
  final String description;
  final String area;
  final int startTime;
  final int? endTime;
  final String? source;
  final double? relevantValue;
  final double? threshold;

  /// UI-friendly date/time label.
  final String? displayDate;

  /// Formatted representation of the triggering weather value.
  String? get formattedRelevantValue {
    if (relevantValue == null) return null;
    final type = alertType.toLowerCase();
    if (type == 'heat' || type == 'heatwave') {
      return '${relevantValue!.toStringAsFixed(1)}°C';
    } else if (type == 'rain' || type == 'flood') {
      return '${relevantValue!.toStringAsFixed(0)}%';
    } else if (type == 'wind' || type == 'cyclone') {
      return '${relevantValue!.toStringAsFixed(0)} km/h';
    } else if (type == 'uv') {
      return 'UV ${relevantValue!.toStringAsFixed(0)}';
    }
    return relevantValue!.toString();
  }

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    final sevStr = (json['severity'] as String?)?.toLowerCase() ?? 'minor';
    AlertSeverity parsedSeverity;
    switch (sevStr) {
      case 'moderate':
        parsedSeverity = AlertSeverity.moderate;
      case 'severe':
        parsedSeverity = AlertSeverity.severe;
      case 'extreme':
        parsedSeverity = AlertSeverity.extreme;
      default:
        parsedSeverity = AlertSeverity.minor;
    }

    return WeatherAlert(
      alertId: json['alert_id'] as String? ?? '',
      alertType: json['alert_type'] as String? ?? 'other',
      severity: parsedSeverity,
      title: json['title'] as String? ?? 'Weather Alert',
      description: json['description'] as String? ?? '',
      area: json['area'] as String? ?? '',
      startTime: (json['start_time'] as num?)?.toInt() ?? 0,
      endTime: (json['end_time'] as num?)?.toInt(),
      source: json['source'] as String?,
      relevantValue: (json['relevant_value'] as num?)?.toDouble(),
      threshold: (json['threshold'] as num?)?.toDouble(),
    );
  }
}

class WeatherAlertsResponse {
  const WeatherAlertsResponse({
    required this.alerts,
    required this.total,
  });

  final List<WeatherAlert> alerts;
  final int total;

  factory WeatherAlertsResponse.fromJson(Map<String, dynamic> json) {
    return WeatherAlertsResponse(
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

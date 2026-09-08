/// Alert model aligned with docs/api/DATA_MODELS.md.

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

  /// UI-friendly date/time label.
  final String? displayDate;

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

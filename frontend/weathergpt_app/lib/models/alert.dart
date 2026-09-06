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
}

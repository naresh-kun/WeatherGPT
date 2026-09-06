/// Location model aligned with docs/api/DATA_MODELS.md.

class Location {
  const Location({
    required this.lat,
    required this.lon,
    this.city,
    this.country,
    this.timezone,
  });

  final double lat;
  final double lon;
  final String? city;
  final String? country;
  final String? timezone;

  String get displayName {
    if (city != null && country != null) {
      return '$city, $country';
    }
    if (city != null) return city!;
    return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
  }
}

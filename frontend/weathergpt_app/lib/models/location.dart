/// Location model aligned with docs/api/DATA_MODELS.md.

import 'dart:convert';

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

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'city': city,
        'country': country,
        'timezone': timezone,
      };

  String toJsonString() => json.encode(toJson());

  factory Location.fromJsonString(String source) =>
      Location.fromJson(json.decode(source));
}

class LocationSearchResult {
  const LocationSearchResult({
    required this.name,
    required this.region,
    required this.country,
    required this.lat,
    required this.lon,
    this.url,
  });

  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;
  final String? url;

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    return LocationSearchResult(
      name: json['name'] as String? ?? '',
      region: json['region'] as String? ?? '',
      country: json['country'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      url: json['url'] as String?,
    );
  }
}

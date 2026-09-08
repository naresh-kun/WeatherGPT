/// WeatherGPT — Location Service
/// Device GPS and geocoding integration.
library;

import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the device's current GPS coordinates, or null if unavailable.
  /// Handles permission requests internally.
  Future<Map<String, double>?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return {'lat': position.latitude, 'lon': position.longitude};
    } catch (_) {
      return null;
    }
  }
}

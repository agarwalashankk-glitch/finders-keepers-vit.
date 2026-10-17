import 'dart:math';
import '../constants/campus_locations.dart';

class FuzzyLocation {
  // Radius of Earth in meters
  static const double _earthRadiusMeters = 6371000.0;

  /// Applies a controlled approximate offset (fuzzing) to a coordinate.
  /// Generates a coordinate displaced by [approxRadiusMeters] (default 65m)
  /// in a deterministic or pseudo-random direction.
  /// This prevents exact dorm room or pin-point tracking.
  static ({double lat, double lng}) applyPrivacyOffset({
    required double latitude,
    required double longitude,
    double approxRadiusMeters = 65.0,
    int? seed,
  }) {
    final random = seed != null ? Random(seed) : Random();
    
    // Random angle between 0 and 2*pi
    final double angle = random.nextDouble() * 2 * pi;
    // Distance uniformly distributed up to approxRadiusMeters
    final double distance = (0.3 + (0.7 * random.nextDouble())) * approxRadiusMeters;

    // Convert distance in meters to delta latitude and delta longitude
    final double deltaLat = (distance * cos(angle)) / 111111.0;
    final double deltaLng = (distance * sin(angle)) / (111111.0 * cos(latitude * pi / 180.0));

    return (
      lat: double.parse((latitude + deltaLat).toStringAsFixed(5)),
      lng: double.parse((longitude + deltaLng).toStringAsFixed(5)),
    );
  }

  /// Calculates the Haversine distance in meters between two coordinates
  static double distanceBetweenMeters(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLng = (lng2 - lng1) * (pi / 180.0);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  /// Finds the closest named CampusZone to given coordinates
  static CampusZone findNearestZone(double lat, double lng) {
    CampusZone nearest = CampusLocations.zones.first;
    double minDistance = double.infinity;

    for (final zone in CampusLocations.zones) {
      final dist = distanceBetweenMeters(lat, lng, zone.latitude, zone.longitude);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = zone;
      }
    }
    return nearest;
  }
}

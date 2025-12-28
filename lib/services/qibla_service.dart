import 'dart:math';
import 'package:geolocator/geolocator.dart';

class QiblaService {
  // Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla direction from current position
  /// Returns bearing in degrees (0-360, where 0 is North)
  static double calculateQiblaDirection(double latitude, double longitude) {
    // Convert to radians
    final lat1 = latitude * pi / 180;
    final lon1 = longitude * pi / 180;
    final lat2 = kaabaLatitude * pi / 180;
    final lon2 = kaabaLongitude * pi / 180;

    // Calculate bearing using Haversine formula
    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    
    var bearing = atan2(y, x);
    bearing = bearing * 180 / pi; // Convert to degrees
    bearing = (bearing + 360) % 360; // Normalize to 0-360

    return bearing;
  }

  /// Calculate distance to Kaaba in kilometers
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      kaabaLatitude,
      kaabaLongitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm >= 1000) {
      return '${(distanceKm / 1000).toStringAsFixed(1)} ribu km';
    } else {
      return '${distanceKm.toStringAsFixed(0)} km';
    }
  }
}

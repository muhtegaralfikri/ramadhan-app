import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class FalakService {
  // Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Convert DMS (Degrees, Minutes, Seconds) to Decimal Degrees
  static double dmsToDecimal({
    required int degrees,
    required int minutes,
    required double seconds,
    required bool isNegative, // true for South latitude or West longitude
  }) {
    double decimal = degrees.abs() + (minutes / 60) + (seconds / 3600);
    return isNegative ? -decimal : decimal;
  }

  /// Convert Decimal Degrees to DMS
  static Map<String, dynamic> decimalToDms(double decimal) {
    final isNegative = decimal < 0;
    decimal = decimal.abs();
    final degrees = decimal.floor();
    final minutesDecimal = (decimal - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;
    
    return {
      'degrees': degrees,
      'minutes': minutes,
      'seconds': seconds,
      'isNegative': isNegative,
    };
  }

  /// Calculate Qibla direction from a location
  static double calculateQiblaDirection(double latitude, double longitude) {
    // Debug input values
    debugPrint('--- Qibla Calculation ---');
    debugPrint('Input Lat: $latitude, Lon: $longitude');
    debugPrint('Kaaba Lat: $kaabaLatitude, Lon: $kaabaLongitude');
    
    final lat1 = latitude * math.pi / 180;
    final lon1 = longitude * math.pi / 180;
    final lat2 = kaabaLatitude * math.pi / 180;
    final lon2 = kaabaLongitude * math.pi / 180;

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    
    debugPrint('dLon: ${dLon * 180 / math.pi}°, y: $y, x: $x');
    
    var bearing = math.atan2(y, x);
    bearing = bearing * 180 / math.pi;
    bearing = (bearing + 360) % 360;

    debugPrint('Final Qibla bearing: $bearing°');
    debugPrint('-------------------------');
    
    return bearing;
  }

  /// Calculate Julian Day Number
  static double calculateJulianDay(DateTime dateTime) {
    int year = dateTime.year;
    int month = dateTime.month;
    int day = dateTime.day;
    double hour = dateTime.hour + dateTime.minute / 60 + dateTime.second / 3600;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();

    double jd = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        hour / 24 +
        b -
        1524.5;

    return jd;
  }

  /// Calculate Sun's position (Declination and Equation of Time)
  static Map<String, double> calculateSunPosition(DateTime dateTime) {
    final jd = calculateJulianDay(dateTime);
    final t = (jd - 2451545.0) / 36525; // Julian centuries from J2000.0

    // Mean longitude of the Sun
    double l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    l0 = l0 % 360;

    // Mean anomaly of the Sun
    double m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
    m = m % 360;
    final mRad = m * math.pi / 180;

    // Eccentricity of Earth's orbit
    final e = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t;

    // Sun's equation of center
    final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(mRad) +
        (0.019993 - 0.000101 * t) * math.sin(2 * mRad) +
        0.000289 * math.sin(3 * mRad);

    // Sun's true longitude
    double sunLong = l0 + c;
    sunLong = sunLong % 360;
    final sunLongRad = sunLong * math.pi / 180;

    // Obliquity of the ecliptic
    final obliquity = 23.439291 - 0.0130042 * t;
    final obliquityRad = obliquity * math.pi / 180;

    // Sun's declination
    final declination = math.asin(math.sin(obliquityRad) * math.sin(sunLongRad)) * 180 / math.pi;

    // Equation of Time (in minutes)
    final y = math.tan(obliquityRad / 2) * math.tan(obliquityRad / 2);
    final eqTime = 4 * 180 / math.pi * (
        y * math.sin(2 * l0 * math.pi / 180) -
        2 * e * math.sin(mRad) +
        4 * e * y * math.sin(mRad) * math.cos(2 * l0 * math.pi / 180) -
        0.5 * y * y * math.sin(4 * l0 * math.pi / 180) -
        1.25 * e * e * math.sin(2 * mRad)
    );

    return {
      'declination': declination,
      'equationOfTime': eqTime,
    };
  }

  /// Calculate Sun's Azimuth at a given time and location
  static double calculateSunAzimuth({
    required double latitude,
    required double longitude,
    required DateTime dateTime,
    required double timezoneOffset, // in hours
  }) {
    final sunPos = calculateSunPosition(dateTime);
    final declination = sunPos['declination']! * math.pi / 180;
    final eqTime = sunPos['equationOfTime']!;

    // Local time in hours
    final localTime = dateTime.hour + dateTime.minute / 60 + dateTime.second / 3600;
    
    // Solar time
    final solarTime = localTime + eqTime / 60 + (longitude / 15) - timezoneOffset;
    
    // Hour angle
    final hourAngle = (solarTime - 12) * 15 * math.pi / 180;

    final latRad = latitude * math.pi / 180;

    // Solar altitude
    final sinAlt = math.sin(latRad) * math.sin(declination) +
        math.cos(latRad) * math.cos(declination) * math.cos(hourAngle);
    final altitude = math.asin(sinAlt);

    // Solar azimuth
    final cosAz = (math.sin(declination) - math.sin(latRad) * math.sin(altitude)) /
        (math.cos(latRad) * math.cos(altitude));
    
    double azimuth = math.acos(cosAz.clamp(-1.0, 1.0)) * 180 / math.pi;
    
    if (hourAngle > 0) {
      azimuth = 360 - azimuth;
    }

    return azimuth;
  }

  /// Calculate shadow direction (opposite of sun azimuth)
  static double calculateShadowDirection(double sunAzimuth) {
    return (sunAzimuth + 180) % 360;
  }

  /// Find the time when shadow points to Qibla (Rashdul Qiblat)
  static Map<String, dynamic>? findRashdulQiblat({
    required double latitude,
    required double longitude,
    required DateTime date,
    required double timezoneOffset,
  }) {
    final qiblaDirection = calculateQiblaDirection(latitude, longitude);
    
    // Shadow should point to Qibla, so Sun should be opposite
    final targetSunAzimuth = (qiblaDirection + 180) % 360;

    // Search through the day in 1-minute intervals
    // Start from 7:00 to 17:00 (daylight hours)
    double? bestDiff;
    Map<String, dynamic>? bestResult;
    
    for (int hour = 7; hour < 17; hour++) {
      for (int minute = 0; minute < 60; minute++) {
        final testTime = DateTime(date.year, date.month, date.day, hour, minute);
        
        // Calculate sun position
        final sunPos = calculateSunPosition(testTime);
        final declination = sunPos['declination']! * math.pi / 180;
        final eqTime = sunPos['equationOfTime']!;
        
        final localTime = hour + minute / 60;
        final solarTime = localTime + eqTime / 60 + (longitude / 15) - timezoneOffset;
        final hourAngle = (solarTime - 12) * 15 * math.pi / 180;
        final latRad = latitude * math.pi / 180;
        
        // Check if sun is above horizon
        final sinAlt = math.sin(latRad) * math.sin(declination) +
            math.cos(latRad) * math.cos(declination) * math.cos(hourAngle);
        
        if (sinAlt <= 0.1) continue; // Skip if sun is too low
        
        final sunAzimuth = calculateSunAzimuth(
          latitude: latitude,
          longitude: longitude,
          dateTime: testTime,
          timezoneOffset: timezoneOffset,
        );

        // Calculate difference to target
        double diff = (sunAzimuth - targetSunAzimuth).abs();
        if (diff > 180) diff = 360 - diff;
        
        // Find the closest match
        if (bestDiff == null || diff < bestDiff) {
          bestDiff = diff;
          bestResult = {
            'time': testTime,
            'sunAzimuth': sunAzimuth,
            'shadowDirection': calculateShadowDirection(sunAzimuth),
            'difference': diff,
          };
        }
      }
    }

    // Only return if difference is less than 2 degrees
    if (bestResult != null && bestDiff != null && bestDiff < 2.0) {
      return bestResult;
    }
    
    return null;
  }

  /// Calculate all Falak data for a given position and time
  static Map<String, dynamic> calculateFalakData({
    required double latitude,
    required double longitude,
    required DateTime dateTime,
    required double timezoneOffset,
  }) {
    final qiblaDirection = calculateQiblaDirection(latitude, longitude);
    final sunAzimuth = calculateSunAzimuth(
      latitude: latitude,
      longitude: longitude,
      dateTime: dateTime,
      timezoneOffset: timezoneOffset,
    );
    final shadowDirection = calculateShadowDirection(sunAzimuth);
    final sunPos = calculateSunPosition(dateTime);

    // Find validity period - when sun/shadow direction changes more than 5 degrees
    final validUntil = _findValidityTime(
      latitude: latitude,
      longitude: longitude,
      startTime: dateTime,
      timezoneOffset: timezoneOffset,
      initialSunAzimuth: sunAzimuth,
      maxDifference: 5.0, // 5 degrees tolerance
    );

    String validityInfo = '';
    if (validUntil != null) {
      validityInfo = 'Berlaku hingga pukul ${_formatTime(validUntil)}';
    } else {
      validityInfo = 'Berlaku untuk waktu yang dipilih';
    }

    return {
      'qiblaDirection': qiblaDirection,
      'sunAzimuth': sunAzimuth,
      'shadowDirection': shadowDirection,
      'declination': sunPos['declination'],
      'equationOfTime': sunPos['equationOfTime'],
      'validityInfo': validityInfo,
      'validUntil': validUntil,
    };
  }

  /// Find when the calculation expires (sun moves more than maxDifference degrees)
  static DateTime? _findValidityTime({
    required double latitude,
    required double longitude,
    required DateTime startTime,
    required double timezoneOffset,
    required double initialSunAzimuth,
    required double maxDifference,
  }) {
    // Check every 5 minutes for up to 20 minutes
    for (int minutes = 5; minutes <= 20; minutes += 5) {
      final checkTime = startTime.add(Duration(minutes: minutes));
      
      // Don't go past midnight or before sunrise/after sunset
      if (checkTime.hour < 6 || checkTime.hour >= 18) {
        return checkTime;
      }
      
      final newSunAzimuth = calculateSunAzimuth(
        latitude: latitude,
        longitude: longitude,
        dateTime: checkTime,
        timezoneOffset: timezoneOffset,
      );
      
      double diff = (newSunAzimuth - initialSunAzimuth).abs();
      if (diff > 180) diff = 360 - diff;
      
      if (diff >= maxDifference) {
        return checkTime;
      }
    }
    
    // Default to 20 minutes if within tolerance
    return startTime.add(const Duration(minutes: 20));
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Format direction to compass point
  static String formatDirection(double degrees) {
    const directions = [
      'U', 'UTL', 'TL', 'TTL', 'T', 'TGR', 'GR', 'SGR',
      'S', 'SBD', 'BD', 'BBD', 'B', 'BBL', 'BL', 'UBL'
    ];
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return '${degrees.toStringAsFixed(1)}° ${directions[index]}';
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimesService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  /// Fetch prayer times for a specific date and location
  /// Method 20 = Kementerian Agama Indonesia
  Future<PrayerTimes?> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      final url = Uri.parse(
        '$_baseUrl/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=20',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final timings = data['data']['timings'];
          return PrayerTimes(
            subuh: _formatTime(timings['Fajr']),
            dzuhur: _formatTime(timings['Dhuhr']),
            ashar: _formatTime(timings['Asr']),
            maghrib: _formatTime(timings['Maghrib']),
            isya: _formatTime(timings['Isha']),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Format time string (remove timezone info if present)
  String _formatTime(String time) {
    // Aladhan returns "HH:MM (TZ)" format, we only need "HH:MM"
    if (time.contains(' ')) {
      return time.split(' ').first;
    }
    return time;
  }
}

class PrayerTimes {
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  PrayerTimes({
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  List<Map<String, String>> toList() {
    return [
      {'name': 'Subuh', 'time': subuh, 'icon': 'morning'},
      {'name': 'Dzuhur', 'time': dzuhur, 'icon': 'sunny'},
      {'name': 'Ashar', 'time': ashar, 'icon': 'afternoon'},
      {'name': 'Maghrib', 'time': maghrib, 'icon': 'evening'},
      {'name': 'Isya', 'time': isya, 'icon': 'night'},
    ];
  }
}

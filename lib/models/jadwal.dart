class JadwalSholat {
  final String id;
  final DateTime date;
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String? location;

  JadwalSholat({
    required this.id,
    required this.date,
    required this.subuh,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'subuh': subuh,
      'dzuhur': dzuhur,
      'ashar': ashar,
      'maghrib': maghrib,
      'isya': isya,
      'location': location,
    };
  }

  factory JadwalSholat.fromJson(Map<String, dynamic> json) {
    return JadwalSholat(
      id: json['id'],
      date: DateTime.parse(json['date']),
      subuh: json['subuh'],
      dzuhur: json['dzuhur'],
      ashar: json['ashar'],
      maghrib: json['maghrib'],
      isya: json['isya'],
      location: json['location'],
    );
  }
}

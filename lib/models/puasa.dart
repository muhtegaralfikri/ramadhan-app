class Puasa {
  final String id;
  final DateTime date;
  final bool isFasting;
  final String? type; // ramadan, sunnah, qadha
  final String? note;

  Puasa({
    required this.id,
    required this.date,
    required this.isFasting,
    this.type,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'is_fasting': isFasting,
      'type': type,
      'note': note,
    };
  }

  factory Puasa.fromJson(Map<String, dynamic> json) {
    return Puasa(
      id: json['id'],
      date: DateTime.parse(json['date']),
      isFasting: json['is_fasting'],
      type: json['type'],
      note: json['note'],
    );
  }
}

class PuasaSummary {
  final int totalDays;
  final int completedDays;
  final double progress;

  PuasaSummary({
    required this.totalDays,
    required this.completedDays,
    required this.progress,
  });
}

class TarawihSchedule {
  final String id;
  final int ramadanDay;
  final String? imamName;
  final String? startTime;
  final int rakaat;
  final String? notes;
  final DateTime createdAt;

  TarawihSchedule({
    required this.id,
    required this.ramadanDay,
    this.imamName,
    this.startTime,
    this.rakaat = 20,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ramadan_day': ramadanDay,
      'imam_name': imamName,
      'start_time': startTime,
      'rakaat': rakaat,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TarawihSchedule.fromJson(Map<String, dynamic> json) {
    return TarawihSchedule(
      id: json['id'],
      ramadanDay: json['ramadan_day'],
      imamName: json['imam_name'],
      startTime: json['start_time'],
      rakaat: json['rakaat'] ?? 20,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

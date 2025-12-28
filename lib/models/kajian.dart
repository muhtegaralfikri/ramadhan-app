class Kajian {
  final String id;
  final String title;
  final String? speaker;
  final DateTime date;
  final String? time;
  final String? location;
  final String? description;
  final DateTime createdAt;

  Kajian({
    required this.id,
    required this.title,
    this.speaker,
    required this.date,
    this.time,
    this.location,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'speaker': speaker,
      'date': date.toIso8601String().split('T').first,
      'time': time,
      'location': location,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Kajian.fromJson(Map<String, dynamic> json) {
    return Kajian(
      id: json['id'],
      title: json['title'],
      speaker: json['speaker'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

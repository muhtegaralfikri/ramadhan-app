class TakjilDonor {
  final String id;
  final String donorName;
  final int ramadanDay;
  final String? description;
  final String? contact;
  final DateTime createdAt;

  TakjilDonor({
    required this.id,
    required this.donorName,
    required this.ramadanDay,
    this.description,
    this.contact,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donor_name': donorName,
      'ramadan_day': ramadanDay,
      'description': description,
      'contact': contact,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TakjilDonor.fromJson(Map<String, dynamic> json) {
    return TakjilDonor(
      id: json['id'],
      donorName: json['donor_name'],
      ramadanDay: json['ramadan_day'],
      description: json['description'],
      contact: json['contact'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

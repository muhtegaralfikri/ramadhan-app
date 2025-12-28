class Infaq {
  final String id;
  final double amount;
  final String? donorName;
  final String? message;
  final DateTime createdAt;

  Infaq({
    required this.id,
    required this.amount,
    this.donorName,
    this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'donor_name': donorName,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Infaq.fromJson(Map<String, dynamic> json) {
    return Infaq(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      donorName: json['donor_name'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class InfaqTarget {
  final String id;
  final double targetAmount;
  final String? description;
  final int year;
  final bool isActive;

  InfaqTarget({
    required this.id,
    required this.targetAmount,
    this.description,
    required this.year,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_amount': targetAmount,
      'description': description,
      'year': year,
      'is_active': isActive,
    };
  }

  factory InfaqTarget.fromJson(Map<String, dynamic> json) {
    return InfaqTarget(
      id: json['id'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      description: json['description'],
      year: json['year'],
      isActive: json['is_active'] ?? true,
    );
  }
}

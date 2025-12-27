class Zakat {
  final String id;
  final double amount;
  final String type; // maal, fitrah
  final DateTime date;
  final String? note;

  Zakat({
    required this.id,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Zakat.fromJson(Map<String, dynamic> json) {
    return Zakat(
      id: json['id'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }
}

class ZakatCalculator {
  static double calculateZakatMaal(double totalWealth) {
    return totalWealth * 0.025; // 2.5%
  }

  static double calculateZakatFitrah({required double ricePriceKg}) {
    return ricePriceKg * 2.5; // 2.5 kg per orang
  }
}

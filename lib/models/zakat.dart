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
      // 'id': id, // ID tidak perlu dikirim (auto-generate oleh database)
      'amount': amount,
      'type': type,
      'date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}", // Format: YYYY-MM-DD
      'note': note,
    };
  }

  factory Zakat.fromJson(Map<String, dynamic> json) {
    return Zakat(
      id: json['id']?.toString() ?? '', // Supabase ID is integer, convert to string
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] ?? 'maal',
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

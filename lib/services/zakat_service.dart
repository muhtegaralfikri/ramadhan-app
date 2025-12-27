import '../config/supabase_config.dart';
import '../models/zakat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ZakatService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'zakat';

  Future<List<Zakat>> getAllZakat() async {
    final response = await _client.from(_tableName).select().order('date', ascending: false);
    return response.map((json) => Zakat.fromJson(json)).toList();
  }

  Future<void> addZakat(Zakat zakat) async {
    await _client.from(_tableName).insert(zakat.toJson());
  }

  Future<void> updateZakat(Zakat zakat) async {
    await _client.from(_tableName).update(zakat.toJson()).eq('id', zakat.id);
  }

  Future<void> deleteZakat(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  Future<double> getTotalZakatMaal() async {
    final response = await _client
        .from(_tableName)
        .select('amount')
        .eq('type', 'maal');
    final total = response.fold<double>(0, (sum, item) => sum + (item['amount'] as double));
    return total;
  }
}

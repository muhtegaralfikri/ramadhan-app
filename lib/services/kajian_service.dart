import '../config/supabase_config.dart';
import '../models/kajian.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KajianService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'kajian';

  /// Get all kajian ordered by date
  Future<List<Kajian>> getAllKajian() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('date', ascending: true);
    return response.map((json) => Kajian.fromJson(json)).toList();
  }

  /// Get upcoming kajian (from today onwards)
  Future<List<Kajian>> getUpcomingKajian() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final response = await _client
        .from(_tableName)
        .select()
        .gte('date', today)
        .order('date', ascending: true)
        .limit(10);
    return response.map((json) => Kajian.fromJson(json)).toList();
  }

  /// Add kajian
  Future<void> addKajian(Kajian kajian) async {
    await _client.from(_tableName).insert(kajian.toJson());
  }

  /// Update kajian
  Future<void> updateKajian(Kajian kajian) async {
    await _client.from(_tableName).update(kajian.toJson()).eq('id', kajian.id);
  }

  /// Delete kajian
  Future<void> deleteKajian(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

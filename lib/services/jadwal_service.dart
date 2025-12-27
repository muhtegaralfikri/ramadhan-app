import '../config/supabase_config.dart';
import '../models/jadwal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JadwalService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'jadwal_sholat';

  Future<JadwalSholat?> getJadwalByDate(DateTime date) async {
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final response = await _client
        .from(_tableName)
        .select()
        .eq('date', dateStr)
        .maybeSingle();
    
    if (response == null) return null;
    return JadwalSholat.fromJson(response);
  }

  Future<void> addJadwal(JadwalSholat jadwal) async {
    await _client.from(_tableName).insert(jadwal.toJson());
  }

  Future<List<JadwalSholat>> getJadwalByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0).toIso8601String();
    
    final response = await _client
        .from(_tableName)
        .select()
        .gte('date', startDate)
        .lte('date', endDate)
        .order('date', ascending: true);
    
    return response.map((json) => JadwalSholat.fromJson(json)).toList();
  }
}

import '../config/supabase_config.dart';
import '../models/puasa.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PuasaService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'puasa';

  Future<List<Puasa>> getAllPuasa() async {
    final response = await _client.from(_tableName).select().order('date', ascending: false);
    return response.map((json) => Puasa.fromJson(json)).toList();
  }

  Future<List<Puasa>> getPuasaByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    final response = await _client
        .from(_tableName)
        .select()
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date', ascending: true);
    
    return response.map((json) => Puasa.fromJson(json)).toList();
  }

  Future<void> addPuasa(Puasa puasa) async {
    await _client.from(_tableName).insert(puasa.toJson());
  }

  Future<void> updatePuasa(Puasa puasa) async {
    await _client.from(_tableName).update(puasa.toJson()).eq('id', puasa.id);
  }

  Future<void> deletePuasa(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  Future<PuasaSummary> getPuasaSummary(int year, int month) async {
    final puasaList = await getPuasaByMonth(year, month);
    final completedDays = puasaList.where((p) => p.isFasting).length;
    
    return PuasaSummary(
      totalDays: 30,
      completedDays: completedDays,
      progress: completedDays / 30,
    );
  }
}

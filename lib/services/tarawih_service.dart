import '../config/supabase_config.dart';
import '../models/tarawih_schedule.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TarawihService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'tarawih_schedule';

  /// Get all tarawih schedules ordered by ramadan day
  Future<List<TarawihSchedule>> getAllSchedules() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('ramadan_day', ascending: true);
    return response.map((json) => TarawihSchedule.fromJson(json)).toList();
  }

  /// Get schedule for a specific day
  Future<TarawihSchedule?> getScheduleByDay(int ramadanDay) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('ramadan_day', ramadanDay)
        .maybeSingle();
    
    if (response == null) return null;
    return TarawihSchedule.fromJson(response);
  }

  /// Get schedules grouped by day
  Future<Map<int, TarawihSchedule>> getSchedulesMap() async {
    final allSchedules = await getAllSchedules();
    return {for (var s in allSchedules) s.ramadanDay: s};
  }

  /// Add or update schedule
  Future<void> upsertSchedule(TarawihSchedule schedule) async {
    await _client.from(_tableName).upsert(schedule.toJson());
  }

  /// Delete schedule
  Future<void> deleteSchedule(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

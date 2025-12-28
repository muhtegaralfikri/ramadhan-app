import '../config/supabase_config.dart';
import '../models/takjil_donor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TakjilService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'takjil_donors';

  /// Get all takjil donors ordered by ramadan day
  Future<List<TakjilDonor>> getAllDonors() async {
    final response = await _client
        .from(_tableName)
        .select()
        .order('ramadan_day', ascending: true)
        .order('created_at', ascending: true);
    return response.map((json) => TakjilDonor.fromJson(json)).toList();
  }

  /// Get donors for a specific ramadan day
  Future<List<TakjilDonor>> getDonorsByDay(int ramadanDay) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('ramadan_day', ramadanDay)
        .order('created_at', ascending: true);
    return response.map((json) => TakjilDonor.fromJson(json)).toList();
  }

  /// Get today's donors based on current Ramadan day
  /// Returns empty list if not in Ramadan or no donors
  Future<List<TakjilDonor>> getTodayDonors(int currentRamadanDay) async {
    if (currentRamadanDay < 1 || currentRamadanDay > 30) {
      return [];
    }
    return getDonorsByDay(currentRamadanDay);
  }

  /// Get donors grouped by day (for list display)
  Future<Map<int, List<TakjilDonor>>> getDonorsGroupedByDay() async {
    final allDonors = await getAllDonors();
    final Map<int, List<TakjilDonor>> grouped = {};
    
    for (var donor in allDonors) {
      if (!grouped.containsKey(donor.ramadanDay)) {
        grouped[donor.ramadanDay] = [];
      }
      grouped[donor.ramadanDay]!.add(donor);
    }
    
    return grouped;
  }

  /// Add a new donor
  Future<void> addDonor(TakjilDonor donor) async {
    await _client.from(_tableName).insert(donor.toJson());
  }

  /// Update an existing donor
  Future<void> updateDonor(TakjilDonor donor) async {
    await _client.from(_tableName).update(donor.toJson()).eq('id', donor.id);
  }

  /// Delete a donor
  Future<void> deleteDonor(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

import '../config/supabase_config.dart';
import '../models/infaq.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InfaqService {
  final SupabaseClient _client = SupabaseConfig.client;

  /// Get all infaq donations
  Future<List<Infaq>> getAllInfaq() async {
    final response = await _client
        .from('infaq')
        .select()
        .order('created_at', ascending: false);
    return response.map((json) => Infaq.fromJson(json)).toList();
  }

  /// Get total collected amount
  Future<double> getTotalCollected() async {
    final response = await _client.from('infaq').select('amount');
    double total = 0;
    for (var row in response) {
      total += (row['amount'] as num).toDouble();
    }
    return total;
  }

  /// Get active target
  Future<InfaqTarget?> getActiveTarget() async {
    final response = await _client
        .from('infaq_target')
        .select()
        .eq('is_active', true)
        .maybeSingle();
    
    if (response == null) return null;
    return InfaqTarget.fromJson(response);
  }

  /// Get progress (collected vs target)
  Future<Map<String, dynamic>> getProgress() async {
    final collected = await getTotalCollected();
    final target = await getActiveTarget();
    
    return {
      'collected': collected,
      'target': target?.targetAmount ?? 0,
      'description': target?.description,
      'percentage': target != null && target.targetAmount > 0 
          ? (collected / target.targetAmount * 100).clamp(0, 100) 
          : 0,
    };
  }

  /// Add infaq donation
  Future<void> addInfaq(Infaq infaq) async {
    await _client.from('infaq').insert(infaq.toJson());
  }

  /// Set target
  Future<void> setTarget(InfaqTarget target) async {
    // Deactivate existing targets
    await _client.from('infaq_target').update({'is_active': false}).eq('is_active', true);
    // Insert new target
    await _client.from('infaq_target').insert(target.toJson());
  }
}

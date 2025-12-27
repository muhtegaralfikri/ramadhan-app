import '../config/supabase_config.dart';
import '../models/menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuService {
  final SupabaseClient _client = SupabaseConfig.client;
  static const String _tableName = 'menu_buka';

  Future<List<MenuBuka>> getAllMenus() async {
    final response = await _client.from(_tableName).select().order('date', ascending: true);
    return response.map((json) => MenuBuka.fromJson(json)).toList();
  }

  Future<List<MenuBuka>> getMenusByDate(DateTime date) async {
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();
    final response = await _client
        .from(_tableName)
        .select()
        .gte('date', dateStr)
        .order('date', ascending: true);
    
    return response.map((json) => MenuBuka.fromJson(json)).toList();
  }

  Future<void> addMenu(MenuBuka menu) async {
    await _client.from(_tableName).insert(menu.toJson());
  }

  Future<void> updateMenu(MenuBuka menu) async {
    await _client.from(_tableName).update(menu.toJson()).eq('id', menu.id);
  }

  Future<void> deleteMenu(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}

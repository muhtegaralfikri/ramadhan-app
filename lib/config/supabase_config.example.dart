import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Ganti dengan Supabase URL dan Anon Key dari project kamu
  static String get supabaseUrl => 'YOUR_SUPABASE_URL_HERE';
  static String get supabaseAnonKey => 'YOUR_SUPABASE_ANON_KEY_HERE';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

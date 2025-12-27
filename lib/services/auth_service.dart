import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Check if user is logged in
  bool get isLoggedIn => _client.auth.currentUser != null;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Login admin
  Future<Map<String, dynamic>> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {'success': true, 'message': 'Login berhasil'};
      } else {
        return {'success': false, 'message': 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Email atau password salah'};
    }
  }

  // Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // Get auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}

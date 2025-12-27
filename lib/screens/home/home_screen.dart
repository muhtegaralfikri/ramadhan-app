import 'package:flutter/material.dart';
import '../zakat/zakat_list_screen.dart';
import '../auth/login_screen.dart';
import '../jadwal/jadwal_screen.dart';
import '../menu_buka/menu_screen.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback onLoginSuccess;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.isAdmin,
    required this.onLoginSuccess,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  Future<void> _handleLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    if (result == true) {
      widget.onLoginSuccess();
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _authService.logout();
      widget.onLogout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil logout')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Dashboard Admin' : 'Masjid App', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            )
          else
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              onPressed: _handleLogin,
              tooltip: 'Login Admin',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Assalamu\'alaikum',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    widget.isAdmin
                        ? 'Selamat datang, Admin'
                        : 'Aplikasi Transparansi Masjid',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
              if (widget.isAdmin) ...[
                _buildMenuCard(
                  context,
                  'Pencatatan Zakat',
                  'Kelola data zakat jamaah',
                  Icons.monetization_on,
                  Colors.green,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ZakatListScreen(
                      isAdmin: true,
                    )),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildMenuCard(
                context,
                'Total Zakat',
                'Lihat total zakat diterima',
                Icons.account_balance_wallet,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ZakatListScreen(
                    isAdmin: false,
                  )),
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                'Jadwal Sholat',
                'Jadwal sholat harian',
                Icons.access_time,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JadwalScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                'Menu Buka',
                'Info menu buka puasa masjid',
                Icons.restaurant,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

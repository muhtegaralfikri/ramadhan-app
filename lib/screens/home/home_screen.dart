import 'package:flutter/material.dart';
import '../zakat/zakat_list_screen.dart';
import '../puasa/puasa_screen.dart';
import '../jadwal/jadwal_screen.dart';
import '../menu_buka/menu_screen.dart';
import '../../models/zakat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Zakat> _zakatList = [];

  void _handleZakatSaved(Zakat zakat) {
    setState(() {
      _zakatList.add(zakat);
    });
  }

  void _handleZakatEdited(Zakat zakat) {
    // Implement edit logic jika needed
  }

  void _handleZakatDeleted(String id) {
    setState(() {
      _zakatList.removeWhere((z) => z.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramadan App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: Text(
                    'Selamat datang di Aplikasi Ramadan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Pencatatan Zakat',
                'Catat zakat jamaah masjid',
                Icons.monetization_on,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ZakatListScreen(
                    zakatList: _zakatList,
                    onEdit: _handleZakatEdited,
                    onDelete: _handleZakatDeleted,
                    onAdd: _handleZakatSaved,
                  )),
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuCard(
                context,
                'Puasa Tracker',
                'Track puasa Ramadan dan sunnah',
                Icons.calendar_today,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PuasaScreen()),
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
                        color: Colors.grey[600],
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

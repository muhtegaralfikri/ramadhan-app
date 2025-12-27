import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  final List<Map<String, dynamic>> _menus = const [
    {
      'name': 'Masjid Al-Ikhlas',
      'address': 'Jl. Sudirman No. 123',
      'menu': 'Nasi Bungkus, Es Teh',
      'time': '18:00',
      'capacity': 50,
      'icon': Icons.mosque,
      'color': Colors.green,
    },
    {
      'name': 'Musholla Al-Huda',
      'address': 'Jl. Ahmad Yani No. 45',
      'menu': 'Kolak, Kurma, Air Mineral',
      'time': '17:45',
      'capacity': 30,
      'icon': Icons.home_work,
      'color': Colors.blue,
    },
    {
      'name': 'Posko Buka Puasa RW 05',
      'address': 'Jl. Melati No. 10',
      'menu': 'Gorengan, Bubur',
      'time': '18:00',
      'capacity': 100,
      'icon': Icons.location_city,
      'color': Colors.orange,
    },
    {
      'name': 'Rumah Ustadz Ahmad',
      'address': 'Jl. Kenanga No. 7',
      'menu': 'Takjil Lengkap',
      'time': '17:30',
      'capacity': 20,
      'icon': Icons.house,
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Buka Puasa', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _menus.length,
        itemBuilder: (context, index) {
          final menu = _menus[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 4,
            child: InkWell(
              onTap: () {
                _showMenuDetail(context, menu);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (menu['color'] as Color).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        menu['icon'] as IconData,
                        color: menu['color'] as Color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu['name'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            menu['address'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                menu['time'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.people, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${menu['capacity']} porsi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
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
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur tambah lokasi akan segera hadir!')),
          );
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add_location),
        label: const Text('Tambah Lokasi'),
      ),
    );
  }

  void _showMenuDetail(BuildContext context, Map<String, dynamic> menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (menu['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                menu['icon'] as IconData,
                color: menu['color'] as Color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                menu['name'] as String,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.location_on, 'Alamat', menu['address'] as String),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.restaurant, 'Menu', menu['menu'] as String),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Waktu', menu['time'] as String),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.people, 'Kuota', '${menu['capacity']} porsi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('QR Code ${menu['name']} akan ditampilkan!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Scan QR'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

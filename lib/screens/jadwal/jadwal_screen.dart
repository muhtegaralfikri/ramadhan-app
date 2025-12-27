import 'package:flutter/material.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _jadwalSholat = [
    {'name': 'Subuh', 'time': '04:30', 'icon': 'morning'},
    {'name': 'Dzuhur', 'time': '12:00', 'icon': 'sunny'},
    {'name': 'Ashar', 'time': '15:30', 'icon': 'afternoon'},
    {'name': 'Maghrib', 'time': '18:15', 'icon': 'evening'},
    {'name': 'Isya', 'time': '19:30', 'icon': 'night'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Tanggal',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          });
                        },
                      ),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _selectedDate = _selectedDate.add(const Duration(days: 1));
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jakarta, Indonesia',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _jadwalSholat.length,
              itemBuilder: (context, index) {
                final jadwal = _jadwalSholat[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getIcon(jadwal['icon']!),
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              jadwal['name']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          jadwal['time']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur notifikasi akan segera hadir!')),
          );
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.notifications),
        label: const Text('Set Notifikasi'),
      ),
    );
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'morning':
        return Icons.wb_twilight;
      case 'sunny':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_sunny_outlined;
      case 'evening':
        return Icons.nights_stay;
      case 'night':
        return Icons.bedtime;
      default:
        return Icons.access_time;
    }
  }
}

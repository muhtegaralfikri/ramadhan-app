import 'package:flutter/material.dart';

class PuasaScreen extends StatefulWidget {
  const PuasaScreen({super.key});

  @override
  State<PuasaScreen> createState() => _PuasaScreenState();
}

class _PuasaScreenState extends State<PuasaScreen> {
  final Map<int, bool> _puasaDays = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Puasa', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Total Hari', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        '30',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Selesai', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        '${_puasaDays.values.where((v) => v).length}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Progress', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        '${((_puasaDays.values.where((v) => v).length / 30) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 30,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isFasting = _puasaDays[day] ?? false;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isFasting ? Colors.green : Colors.grey.shade300,
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isFasting ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    title: Text('Hari ke-$day'),
                    trailing: Switch(
                      value: isFasting,
                      onChanged: (value) {
                        setState(() {
                          _puasaDays[day] = value;
                        });
                      },
                      activeTrackColor: Colors.green.shade200,
                      activeThumbColor: Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur riwayat akan segera hadir!')),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.history),
      ),
    );
  }
}

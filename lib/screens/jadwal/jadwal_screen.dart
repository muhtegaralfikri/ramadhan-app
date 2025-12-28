import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/prayer_times_service.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _selectedDate = DateTime.now();
  
  final LocationService _locationService = LocationService();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  
  bool _isLoading = true;
  String _locationName = 'Memuat lokasi...';
  String? _errorMessage;
  Position? _currentPosition;
  List<Map<String, String>> _jadwalSholat = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current position
      final position = await _locationService.getCurrentPosition();
      
      if (position == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tidak dapat mengakses lokasi. Pastikan GPS aktif dan izin lokasi diberikan.';
        });
        return;
      }

      _currentPosition = position;

      // Get city name
      final cityName = await _locationService.getCityName(
        position.latitude,
        position.longitude,
      );

      // Get prayer times
      await _fetchPrayerTimes();

      setState(() {
        _locationName = cityName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  Future<void> _fetchPrayerTimes() async {
    if (_currentPosition == null) return;

    final prayerTimes = await _prayerTimesService.getPrayerTimes(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      date: _selectedDate,
    );

    if (prayerTimes != null) {
      setState(() {
        _jadwalSholat = prayerTimes.toList();
      });
    } else {
      setState(() {
        _errorMessage = 'Gagal memuat jadwal sholat. Periksa koneksi internet.';
      });
    }
  }

  void _changeDate(int days) async {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _isLoading = true;
    });
    await _fetchPrayerTimes();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
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
                        onPressed: _isLoading ? null : () => _changeDate(-1),
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
                        onPressed: _isLoading ? null : () => _changeDate(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _locationName,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!_isLoading && _errorMessage == null)
                        IconButton(
                          icon: Icon(Icons.refresh, size: 16, color: Colors.grey[600]),
                          onPressed: _initLocation,
                          tooltip: 'Refresh lokasi',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildContent(),
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat jadwal sholat...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _locationService.openLocationSettings(),
                child: const Text('Buka Pengaturan Lokasi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_jadwalSholat.isEmpty) {
      return const Center(
        child: Text('Tidak ada data jadwal'),
      );
    }

    return ListView.builder(
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

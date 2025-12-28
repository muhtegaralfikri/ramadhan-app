import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../theme/app_theme.dart';
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
      final position = await _locationService.getCurrentPosition();
      
      if (position == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tidak dapat mengakses lokasi. Pastikan GPS aktif dan izin lokasi diberikan.';
        });
        return;
      }

      _currentPosition = position;

      final cityName = await _locationService.getCityName(
        position.latitude,
        position.longitude,
      );

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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildLoadingState(),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildDateSelector(),
                  _buildPrayerTimesList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _buildGradientFAB(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1976D2),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.white,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _JadwalPatternPainter(),
                ),
              ),
              // Decorative circles
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.1),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Hero(
                          tag: 'hero_jadwal_icon',
                          child: Icon(
                            Icons.access_time_filled_rounded,
                            size: 40,
                            color: AppColors.white,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 12),
                      Text(
                        'Jadwal Sholat',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 8),
                      // Location badge
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: AppColors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _locationName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.white.withValues(alpha: 0.9),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!_isLoading && _errorMessage == null)
                              GestureDetector(
                                onTap: _initLocation,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.refresh_rounded,
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Previous button
            _buildDateButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _changeDate(-1),
            ),
            // Date display
            Expanded(
              child: Column(
                children: [
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Hari Ini',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Next button
            _buildDateButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _changeDate(1),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildDateButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }

  Widget _buildPrayerTimesList() {
    if (_jadwalSholat.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text('Tidak ada data jadwal'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_jadwalSholat.length, (index) {
          final jadwal = _jadwalSholat[index];
          return _buildPrayerCard(jadwal, index);
        }),
      ),
    );
  }

  Widget _buildPrayerCard(Map<String, String> jadwal, int index) {
    final prayerColors = _getPrayerColors(jadwal['icon'] ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: prayerColors['primary']!.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: prayerColors['primary']!.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon with gradient
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    prayerColors['primary']!,
                    prayerColors['secondary']!,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: prayerColors['primary']!.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getIcon(jadwal['icon'] ?? ''),
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Prayer name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jadwal['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getPrayerDescription(jadwal['icon'] ?? ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: prayerColors['primary']!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                jadwal['time'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: prayerColors['primary'],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (500 + index * 80).ms).slideX(begin: 0.05);
  }

  Map<String, Color> _getPrayerColors(String iconType) {
    switch (iconType) {
      case 'morning': // Subuh
        return {'primary': const Color(0xFF5C6BC0), 'secondary': const Color(0xFF3949AB)};
      case 'sunny': // Dzuhur
        return {'primary': AppColors.gold, 'secondary': AppColors.goldLight};
      case 'afternoon': // Ashar
        return {'primary': const Color(0xFFFF7043), 'secondary': const Color(0xFFFF5722)};
      case 'evening': // Maghrib
        return {'primary': const Color(0xFFEC407A), 'secondary': const Color(0xFFD81B60)};
      case 'night': // Isya
        return {'primary': const Color(0xFF7E57C2), 'secondary': const Color(0xFF5E35B1)};
      default:
        return {'primary': AppColors.primary, 'secondary': AppColors.primaryLight};
    }
  }

  String _getPrayerDescription(String iconType) {
    switch (iconType) {
      case 'morning':
        return 'Waktu fajar menyingsing';
      case 'sunny':
        return 'Matahari di zenith';
      case 'afternoon':
        return 'Bayangan sama panjang';
      case 'evening':
        return 'Matahari terbenam';
      case 'night':
        return 'Mega merah menghilang';
      default:
        return '';
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Memuat jadwal sholat...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withValues(alpha: 0.1),
                    AppColors.error.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _initLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: AppColors.white, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Coba Lagi',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _locationService.openLocationSettings(),
              child: Text(
                'Buka Pengaturan Lokasi',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Fitur notifikasi akan segera hadir!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_rounded, color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Set Notifikasi',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8));
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

// Pattern Painter for header overlay
class _JadwalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;
    
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - 8)
          ..lineTo(x + 8, y)
          ..lineTo(x, y + 8)
          ..lineTo(x - 8, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

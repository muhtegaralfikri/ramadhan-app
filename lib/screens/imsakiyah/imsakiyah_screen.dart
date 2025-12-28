import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../services/prayer_times_service.dart';
import '../../services/location_service.dart';
import '../../services/hijri_service.dart';
import 'package:intl/intl.dart';

class ImsakiyahScreen extends StatefulWidget {
  const ImsakiyahScreen({super.key});

  @override
  State<ImsakiyahScreen> createState() => _ImsakiyahScreenState();
}

class _ImsakiyahScreenState extends State<ImsakiyahScreen> {
  final PrayerTimesService _prayerService = PrayerTimesService();
  final LocationService _locationService = LocationService();
  
  List<Map<String, dynamic>> _scheduleData = [];
  bool _isLoading = true;
  String _locationName = 'Memuat...';
  int _currentRamadanDay = 0;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get location name
      final locationName = await _locationService.getCityName(position.latitude, position.longitude);

      // Calculate Ramadan dates
      // For demo: use current year's approximate Ramadan dates
      // In production: calculate from Hijri calendar
      final now = DateTime.now();
      final hijriNow = HijriService.gregorianToHijri(now);
      
      // Find first day of Ramadan this year (approximate)
      DateTime ramadanStart;
      if (hijriNow.month <= 9) {
        // Before or during Ramadan this Hijri year
        ramadanStart = HijriService.hijriToGregorian(hijriNow.year, 9, 1);
      } else {
        // After Ramadan, show next year
        ramadanStart = HijriService.hijriToGregorian(hijriNow.year + 1, 9, 1);
      }

      // Check current Ramadan day
      int currentDay = 0;
      if (hijriNow.month == 9 && hijriNow.day >= 1 && hijriNow.day <= 30) {
        currentDay = hijriNow.day;
      }

      // Load 30 days of prayer times
      List<Map<String, dynamic>> schedule = [];
      for (int day = 1; day <= 30; day++) {
        final date = ramadanStart.add(Duration(days: day - 1));
        final prayerTimes = await _prayerService.getPrayerTimes(
          latitude: position.latitude,
          longitude: position.longitude,
          date: date,
        );

        if (prayerTimes != null) {
          // Calculate imsak (10 minutes before subuh)
          final subuhParts = prayerTimes.subuh.split(':');
          final subuhMinutes = int.parse(subuhParts[0]) * 60 + int.parse(subuhParts[1]);
          final imsakMinutes = subuhMinutes - 10;
          final imsakTime = '${(imsakMinutes ~/ 60).toString().padLeft(2, '0')}:${(imsakMinutes % 60).toString().padLeft(2, '0')}';

          schedule.add({
            'day': day,
            'date': date,
            'imsak': imsakTime,
            'subuh': prayerTimes.subuh,
            'maghrib': prayerTimes.maghrib,
          });
        }
      }

      if (mounted) {
        setState(() {
          _scheduleData = schedule;
          _locationName = locationName;
          _currentRamadanDay = currentDay;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverToBoxAdapter(
              child: _buildScheduleTable(),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1565C0),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          ),
        ).animate().fadeIn(delay: 100.ms),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern
              Positioned.fill(
                child: CustomPaint(painter: _ImsakPatternPainter()),
              ),
              // Content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Hero(
                          tag: 'hero_imsakiyah_icon',
                          child: Icon(
                            Icons.calendar_view_month_rounded,
                            size: 36,
                            color: AppColors.white,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 12),
                      const Text(
                        'Jadwal Imsakiyah',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 4),
                      Text(
                        _locationName,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.white.withValues(alpha: 0.8),
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

  Widget _buildScheduleTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Hari', flex: 1),
                _buildHeaderCell('Tanggal', flex: 2),
                _buildHeaderCell('Imsak', flex: 2),
                _buildHeaderCell('Subuh', flex: 2),
                _buildHeaderCell('Berbuka', flex: 2),
              ],
            ),
          ),
          // Data Rows
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: _scheduleData.map((data) {
                final isToday = data['day'] == _currentRamadanDay;
                return _buildDataRow(data, isToday);
              }).toList(),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataRow(Map<String, dynamic> data, bool isToday) {
    final date = data['date'] as DateTime;
    final dateFormat = DateFormat('d MMM', 'id_ID');
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF1565C0).withValues(alpha: 0.1) : null,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          left: isToday ? const BorderSide(color: Color(0xFF1565C0), width: 3) : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(
            '${data['day']}',
            flex: 1,
            isHighlight: isToday,
            isBold: true,
          ),
          _buildDataCell(dateFormat.format(date), flex: 2),
          _buildDataCell(data['imsak'], flex: 2, color: const Color(0xFF6A1B9A)),
          _buildDataCell(data['subuh'], flex: 2, color: const Color(0xFF1565C0)),
          _buildDataCell(data['maghrib'], flex: 2, color: const Color(0xFFE65100)),
        ],
      ),
    ).animate().fadeIn(delay: (300 + data['day'] * 20).ms);
  }

  Widget _buildDataCell(String text, {
    int flex = 1,
    bool isHighlight = false,
    bool isBold = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: color ?? (isHighlight ? const Color(0xFF1565C0) : AppColors.textPrimary),
          fontSize: 12,
          fontWeight: (isBold || isHighlight) ? FontWeight.w600 : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ImsakPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

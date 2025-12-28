import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ramadan_app/constants/app_colors.dart';
import 'package:ramadan_app/services/location_service.dart';
import 'package:ramadan_app/services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  
  double? _qiblaDirection;
  double? _currentHeading;
  double _distanceToKaaba = 0;
  String _locationName = 'Mencari lokasi...';
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasCompass = false;

  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initQibla() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if compass is available
      _hasCompass = await FlutterCompass.events != null;

      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        setState(() {
          _errorMessage = 'Tidak dapat mengakses lokasi';
          _isLoading = false;
        });
        return;
      }

      // Get location name
      final cityName = await _locationService.getCityName(position.latitude, position.longitude);
      
      // Calculate Qibla direction
      final qiblaDir = QiblaService.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      // Calculate distance
      final distance = QiblaService.calculateDistanceToKaaba(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _qiblaDirection = qiblaDir;
        _distanceToKaaba = distance;
        _locationName = cityName ?? 'Lokasi tidak diketahui';
        _isLoading = false;
      });

      // Start listening to compass
      if (_hasCompass) {
        _compassSubscription = FlutterCompass.events?.listen((event) {
          if (mounted && event.heading != null) {
            setState(() {
              _currentHeading = event.heading;
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _buildCompassContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFE65100),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE65100), Color(0xFFFF9800)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _QiblaPatternPainter(),
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
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE65100).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'hero_qibla_icon',
                          child: Icon(
                            Icons.explore_rounded,
                            size: 40,
                            color: AppColors.white,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 12),
                      Text(
                        'Kompas Kiblat',
                        style: const TextStyle(
                          fontSize: 24,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Mencari arah kiblat...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initQibla,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Compass Widget
          _buildCompass(),
          const SizedBox(height: 32),
          // Info Cards
          _buildInfoCards(),
          const SizedBox(height: 20),
          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    final qiblaAngle = _qiblaDirection ?? 0;
    final heading = _currentHeading ?? 0;
    final rotationAngle = -(heading * math.pi / 180);
    final qiblaIndicatorAngle = ((qiblaAngle - heading) * math.pi / 180);

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.surface,
            AppColors.background,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass Rose (rotates with heading)
          Transform.rotate(
            angle: rotationAngle,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _CompassPainter(),
            ),
          ),
          // Qibla Indicator (fixed position relative to Qibla)
          Transform.rotate(
            angle: qiblaIndicatorAngle,
            child: Container(
              width: 260,
              height: 260,
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFFF9800)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE65100).withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFE65100),
                            const Color(0xFFE65100).withValues(alpha: 0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE65100),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE65100).withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.navigation_rounded,
            label: 'Arah Kiblat',
            value: '${_qiblaDirection?.toStringAsFixed(1) ?? '-'}°',
            color: const Color(0xFFE65100),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.place_rounded,
            label: 'Jarak ke Kaaba',
            value: QiblaService.formatDistance(_distanceToKaaba),
            color: const Color(0xFF00897B),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE65100).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE65100).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFFE65100),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hasCompass
                  ? 'Putar perangkat perlahan hingga ikon masjid berada di atas'
                  : 'Perangkat tidak memiliki sensor kompas',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}

// Custom Painters
class _QiblaPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final spacing = 30.0;
    for (var i = 0.0; i < size.width + spacing; i += spacing) {
      for (var j = 0.0; j < size.height + spacing; j += spacing) {
        canvas.drawCircle(Offset(i, j), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw outer circle
    final outerPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);

    // Draw cardinal directions
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final directionColors = [
      const Color(0xFFE65100), // North - Orange
      Colors.grey.shade600,
      Colors.grey.shade600,
      Colors.grey.shade600,
    ];

    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      final x = center.dx + (radius - 25) * math.cos(angle);
      final y = center.dy + (radius - 25) * math.sin(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: directionColors[i],
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw tick marks
    for (var i = 0; i < 360; i += 15) {
      final angle = (i - 90) * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 45 == 0;
      
      final tickLength = isCardinal ? 0 : (isMajor ? 12 : 6);
      final tickWidth = isMajor ? 2.0 : 1.0;
      
      if (tickLength > 0) {
        final startX = center.dx + (radius - 5) * math.cos(angle);
        final startY = center.dy + (radius - 5) * math.sin(angle);
        final endX = center.dx + (radius - 5 - tickLength) * math.cos(angle);
        final endY = center.dy + (radius - 5 - tickLength) * math.sin(angle);

        final tickPaint = Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = tickWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

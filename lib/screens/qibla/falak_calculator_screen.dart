import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:ramadan_app/constants/app_colors.dart';
import 'package:ramadan_app/services/falak_service.dart';
import 'package:ramadan_app/services/location_service.dart';

class FalakCalculatorScreen extends StatefulWidget {
  const FalakCalculatorScreen({super.key});

  @override
  State<FalakCalculatorScreen> createState() => _FalakCalculatorScreenState();
}

class _FalakCalculatorScreenState extends State<FalakCalculatorScreen> {
  // Latitude input
  int _latDegrees = 0;
  int _latMinutes = 0;
  double _latSeconds = 0;
  bool _isLatSouth = true; // true = Selatan, false = Utara

  // Longitude input
  int _lngDegrees = 0;
  int _lngMinutes = 0;
  double _lngSeconds = 0;
  bool _isLngWest = false; // true = Barat, false = Timur

  // Date and Time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Results
  Map<String, dynamic>? _results;
  bool _isCalculating = false;

  // Controllers
  final _latDegController = TextEditingController();
  final _latMinController = TextEditingController();
  final _latSecController = TextEditingController();
  final _lngDegController = TextEditingController();
  final _lngMinController = TextEditingController();
  final _lngSecController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _useCurrentTime();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _latDegController.dispose();
    _latMinController.dispose();
    _latSecController.dispose();
    _lngDegController.dispose();
    _lngMinController.dispose();
    _lngSecController.dispose();
    super.dispose();
  }

  void _useCurrentTime() {
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }

  Future<void> _loadCurrentLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();
    
    if (position != null && mounted) {
      // Convert latitude to DMS
      final latDms = FalakService.decimalToDms(position.latitude);
      _latDegrees = latDms['degrees'] as int;
      _latMinutes = latDms['minutes'] as int;
      _latSeconds = latDms['seconds'] as double;
      _isLatSouth = latDms['isNegative'] as bool;

      // Convert longitude to DMS
      final lngDms = FalakService.decimalToDms(position.longitude);
      _lngDegrees = lngDms['degrees'] as int;
      _lngMinutes = lngDms['minutes'] as int;
      _lngSeconds = lngDms['seconds'] as double;
      _isLngWest = lngDms['isNegative'] as bool;

      // Update controllers
      _latDegController.text = _latDegrees.toString();
      _latMinController.text = _latMinutes.toString();
      _latSecController.text = _latSeconds.toStringAsFixed(2);
      _lngDegController.text = _lngDegrees.toString();
      _lngMinController.text = _lngMinutes.toString();
      _lngSecController.text = _lngSeconds.toStringAsFixed(2);

      setState(() {});
    }
  }

  /// Detect timezone based on longitude for Indonesia
  /// WIB (UTC+7): 95°-115° E (Sumatra, Java, West/Central Kalimantan)
  /// WITA (UTC+8): 115°-135° E (East/South Kalimantan, Sulawesi, Bali, NTT, NTB)
  /// WIT (UTC+9): 135°-141° E (Maluku, Papua)
  int _detectTimezone(double longitude) {
    if (longitude < 115) {
      return 7; // WIB
    } else if (longitude < 135) {
      return 8; // WITA
    } else {
      return 9; // WIT
    }
  }

  String _getTimezoneLabel(int offset) {
    switch (offset) {
      case 7:
        return 'WIB';
      case 8:
        return 'WITA';
      case 9:
        return 'WIT';
      default:
        return 'UTC+$offset';
    }
  }

  void _calculatePosition() {
    setState(() => _isCalculating = true);

    // Convert DMS to decimal
    final latitude = FalakService.dmsToDecimal(
      degrees: _latDegrees,
      minutes: _latMinutes,
      seconds: _latSeconds,
      isNegative: _isLatSouth,
    );

    final longitude = FalakService.dmsToDecimal(
      degrees: _lngDegrees,
      minutes: _lngMinutes,
      seconds: _lngSeconds,
      isNegative: _isLngWest,
    );

    // Detect timezone based on longitude
    final timezoneOffset = _detectTimezone(longitude.abs());

    // Combine date and time
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Calculate Falak data with detected timezone
    final results = FalakService.calculateFalakData(
      latitude: latitude,
      longitude: longitude,
      dateTime: dateTime,
      timezoneOffset: timezoneOffset.toDouble(),
    );

    setState(() {
      _results = results;
      _isCalculating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Latitude Input
                  _buildSectionTitle('Lintang Tempat', Icons.north_rounded),
                  const SizedBox(height: 12),
                  _buildLatitudeInput(),
                  const SizedBox(height: 24),

                  // Longitude Input
                  _buildSectionTitle('Bujur Tempat', Icons.east_rounded),
                  const SizedBox(height: 12),
                  _buildLongitudeInput(),
                  const SizedBox(height: 24),

                  // Date & Time Input
                  _buildSectionTitle('Tanggal & Waktu', Icons.schedule_rounded),
                  const SizedBox(height: 12),
                  _buildDateTimeInput(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 32),

                  // Results
                  if (_results != null) _buildResults(),
                ],
              ),
            ),
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
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            ),
          ),
          child: SafeArea(
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
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      size: 40,
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 12),
                  Text(
                    'Kalkulator Ilmu Falak',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    'Hitung Arah Kiblat & Posisi Matahari',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLatitudeInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDMSField('Derajat', _latDegController, (v) => _latDegrees = int.tryParse(v) ?? 0, '°', max: 90)),
              const SizedBox(width: 8),
              Expanded(child: _buildDMSField('Menit', _latMinController, (v) => _latMinutes = int.tryParse(v) ?? 0, "'", max: 59)),
              const SizedBox(width: 8),
              Expanded(child: _buildDMSField('Detik', _latSecController, (v) => _latSeconds = double.tryParse(v) ?? 0, '"', isDecimal: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHemisphereButton(
                  'Utara (U)',
                  !_isLatSouth,
                  () => setState(() => _isLatSouth = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHemisphereButton(
                  'Selatan (S)',
                  _isLatSouth,
                  () => setState(() => _isLatSouth = true),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildLongitudeInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDMSField('Derajat', _lngDegController, (v) => _lngDegrees = int.tryParse(v) ?? 0, '°', max: 180)),
              const SizedBox(width: 8),
              Expanded(child: _buildDMSField('Menit', _lngMinController, (v) => _lngMinutes = int.tryParse(v) ?? 0, "'", max: 59)),
              const SizedBox(width: 8),
              Expanded(child: _buildDMSField('Detik', _lngSecController, (v) => _lngSeconds = double.tryParse(v) ?? 0, '"', isDecimal: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHemisphereButton(
                  'Timur (T)',
                  !_isLngWest,
                  () => setState(() => _isLngWest = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHemisphereButton(
                  'Barat (B)',
                  _isLngWest,
                  () => setState(() => _isLngWest = true),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildDMSField(
    String label,
    TextEditingController controller,
    Function(String) onChanged,
    String suffix, {
    int max = 59,
    bool isDecimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        filled: true,
        fillColor: AppColors.background,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildHemisphereButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            DateFormat('dd/MM/yy').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _selectedTime.format(context),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _useCurrentTime,
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Waktu Saat Ini'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1565C0),
                  side: const BorderSide(color: Color(0xFF1565C0)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCalculating ? null : _calculatePosition,
            icon: _isCalculating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.calculate_rounded),
            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung Posisi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildResults() {
    final qibla = _results!['qiblaDirection'] as double;
    final sunAzimuth = _results!['sunAzimuth'] as double;
    final shadow = _results!['shadowDirection'] as double;
    final validityInfo = _results!['validityInfo'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Hasil Perhitungan', Icons.analytics_rounded),
        const SizedBox(height: 16),
        
        // Compass Visualization
        _buildCompassVisualization(qibla, sunAzimuth, shadow),
        const SizedBox(height: 24),
        
        // Result Cards
        _buildResultCard(
          icon: Icons.mosque_rounded,
          label: 'Arah Kiblat',
          value: FalakService.formatDirection(qibla),
          color: const Color(0xFF4CAF50),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
        const SizedBox(height: 12),
        
        _buildResultCard(
          icon: Icons.wb_sunny_rounded,
          label: 'Arah Matahari',
          value: FalakService.formatDirection(sunAzimuth),
          color: const Color(0xFFF44336),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
        const SizedBox(height: 12),
        
        _buildResultCard(
          icon: Icons.arrow_downward_rounded,
          label: 'Arah Bayangan',
          value: FalakService.formatDirection(shadow),
          color: const Color(0xFFFF9800),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
        const SizedBox(height: 16),
        
        // Validity Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_rounded, color: Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  validityInfo,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildResultCard({
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassVisualization(double qibla, double sunAzimuth, double shadow) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF37474F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compass
          SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: _FalakCompassPainter(
                qiblaDirection: qibla,
                sunDirection: sunAzimuth,
                shadowDirection: shadow,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Matahari', const Color(0xFFF44336)),
              const SizedBox(width: 16),
              _buildLegendItem('Bayangan', const Color(0xFFFF9800)),
              const SizedBox(width: 16),
              _buildLegendItem('Kiblat', const Color(0xFF4CAF50)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FalakCompassPainter extends CustomPainter {
  final double qiblaDirection;
  final double sunDirection;
  final double shadowDirection;

  _FalakCompassPainter({
    required this.qiblaDirection,
    required this.sunDirection,
    required this.shadowDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw outer circle
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);

    // Draw inner circles
    final innerPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.7, innerPaint);
    canvas.drawCircle(center, radius * 0.4, innerPaint);

    // Draw tick marks and cardinal directions
    _drawTickMarks(canvas, center, radius);
    _drawCardinalDirections(canvas, center, radius);

    // Draw direction lines
    _drawDirectionLine(canvas, center, radius * 0.85, sunDirection, const Color(0xFFF44336), 3);
    _drawDirectionLine(canvas, center, radius * 0.85, shadowDirection, const Color(0xFFFF9800), 3);
    _drawDirectionLine(canvas, center, radius * 0.85, qiblaDirection, const Color(0xFF4CAF50), 3);

    // Draw center dot
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 5, centerPaint);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      
      final tickLength = isCardinal ? 15 : (isMajor ? 10 : 5);
      
      final startX = center.dx + radius * math.cos(angle);
      final startY = center.dy + radius * math.sin(angle);
      final endX = center.dx + (radius - tickLength) * math.cos(angle);
      final endY = center.dy + (radius - tickLength) * math.sin(angle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    final directions = ['N', 'E', 'S', 'W'];
    final positions = [
      Offset(center.dx - 6, center.dy - radius + 20),
      Offset(center.dx + radius - 30, center.dy - 6),
      Offset(center.dx - 5, center.dy + radius - 35),
      Offset(center.dx - radius + 18, center.dy - 6),
    ];

    for (int i = 0; i < 4; i++) {
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? Colors.white : Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, positions[i]);
    }
  }

  void _drawDirectionLine(Canvas canvas, Offset center, double length, double degrees, Color color, double width) {
    final angle = (degrees - 90) * math.pi / 180;
    final endX = center.dx + length * math.cos(angle);
    final endY = center.dy + length * math.sin(angle);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, Offset(endX, endY), linePaint);

    // Draw arrow head
    final arrowLength = 10.0;
    final arrowAngle = 0.5;
    final arrowX1 = endX - arrowLength * math.cos(angle - arrowAngle);
    final arrowY1 = endY - arrowLength * math.sin(angle - arrowAngle);
    final arrowX2 = endX - arrowLength * math.cos(angle + arrowAngle);
    final arrowY2 = endY - arrowLength * math.sin(angle + arrowAngle);

    final arrowPath = Path()
      ..moveTo(endX, endY)
      ..lineTo(arrowX1, arrowY1)
      ..lineTo(arrowX2, arrowY2)
      ..close();

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

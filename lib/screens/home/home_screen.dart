import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../zakat/zakat_list_screen.dart';
import '../auth/login_screen.dart';
import '../jadwal/jadwal_screen.dart';
import '../menu_buka/takjil_screen.dart';
import '../../services/takjil_service.dart';
import '../../services/hijri_service.dart';
import '../../models/takjil_donor.dart';
import '../masjid/profil_masjid_screen.dart';
import '../qibla/qibla_screen.dart';
import '../settings/reminder_settings_screen.dart';
import '../calendar/hijri_calendar_screen.dart';
import '../imsakiyah/imsakiyah_screen.dart';
import '../tarawih/tarawih_screen.dart';
import '../kajian/kajian_screen.dart';
import '../infaq/infaq_screen.dart';
import '../../services/auth_service.dart';
import '../../services/prayer_times_service.dart';
import '../../services/location_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final PrayerTimesService _prayerService = PrayerTimesService();
  final LocationService _locationService = LocationService();
  final TakjilService _takjilService = TakjilService();
  late bool _isAdmin;
  
  // Prayer time state
  String _nextPrayer = 'Maghrib';
  String _nextPrayerTime = '18:02';
  Duration _timeRemaining = const Duration(hours: 2, minutes: 15);
  Timer? _countdownTimer;
  
  // Takjil state
  List<TakjilDonor> _todayTakjilDonors = [];
  List<TakjilDonor> _tomorrowTakjilDonors = [];
  int _currentRamadanDay = 0;
  
  // Animation controllers
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.isAdmin;
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((data) {
      if (mounted) {
        setState(() {
          _isAdmin = data.session != null;
        });
      }
    });
    
    // Load prayer times and start countdown
    _loadPrayerTimes();
    _loadTakjilData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) return;
      
      final now = DateTime.now();
      
      final prayerTimes = await _prayerService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        date: now,
      );
      
      if (prayerTimes != null && mounted) {
        final prayers = prayerTimes.toList();
        bool foundNext = false;
        
        // Check today's prayers
        for (var prayer in prayers) {
          final time = prayer['time'];
          if (time != null) {
            final parts = time.split(':');
            final prayerDateTime = DateTime(
              now.year, now.month, now.day,
              int.parse(parts[0]), int.parse(parts[1]),
            );
            
            if (prayerDateTime.isAfter(now)) {
              setState(() {
                _nextPrayer = prayer['name'] ?? 'Maghrib';
                _nextPrayerTime = time;
                _timeRemaining = prayerDateTime.difference(now);
              });
              _startCountdown(prayerDateTime);
              foundNext = true;
              break;
            }
          }
        }
        
        // If all prayers today have passed, get tomorrow's Subuh
        if (!foundNext) {
          final tomorrow = now.add(const Duration(days: 1));
          final tomorrowPrayerTimes = await _prayerService.getPrayerTimes(
            latitude: position.latitude,
            longitude: position.longitude,
            date: tomorrow,
          );
          
          if (tomorrowPrayerTimes != null && mounted) {
            final subuhTime = tomorrowPrayerTimes.subuh;
            final parts = subuhTime.split(':');
            final subuhDateTime = DateTime(
              tomorrow.year, tomorrow.month, tomorrow.day,
              int.parse(parts[0]), int.parse(parts[1]),
            );
            
            setState(() {
              _nextPrayer = 'Subuh';
              _nextPrayerTime = subuhTime;
              _timeRemaining = subuhDateTime.difference(now);
            });
            _startCountdown(subuhDateTime);
          }
        }
      }
    } catch (e) {
      // Use default values
    }
  }

  Future<void> _loadTakjilData() async {
    try {
      final now = DateTime.now();
      final hijriDate = HijriService.gregorianToHijri(now);
      
      int displayDay;
      
      // Check if currently in Ramadan (month 9)
      if (hijriDate.month == 9 && hijriDate.day >= 1 && hijriDate.day <= 30) {
        displayDay = hijriDate.day;
      } else {
        // Outside Ramadan - use day 1 for demo/preview
        displayDay = 1;
      }
      
      final todayDonors = await _takjilService.getTodayDonors(displayDay);
      final tomorrowDay = displayDay < 30 ? displayDay + 1 : 1;
      final tomorrowDonors = await _takjilService.getTodayDonors(tomorrowDay);
      
      if (mounted) {
        setState(() {
          _currentRamadanDay = displayDay;
          _todayTakjilDonors = todayDonors;
          _tomorrowTakjilDonors = tomorrowDonors;
        });
      }
    } catch (e) {
      // Silently fail - takjil section just won't show
    }
  }

  void _startCountdown(DateTime targetTime) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(targetTime)) {
        timer.cancel();
        _loadPrayerTimes();
      } else {
        setState(() {
          _timeRemaining = targetTime.difference(now);
        });
      }
    });
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true) {
      setState(() {
        _isAdmin = true;
      });
      widget.onLoginSuccess();
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.allL),
        title: Text('Logout', style: AppTextStyles.titleLarge),
        content: Text('Apakah Anda yakin ingin logout?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: AppTextStyles.buttonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.allS),
            ),
            child: Text('Logout', style: AppTextStyles.buttonPrimary),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      widget.onLogout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil logout', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildPremiumHeader(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrayerCountdown(),
                _buildTakjilCard(),
                _buildSectionTitle('Layanan Utama'),
                _buildFeatureGrid(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1B5E20),
                AppColors.primary,
                const Color(0xFF2E7D32),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Islamic geometric pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: IslamicPatternPainter(),
                ),
              ),
              // Decorative circles
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        color: AppColors.gold,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now()),
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                                const SizedBox(height: 16),
                                // Greeting
                                Text(
                                  _isAdmin ? 'Assalamu\'alaikum, Admin' : 'Assalamu\'alaikum',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    height: 1.2,
                                  ),
                                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                                const SizedBox(height: 4),
                                Text(
                                  _isAdmin
                                      ? 'Kelola masjid dengan transparan'
                                      : 'Selamat datang di Masjid Al-Ikhlas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.white.withValues(alpha: 0.8),
                                    height: 1.4,
                                  ),
                                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildGlassProfileButton(),
                        ],
                      ),
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

  Widget _buildGlassProfileButton() {
    return GestureDetector(
      onTap: _isAdmin ? _handleLogout : _handleLogin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              _isAdmin ? Icons.logout_rounded : Icons.person_rounded,
              color: AppColors.white,
              size: 26,
            ),
          ),
        ),
      ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Widget _buildPrayerCountdown() {
    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Waktu Sholat Berikutnya',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Prayer name and countdown row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left - Prayer name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nextPrayer,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _nextPrayerTime,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // Right - Countdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Jam'),
                      _buildTimeSeparator(),
                      _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Mnt'),
                      _buildTimeSeparator(),
                      _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Dtk'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1 + (_pulseController.value * 0.05)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            );
          },
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.6),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          color: AppColors.white.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTakjilCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5E35B1).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Donatur Takjil',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Today's donors
            _buildDonorSection(
              title: 'Hari ini${_currentRamadanDay > 0 ? " (Hari ke-$_currentRamadanDay)" : ""}',
              donors: _todayTakjilDonors,
              isToday: true,
            ),
            
            const SizedBox(height: 16),
            
            // Divider
            Container(
              height: 1,
              color: AppColors.white.withValues(alpha: 0.15),
            ),
            
            const SizedBox(height: 16),
            
            // Tomorrow's donors
            _buildDonorSection(
              title: 'Besok${_currentRamadanDay > 0 && _currentRamadanDay < 30 ? " (Hari ke-${_currentRamadanDay + 1})" : ""}',
              donors: _tomorrowTakjilDonors,
              isToday: false,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildDonorSection({
    required String title,
    required List<TakjilDonor> donors,
    required bool isToday,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isToday ? Icons.today_rounded : Icons.event_rounded,
              color: isToday ? AppColors.gold : AppColors.white.withValues(alpha: 0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isToday ? AppColors.gold : AppColors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (donors.isEmpty)
          Text(
            'Belum ada donatur terdaftar',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: donors.map((donor) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isToday 
                    ? AppColors.white.withValues(alpha: 0.25)
                    : AppColors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isToday 
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : AppColors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_rounded,
                    color: isToday ? AppColors.gold : AppColors.white.withValues(alpha: 0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    donor.donorName,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.gold],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.1);
  }

  Widget _buildFeatureGrid() {
    final features = [
      _FeatureItem(
        title: _isAdmin ? 'Pencatatan Zakat' : 'Laporan Zakat',
        subtitle: _isAdmin ? 'Kelola donasi & zakat' : 'Transparansi keuangan',
        icon: _isAdmin ? Icons.payments_rounded : Icons.account_balance_wallet_rounded,
        gradient: _isAdmin 
            ? [const Color(0xFF43A047), const Color(0xFF66BB6A)]
            : [const Color(0xFF00897B), const Color(0xFF26A69A)],
        onTap: () {},
        page: ZakatListScreen(isAdmin: _isAdmin),
        heroTag: 'hero_zakat',
      ),
      _FeatureItem(
        title: 'Jadwal Sholat',
        subtitle: 'Waktu sholat hari ini',
        icon: Icons.schedule_rounded,
        gradient: [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
        onTap: () {},
        page: const JadwalScreen(),
        heroTag: 'hero_jadwal_icon',
      ),
      _FeatureItem(
        title: 'Jadwal Takjil',
        subtitle: 'Donatur buka puasa',
        icon: Icons.restaurant_rounded,
        gradient: [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
        onTap: () {},
        page: const TakjilScreen(),
        heroTag: 'hero_menu_icon',
      ),
      _FeatureItem(
        title: 'Imsakiyah',
        subtitle: 'Jadwal puasa sebulan',
        icon: Icons.calendar_view_month_rounded,
        gradient: [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
        onTap: () {},
        page: const ImsakiyahScreen(),
        heroTag: 'hero_imsakiyah_icon',
      ),
      _FeatureItem(
        title: 'Jadwal Tarawih',
        subtitle: 'Info imam & waktu',
        icon: Icons.nights_stay_rounded,
        gradient: [const Color(0xFF00695C), const Color(0xFF00897B)],
        onTap: () {},
        page: const TarawihScreen(),
        heroTag: 'hero_tarawih_icon',
      ),
      _FeatureItem(
        title: 'Jadwal Kajian',
        subtitle: 'Kultum & ceramah',
        icon: Icons.menu_book_rounded,
        gradient: [const Color(0xFF7B1FA2), const Color(0xFF9C27B0)],
        onTap: () {},
        page: const KajianScreen(),
        heroTag: 'hero_kajian_icon',
      ),
      _FeatureItem(
        title: 'Infaq Ramadan',
        subtitle: 'Progress donasi',
        icon: Icons.volunteer_activism_rounded,
        gradient: [const Color(0xFFB8962F), const Color(0xFFD4AF37)],
        onTap: () {},
        page: const InfaqScreen(),
        heroTag: 'hero_infaq_icon',
      ),
      _FeatureItem(
        title: 'Profil Masjid',
        subtitle: 'Info & fasilitas',
        icon: Icons.mosque_rounded,
        gradient: [const Color(0xFF455A64), const Color(0xFF607D8B)],
        onTap: () {},
        page: const ProfilMasjidScreen(),
        heroTag: 'hero_masjid_icon',
      ),
      _FeatureItem(
        title: 'Kompas Kiblat',
        subtitle: 'Arah kiblat akurat',
        icon: Icons.explore_rounded,
        gradient: [const Color(0xFFE65100), const Color(0xFFFF9800)],
        onTap: () {},
        page: const QiblaScreen(),
        heroTag: 'hero_qibla_icon',
      ),
      _FeatureItem(
        title: 'Pengingat',
        subtitle: 'Sahur & Berbuka',
        icon: Icons.notifications_active_rounded,
        gradient: [const Color(0xFF6D4C41), const Color(0xFF8D6E63)],
        onTap: () {},
        page: const ReminderSettingsScreen(),
        heroTag: 'hero_reminder_icon',
      ),
      _FeatureItem(
        title: 'Kalender Hijriah',
        subtitle: 'Tanggal & hari penting',
        icon: Icons.calendar_month_rounded,
        gradient: [const Color(0xFF6A1B9A), const Color(0xFF9C27B0)],
        onTap: () {},
        page: const HijriCalendarScreen(),
        heroTag: 'hero_hijri_icon',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Build rows of 2 cards each
          for (int i = 0; i < features.length; i += 2)
            Padding(
              padding: EdgeInsets.only(bottom: i + 2 < features.length ? 12 : 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPremiumFeatureCard(
                      feature: features[i],
                      delay: 1000 + (i * 50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < features.length
                        ? _buildPremiumFeatureCard(
                            feature: features[i + 1],
                            delay: 1050 + (i * 50),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWideFeatureCard({
    required _FeatureItem feature,
    required int delay,
  }) {
    return GestureDetector(
      onTap: feature.onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: feature.gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: feature.gradient.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Content - horizontal layout
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      feature.icon,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feature.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.subtitle,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1),
    );
  }

  Widget _buildPremiumFeatureCard({
    required _FeatureItem feature,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () => _navigateTo(feature.page),
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: feature.gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: feature.gradient.first.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Hero(
                        tag: feature.heroTag,
                        child: Icon(
                          feature.icon,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          feature.subtitle,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Arrow indicator
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        ),
      ).animate().fadeIn(delay: delay.ms).scale(
            begin: const Offset(0.9, 0.9),
            curve: Curves.easeOutBack,
          ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.page,
    required this.heroTag,
  });
  final Widget page;
  final String heroTag;
}

// Custom painter for Islamic geometric pattern
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final spacing = 40.0;
    
    for (var x = 0.0; x < size.width + spacing; x += spacing) {
      for (var y = 0.0; y < size.height + spacing; y += spacing) {
        // Draw simple geometric shapes
        canvas.drawCircle(Offset(x, y), 8, paint);
        
        // Draw connecting lines
        if (x + spacing <= size.width) {
          canvas.drawLine(
            Offset(x + 8, y),
            Offset(x + spacing - 8, y),
            paint,
          );
        }
        if (y + spacing <= size.height) {
          canvas.drawLine(
            Offset(x, y + 8),
            Offset(x, y + spacing - 8),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

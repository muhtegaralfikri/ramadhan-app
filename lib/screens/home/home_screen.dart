import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../zakat/zakat_list_screen.dart';
import '../auth/login_screen.dart';
import '../jadwal/jadwal_screen.dart';
import '../menu_buka/menu_screen.dart';
import '../puasa/puasa_screen.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

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
            content: Text('Berhasil logout', style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.darkGrey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingSection(),
                _buildStatsCard(),
                _buildFeatureGrid(),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: AppPadding.allL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.gold,
                                letterSpacing: 1.0,
                                fontSize: 12, // Smaller font to prevent overflow
                              ),
                            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                            const SizedBox(height: AppDimensions.spacingXS),
                            Text(
                              widget.isAdmin ? 'Halo, Admin 👋' : 'Assalamu\'alaikum 🤲',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1, // Reduce height to prevent overflow
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                          ],
                        ),
                      ),
                      _buildProfileButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: widget.isAdmin ? _handleLogout : _handleLogin,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
        ),
        child: Icon(
          widget.isAdmin ? Icons.logout_rounded : Icons.login_rounded,
          color: AppColors.white,
          size: 28,
        ),
      ).animate().fadeIn(delay: 300.ms).scale(),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: AppPadding.allL,
      child: Text(
        widget.isAdmin
            ? 'Kelola aktivitas masjid dengan transparansi dan akuntabilitas'
            : 'Pantau aktivitas dan transparansi keuangan masjid',
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textSecondary,
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: AppPadding.hL,
      child: Container(
        padding: AppPadding.allL,
        decoration: BoxDecoration(
          gradient: AppTheme.goldGradient,
          borderRadius: AppRadius.allL,
          boxShadow: AppTheme.cardShadowL,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('30', 'Hari Puasa', Icons.calendar_today_rounded),
                _buildStatItem('5', 'Jadwal Sholat', Icons.access_time_rounded),
                _buildStatItem('4', 'Menu Buka', Icons.restaurant_rounded),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2).then().shimmer(),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
              height: 1,
              fontSize: 24,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: AppPadding.hL,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.spacingM,
        crossAxisSpacing: AppDimensions.spacingM,
        childAspectRatio: 1.3,
        children: [
          if (widget.isAdmin)
            _buildFeatureCard(
              'Pencatatan Zakat',
              Icons.payments_rounded,
              AppColors.primary,
              () => _navigateTo(const ZakatListScreen(isAdmin: true)),
              delay: 600,
            ),
          _buildFeatureCard(
            'Total Zakat',
            Icons.account_balance_wallet_rounded,
            AppColors.teal,
            () => _navigateTo(const ZakatListScreen(isAdmin: false)),
            delay: 700,
          ),
          _buildFeatureCard(
            'Tracker Puasa',
            Icons.fact_check_rounded,
            AppColors.secondary,
            () => _navigateTo(const PuasaScreen()),
            delay: 800,
          ),
          _buildFeatureCard(
            'Jadwal Sholat',
            Icons.schedule_rounded,
            AppColors.info,
            () => _navigateTo(const JadwalScreen()),
            delay: 900,
          ),
          _buildFeatureCard(
            'Menu Buka',
            Icons.lunch_dining_rounded,
            AppColors.indigo,
            () => _navigateTo(const MenuScreen()),
            delay: 1000,
          ),
          _buildFeatureCard(
            'Profil Masjid',
            Icons.mosque_rounded,
            AppColors.goldDark,
            () {},
            delay: 1100,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    int delay = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.allL,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: AppPadding.allS,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingXS),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.allS,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: delay.ms).scale(),
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
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../home/home_screen.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    setState(() {
      _isAdmin = _authService.isLoggedIn;
    });
    _navigateToHome();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          isAdmin: _isAdmin,
          onLoginSuccess: () {},
          onLogout: () {},
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                _buildLogo(),
                const SizedBox(height: AppDimensions.spacingL),
                _buildAppName(),
                const SizedBox(height: AppDimensions.spacingS),
                _buildTagline(),
                const Spacer(),
                _buildLoadingIndicator(),
                const SizedBox(height: AppDimensions.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.mosque_outlined,
          size: 80,
          color: AppColors.white,
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              duration: 1000.ms,
              curve: Curves.easeInOut,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.05, 1.05),
            )
            .then()
            .scale(
              duration: 1000.ms,
              curve: Curves.easeInOut,
              begin: const Offset(1.05, 1.05),
              end: const Offset(1.0, 1.0),
            ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildAppName() {
    return Text(
      'Masjid App',
      style: AppTextStyles.displaySmall.copyWith(
        color: AppColors.white,
        fontWeight: FontWeight.w800,
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideX(begin: -0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTagline() {
    return Text(
      'Aplikasi Transparansi Masjid',
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.gold,
        letterSpacing: 1.0,
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideX(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1500.ms, curve: Curves.linear),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Text(
          'Loading...',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms),
      ],
    );
  }
}

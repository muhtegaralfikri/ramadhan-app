import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../theme/app_theme.dart';

class ProfilMasjidScreen extends StatelessWidget {
  const ProfilMasjidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMasjidHeader(),
                _buildInfoSection(),
                _buildFacilitiesSection(),
                _buildContactSection(),
                const SizedBox(height: AppDimensions.spacingXL),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.goldDark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.goldDark,
                AppColors.gold,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          'Profil Masjid',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildMasjidHeader() {
    return Container(
      margin: AppPadding.allL,
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadowL,
      ),
      child: Column(
        children: [
          Text(
            'Masjid Al-Ikhlas',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Melayani Umat dengan Kasih Sayang',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.allS,
            ),
            child: Text(
              'Didirikan tahun 1985',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: AppPadding.hL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Informasi Umum',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildInfoCard(
            icon: Icons.location_on_rounded,
            title: 'Alamat',
            content: 'Jl. Contoh No. 123, Kelurahan ABC\nKecamatan XYZ, Kota DEF 12345',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildInfoCard(
            icon: Icons.people_rounded,
            title: 'Jamaah',
            content: 'Kapasitas: ±500 jamaah\nRata-rata sholat Jumat: ±350 jamaah',
            color: AppColors.teal,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildInfoCard(
            icon: Icons.schedule_rounded,
            title: 'Jam Operasional',
            content: 'Buka 24 jam untuk ibadah\nSekretariat: 08:00 - 17:00 WIB',
            color: AppColors.info,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: AppPadding.allM,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.allS,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    final facilities = [
      {'icon': Icons.menu_book_rounded, 'name': 'Perpustakaan'},
      {'icon': Icons.school_rounded, 'name': 'TPA'},
      {'icon': Icons.local_parking_rounded, 'name': 'Parkir Luas'},
      {'icon': Icons.wc_rounded, 'name': 'Toilet Bersih'},
      {'icon': Icons.ac_unit_rounded, 'name': 'AC'},
      {'icon': Icons.wifi_rounded, 'name': 'WiFi Gratis'},
    ];

    return Padding(
      padding: AppPadding.allL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fasilitas',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
            children: facilities.map((facility) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.allS,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      facility['icon'] as IconData,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXS),
                    Text(
                      facility['name'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildContactSection() {
    return Padding(
      padding: AppPadding.hL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kontak & Sosial Media',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildContactCard(
            icon: Icons.phone_rounded,
            title: 'Telepon',
            content: '(021) 1234-5678',
            color: AppColors.success,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildContactCard(
            icon: Icons.email_rounded,
            title: 'Email',
            content: 'info@masjidalkhlas.org',
            color: AppColors.error,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Container(
            padding: AppPadding.allM,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.allL,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialIcon(Icons.facebook_rounded, AppColors.info),
                _buildSocialIcon(Icons.camera_alt_rounded, AppColors.error),
                _buildSocialIcon(Icons.play_circle_rounded, AppColors.error),
                _buildSocialIcon(Icons.send_rounded, AppColors.info),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: AppPadding.allM,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.allS,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                content,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

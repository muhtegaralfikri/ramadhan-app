import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../theme/app_theme.dart';

class ProfilMasjidScreen extends StatelessWidget {
  const ProfilMasjidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                const SizedBox(height: 40),
              ],
            ),
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
      backgroundColor: const Color(0xFF455A64),
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
              colors: [Color(0xFF455A64), Color(0xFF607D8B)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _MasjidPatternPainter(),
                ),
              ),
              // Decorative circles
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 150,
                  height: 150,
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
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Hero(
                          tag: 'hero_masjid_icon',
                          child: Icon(
                            Icons.mosque_rounded,
                            size: 36,
                            color: AppColors.white,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 12),
                      Text(
                        'Profil Masjid',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
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

  Widget _buildMasjidHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF455A64), Color(0xFF607D8B)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF455A64).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Masjid Al-Ikhlas',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Melayani Umat dengan Kasih Sayang',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Didirikan tahun 1985',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informasi Umum', Icons.info_rounded),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.location_on_rounded,
            title: 'Alamat',
            content: 'Jl. Contoh No. 123, Kelurahan ABC\nKecamatan XYZ, Kota DEF 12345',
            color: AppColors.primary,
            delay: 500,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.people_rounded,
            title: 'Jamaah',
            content: 'Kapasitas: ±500 jamaah\nRata-rata sholat Jumat: ±350 jamaah',
            color: AppColors.teal,
            delay: 600,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.schedule_rounded,
            title: 'Jam Operasional',
            content: 'Buka 24 jam untuk ibadah\nSekretariat: 08:00 - 17:00 WIB',
            color: AppColors.info,
            delay: 700,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.gold, AppColors.goldDark],
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
          ),
        ),
      ],
    ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1);
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.05);
  }

  Widget _buildFacilitiesSection() {
    final facilities = [
      {'icon': Icons.menu_book_rounded, 'name': 'Perpustakaan', 'color': AppColors.primary},
      {'icon': Icons.school_rounded, 'name': 'TPA', 'color': AppColors.gold},
      {'icon': Icons.local_parking_rounded, 'name': 'Parkir Luas', 'color': AppColors.teal},
      {'icon': Icons.wc_rounded, 'name': 'Toilet Bersih', 'color': AppColors.info},
      {'icon': Icons.ac_unit_rounded, 'name': 'AC', 'color': const Color(0xFF5C6BC0)},
      {'icon': Icons.wifi_rounded, 'name': 'WiFi Gratis', 'color': const Color(0xFF7E57C2)},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Fasilitas', Icons.check_circle_rounded),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: facilities.asMap().entries.map((entry) {
              final index = entry.key;
              final facility = entry.value;
              return _buildFacilityChip(
                icon: facility['icon'] as IconData,
                name: facility['name'] as String,
                color: facility['color'] as Color,
                delay: 800 + (index * 50),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip({
    required IconData icon,
    required String name,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Kontak & Sosial Media', Icons.contact_phone_rounded),
          const SizedBox(height: 16),
          _buildContactCard(
            icon: Icons.phone_rounded,
            title: 'Telepon',
            content: '(021) 1234-5678',
            color: AppColors.success,
            delay: 1100,
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.email_rounded,
            title: 'Email',
            content: 'info@masjidalkhlas.org',
            color: AppColors.error,
            delay: 1150,
          ),
          const SizedBox(height: 16),
          _buildSocialMediaRow(),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.05);
  }

  Widget _buildSocialMediaRow() {
    final socials = [
      {'icon': Icons.facebook_rounded, 'color': const Color(0xFF1877F2)},
      {'icon': Icons.camera_alt_rounded, 'color': const Color(0xFFE4405F)},
      {'icon': Icons.play_circle_rounded, 'color': const Color(0xFFFF0000)},
      {'icon': Icons.send_rounded, 'color': const Color(0xFF0088CC)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: socials.asMap().entries.map((entry) {
          final index = entry.key;
          final social = entry.value;
          return _buildSocialIcon(
            icon: social['icon'] as IconData,
            color: social['color'] as Color,
            delay: 1200 + (index * 50),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.1);
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(icon, color: color, size: 22),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

// Pattern Painter for header overlay
class _MasjidPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.04)
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

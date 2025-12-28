import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/zakat.dart';
import '../../services/zakat_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'zakat_screen.dart';

class ZakatListScreen extends StatefulWidget {
  final bool isAdmin;

  const ZakatListScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<ZakatListScreen> createState() => _ZakatListScreenState();
}

class _ZakatListScreenState extends State<ZakatListScreen> {
  final ZakatService _zakatService = ZakatService();
  List<Zakat> _zakatList = [];
  bool _isLoading = true;

  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadZakatData();
  }

  Future<void> _loadZakatData() async {
    try {
      final data = await _zakatService.getAllZakat();
      if (mounted) {
        setState(() {
          _zakatList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMaal = _zakatList
        .where((z) => z.type == 'maal')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final totalFitrah = _zakatList
        .where((z) => z.type == 'fitrah')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final totalZakat = totalMaal + totalFitrah;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(totalZakat),
          if (_isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildLoadingState(),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildChartSection(totalMaal, totalFitrah),
                  _buildZakatList(totalZakat),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? Container(
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
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const ZakatScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                    if (result != null) {
                      await _loadZakatData();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, color: AppColors.white, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Tambah Zakat',
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
            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8))
          : null,
    );
  }

  Widget _buildSliverAppBar(double totalZakat) {
    return SliverAppBar(
      expandedHeight: 220, // Increased height
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
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
            gradient: AppTheme.primaryGradient,
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _ZakatPatternPainter(),
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20), // Reduced top padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isAdmin ? Icons.edit_note_rounded : Icons.account_balance_wallet_rounded,
                              color: AppColors.gold,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isAdmin ? 'Admin Mode' : 'Laporan',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                      const SizedBox(height: 12),
                      Text(
                        widget.isAdmin ? 'Pencatatan Zakat' : 'Total Zakat', // Shortened text
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                      const SizedBox(height: 8),
                      Text(
                        _currencyFormatter.format(totalZakat),
                        style: TextStyle(
                          fontSize: 28, // Reduced font size
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
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

  Widget _buildChartSection(double totalMaal, double totalFitrah) {
    if (totalMaal == 0 && totalFitrah == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header with gradient accent
            Row(
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
                  'Distribusi Zakat',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _buildChartLegend(),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 55,
                  sections: [
                    PieChartSectionData(
                      value: totalMaal,
                      title: '${((totalMaal / (totalMaal + totalFitrah)) * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      color: AppColors.primary,
                      radius: 55,
                      badgeWidget: _buildChartBadge(Icons.monetization_on_rounded, AppColors.primary),
                      badgePositionPercentageOffset: 1.3,
                    ),
                    PieChartSectionData(
                      value: totalFitrah,
                      title: '${((totalFitrah / (totalMaal + totalFitrah)) * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      color: AppColors.gold,
                      radius: 55,
                      badgeWidget: _buildChartBadge(Icons.rice_bowl_rounded, AppColors.gold),
                      badgePositionPercentageOffset: 1.3,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 24),
            // Enhanced summary cards
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildPremiumSummaryCard('Zakat Maal', totalMaal, AppColors.primary, Icons.monetization_on_rounded),
                  ),
                  const SizedBox(width: 8), // Reduced gap
                  Expanded(
                    child: _buildPremiumSummaryCard('Zakat Fitrah', totalFitrah, AppColors.gold, Icons.rice_bowl_rounded),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildChartBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.white, size: 14),
    );
  }

  Widget _buildPremiumSummaryCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded( // Prevent overlap
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11, // Reduced font
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced height
          FittedBox( // Prevent overflow
            fit: BoxFit.scaleDown,
            child: Text(
              _currencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 15, // Reduced font
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(AppColors.primary, 'Maal'),
        const SizedBox(width: AppDimensions.spacingM),
        _buildLegendItem(AppColors.gold, 'Fitrah'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildSummaryCard(String label, double amount, Color color) {
    return Container(
      padding: AppPadding.allM,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.allM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currencyFormatter.format(amount),
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatList(double totalZakat) {
    if (_zakatList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium section title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                'Riwayat Zakat',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_zakatList.length} data',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _zakatList.length,
          itemBuilder: (context, index) {
            final zakat = _zakatList[index];
            return _buildPremiumZakatCard(zakat, index);
          },
        ),
        const SizedBox(height: 100), // Add padding for FAB
      ],
    );
  }

  Widget _buildPremiumZakatCard(Zakat zakat, int index) {
    final isPrimary = zakat.type == 'maal';
    final color = isPrimary ? AppColors.primary : AppColors.gold;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Reduced padding
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(10), // Reduced from 12
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPrimary
                          ? [AppColors.primary, AppColors.primaryLight]
                          : [AppColors.gold, AppColors.goldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                  child: Icon(
                    isPrimary ? Icons.monetization_on_rounded : Icons.rice_bowl_rounded,
                    color: AppColors.white,
                    size: 20, // Reduced from 22
                  ),
                ),
                const SizedBox(width: 10), // Reduced from 14
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (zakat.note != null && zakat.note!.isNotEmpty) 
                            ? zakat.note! 
                            : (isPrimary ? 'Zakat Maal' : 'Zakat Fitrah'),
                        style: const TextStyle(
                          fontSize: 14, // Reduced from 15
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(zakat.date),
                            style: TextStyle(
                              fontSize: 11, // Reduced from 12
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8), // Reduced from 12
                // Amount & Actions
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormatter.format(zakat.amount),
                      style: TextStyle(
                        fontSize: 14, // Reduced from 15
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (widget.isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: InkWell(
                          onTap: () => _showDeleteDialog(zakat.id),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded, 
                              size: 18, 
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (500 + index * 60).ms).slideX(begin: 0.05);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppDimensions.spacingM),
          Text('Memuat data...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppPadding.allXL,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              'Belum ada data zakat',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              widget.isAdmin
                  ? 'Mulai tambahkan data zakat dengan tombol di bawah'
                  : 'Data zakat akan ditampilkan setelah admin menambahkannya',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.allL),
        title: Text('Hapus Zakat', style: AppTextStyles.titleLarge),
        content: Text(
          'Apakah Anda yakin ingin menghapus data zakat ini?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: AppTextStyles.buttonText),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (!mounted) return;

              try {
                await _zakatService.deleteZakat(id);
                await _loadZakatData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data zakat berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.allS),
            ),
            child: Text('Hapus', style: AppTextStyles.buttonPrimary),
          ),
        ],
      ),
    );
  }
}

// Pattern Painter for header overlay
class _ZakatPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;
    
    // Draw geometric pattern
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        // Diamond shape
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

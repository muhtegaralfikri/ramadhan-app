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
          ? FloatingActionButton.extended(
              onPressed: () async {
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
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: Text('Tambah Zakat', style: AppTextStyles.buttonPrimary),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(double totalZakat) {
    return SliverAppBar(
      expandedHeight: 170,
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
                  Text(
                    widget.isAdmin ? 'Pencatatan Zakat' : 'Total Zakat Diterima',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                  const SizedBox(height: AppDimensions.spacingS),
                  Text(
                    _currencyFormatter.format(totalZakat),
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),
                ],
              ),
            ),
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
      padding: AppPadding.allL,
      child: Container(
        padding: AppPadding.allL,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.allL,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Column(
              children: [
                Text('Distribusi Zakat', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppDimensions.spacingL),
                _buildChartLegend(),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      value: totalMaal,
                      title: '${((totalMaal / (totalMaal + totalFitrah)) * 100).toStringAsFixed(1)}%',
                      titleStyle: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      color: AppColors.primary,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: totalFitrah,
                      title: '${((totalFitrah / (totalMaal + totalFitrah)) * 100).toStringAsFixed(1)}%',
                      titleStyle: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      color: AppColors.gold,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).scale(),
            const SizedBox(height: AppDimensions.spacingXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard('Zakat Maal', totalMaal, AppColors.primary),
                _buildSummaryCard('Zakat Fitrah', totalFitrah, AppColors.gold),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
          ],
        ),
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
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_zakatList.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppPadding.hL,
          child: Text(
            'Riwayat Zakat',
            style: AppTextStyles.titleLarge,
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: AppDimensions.spacingM),
        ListView.builder(
          padding: AppPadding.hL,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _zakatList.length,
          itemBuilder: (context, index) {
            final zakat = _zakatList[index];
            return _buildZakatCard(zakat, index);
          },
        ),
        const SizedBox(height: 80), // Add padding for FAB
      ],
    );
  }

  Widget _buildZakatCard(Zakat zakat, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      padding: AppPadding.allM,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allM,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: zakat.type == 'maal'
                    ? [AppColors.primary, AppColors.primaryLight]
                    : [AppColors.gold, AppColors.goldLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.allS,
            ),
            child: Icon(
              zakat.type == 'maal' ? Icons.monetization_on_rounded : Icons.rice_bowl_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (zakat.note != null && zakat.note!.isNotEmpty) ? zakat.note! : (zakat.type == 'maal' ? 'Zakat Maal' : 'Zakat Fitrah'),
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(zakat.date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFormatter.format(zakat.amount),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (widget.isAdmin)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: InkWell(
                    onTap: () => _showDeleteDialog(zakat.id),
                    child: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (500 + index * 50).ms).slideX(begin: 0.1);
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

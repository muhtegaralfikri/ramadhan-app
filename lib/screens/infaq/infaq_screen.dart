import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/infaq.dart';
import '../../services/infaq_service.dart';
import '../../services/auth_service.dart';

class InfaqScreen extends StatefulWidget {
  const InfaqScreen({super.key});

  @override
  State<InfaqScreen> createState() => _InfaqScreenState();
}

class _InfaqScreenState extends State<InfaqScreen> {
  final InfaqService _infaqService = InfaqService();
  final AuthService _authService = AuthService();
  
  List<Infaq> _infaqList = [];
  Map<String, dynamic> _progress = {'collected': 0.0, 'target': 0.0, 'percentage': 0.0};
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final isLoggedIn = _authService.isLoggedIn;
      final infaq = await _infaqService.getAllInfaq();
      final progress = await _infaqService.getProgress();
      
      if (mounted) {
        setState(() {
          _isAdmin = isLoggedIn;
          _infaqList = infaq;
          _progress = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ))
                : _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _isAdmin ? _buildAddFAB() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 340,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFD4AF37),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
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
              colors: [Color(0xFFB8962F), Color(0xFFD4AF37)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Hero(
                        tag: 'hero_infaq_icon',
                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          size: 36,
                          color: AppColors.white,
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 8),
                    const Text(
                      'Infaq Ramadan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),
                    // Progress section
                    _buildProgressSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final percentage = _progress['percentage'] as double;
    final collected = _progress['collected'] as double;
    final target = _progress['target'] as double;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terkumpul',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
              Text(
                target > 0 ? '${percentage.toStringAsFixed(1)}%' : '-',
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: target > 0 ? percentage / 100 : 0,
              backgroundColor: AppColors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCurrency(collected),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'terkumpul',
                    style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 11),
                  ),
                ],
              ),
              if (target > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(target),
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'target',
                      style: TextStyle(color: AppColors.white.withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isAdmin) ...[
            _buildAdminActions(),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFB8962F), AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Riwayat Donasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_infaqList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('Belum ada donasi', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_infaqList.length, (index) => _buildInfaqCard(_infaqList[index], index)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showSetTargetDialog,
            icon: const Icon(Icons.flag_rounded, size: 18),
            label: const Text('Set Target'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB8962F),
              side: const BorderSide(color: Color(0xFFB8962F)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildInfaqCard(Infaq infaq, int index) {
    final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.paid_rounded, color: Color(0xFFD4AF37), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  infaq.donorName ?? 'Hamba Allah',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  dateFormat.format(infaq.createdAt),
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                if (infaq.message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      infaq.message!,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatCurrency(infaq.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFB8962F),
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (400 + index * 30).ms);
  }

  Widget _buildAddFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB8962F), Color(0xFFD4AF37)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _showAddInfaqDialog,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Text('Tambah Infaq', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  void _showAddInfaqDialog() {
    final amountController = TextEditingController();
    final donorController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Donasi Infaq'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah (Rp) *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.paid),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: donorController,
              decoration: InputDecoration(
                labelText: 'Nama Donatur',
                hintText: 'Kosongkan untuk anonim',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Pesan/Doa',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), ''));
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan jumlah yang valid')),
                );
                return;
              }
              
              final infaq = Infaq(
                id: const Uuid().v4(),
                amount: amount,
                donorName: donorController.text.trim().isEmpty ? null : donorController.text.trim(),
                message: messageController.text.trim().isEmpty ? null : messageController.text.trim(),
                createdAt: DateTime.now(),
              );
              
              try {
                await _infaqService.addInfaq(infaq);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Infaq berhasil dicatat'), backgroundColor: Color(0xFFB8962F)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8962F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showSetTargetDialog() {
    final targetController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Target Infaq'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target (Rp)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Contoh: Renovasi Masjid',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final target = double.tryParse(targetController.text.replaceAll(RegExp(r'[^0-9]'), ''));
              if (target == null || target <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan target yang valid')),
                );
                return;
              }
              
              final infaqTarget = InfaqTarget(
                id: const Uuid().v4(),
                targetAmount: target,
                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                year: DateTime.now().year,
                isActive: true,
              );
              
              try {
                await _infaqService.setTarget(infaqTarget);
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Target berhasil diset'), backgroundColor: Color(0xFFB8962F)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8962F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

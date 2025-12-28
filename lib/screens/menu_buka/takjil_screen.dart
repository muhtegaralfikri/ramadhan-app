import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../models/takjil_donor.dart';
import '../../services/takjil_service.dart';
import '../../services/auth_service.dart';
import '../../services/hijri_service.dart';

class TakjilScreen extends StatefulWidget {
  const TakjilScreen({super.key});

  @override
  State<TakjilScreen> createState() => _TakjilScreenState();
}

class _TakjilScreenState extends State<TakjilScreen> {
  final TakjilService _takjilService = TakjilService();
  final AuthService _authService = AuthService();
  
  Map<int, List<TakjilDonor>> _donorsByDay = {};
  bool _isLoading = true;
  bool _isAdmin = false;
  int _currentRamadanDay = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final isLoggedIn = _authService.isLoggedIn;
      final donors = await _takjilService.getDonorsGroupedByDay();
      
      // Calculate current Ramadan day
      final now = DateTime.now();
      final hijriDate = HijriService.gregorianToHijri(now);
      final currentRamadanDay = hijriDate.month == 9 ? hijriDate.day : 0;
      
      if (mounted) {
        setState(() {
          _isAdmin = isLoggedIn;
          _donorsByDay = donors;
          _currentRamadanDay = currentRamadanDay;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ))
                : _buildDaysList(),
          ),
        ],
      ),
      floatingActionButton: _isAdmin ? _buildAddFAB(context) : null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final totalDonors = _donorsByDay.values.fold<int>(0, (sum, list) => sum + list.length);
    
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF5E35B1),
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
              colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TakjilPatternPainter(),
                ),
              ),
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
                        child: Hero(
                          tag: 'hero_menu_icon',
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            size: 36,
                            color: AppColors.white,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: 12),
                      const Text(
                        'Jadwal Takjil Ramadan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 4),
                      Text(
                        '$totalDonors donatur terdaftar',
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

  Widget _buildDaysList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              const Text(
                'Daftar Donatur per Hari',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          ...List.generate(30, (index) {
            final day = index + 1;
            final donors = _donorsByDay[day] ?? [];
            final isToday = day == _currentRamadanDay;
            return _buildDayCard(day, donors, isToday, index);
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDayCard(int day, List<TakjilDonor> donors, bool isToday, int index) {
    final color = isToday ? AppColors.primary : const Color(0xFF5E35B1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAdmin && donors.isNotEmpty
              ? () => _showDonorDetails(day, donors)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Day number badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isToday
                          ? [AppColors.primary, AppColors.primaryDark]
                          : [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday)
                        const Text(
                          'HARI INI',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Donor names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hari ke-$day Ramadan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isToday ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (donors.isEmpty)
                        Text(
                          'Belum ada donatur',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: donors.map((donor) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              donor.donorName,
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
                // Add button for admin
                if (_isAdmin)
                  IconButton(
                    onPressed: () => _showAddDonorDialog(day),
                    icon: Icon(Icons.add_circle_outline, color: color),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (500 + index * 30).ms).slideX(begin: 0.05);
  }

  Widget _buildAddFAB(BuildContext context) {
    return Container(
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
          onTap: () => _showAddDonorDialog(null),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add_rounded, color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tambah Donatur',
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
    ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }

  void _showAddDonorDialog(int? preselectedDay) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final contactController = TextEditingController();
    int selectedDay = preselectedDay ?? 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Donatur Takjil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Day selector
                DropdownButtonFormField<int>(
                  value: selectedDay,
                  decoration: InputDecoration(
                    labelText: 'Hari Ramadan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  items: List.generate(30, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Hari ke-${i + 1}'),
                  )),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedDay = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Name input
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Donatur *',
                    hintText: 'Contoh: Keluarga Bpk. Ahmad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                // Description input
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Keterangan (opsional)',
                    hintText: 'Contoh: Kolak & Kurma',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                // Contact input
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: 'Kontak (opsional)',
                    hintText: 'Contoh: 08123456789',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama donatur harus diisi')),
                  );
                  return;
                }
                
                final donor = TakjilDonor(
                  id: const Uuid().v4(),
                  donorName: nameController.text.trim(),
                  ramadanDay: selectedDay,
                  description: descController.text.trim().isEmpty 
                      ? null 
                      : descController.text.trim(),
                  contact: contactController.text.trim().isEmpty 
                      ? null 
                      : contactController.text.trim(),
                  createdAt: DateTime.now(),
                );
                
                try {
                  await _takjilService.addDonor(donor);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Donatur berhasil ditambahkan'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menambah donatur: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan', style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonorDetails(int day, List<TakjilDonor> donors) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Donatur Hari ke-$day',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...donors.map((donor) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: Text(donor.donorName),
              subtitle: donor.description != null ? Text(donor.description!) : null,
              trailing: _isAdmin
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () async {
                        await _takjilService.deleteDonor(donor.id);
                        if (mounted) {
                          Navigator.pop(context);
                          _loadData();
                        }
                      },
                    )
                  : null,
            )),
          ],
        ),
      ),
    );
  }
}

class _TakjilPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.03)
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

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
    // Premium Simple Style:
    // Today: Gold accent.
    // Others: Gray/Neutral.
    final accentColor = isToday ? AppColors.gold : const Color(0xFF757575);
    final badgeBgColor = isToday ? AppColors.gold : const Color(0xFFEEEEEE);
    final badgeTextColor = isToday ? AppColors.white : const Color(0xFF616161);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Very subtle shadow
            blurRadius: 10,
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
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(14),
                    // No deep shadows, clean flat/soft look
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday)
                        Text(
                          'HARI INI',
                          style: TextStyle(
                            color: badgeTextColor.withValues(alpha: 0.9),
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ramadan Hari ke-$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (donors.isEmpty)
                        Text(
                          'Belum ada donatur',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        // Use simple text list or very clean chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: donors.map((donor) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isToday 
                                ? AppColors.gold.withValues(alpha: 0.1) 
                                : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              donor.donorName,
                              style: TextStyle(
                                fontSize: 12,
                                color: isToday ? const Color(0xFF8D6E63) : AppColors.textPrimary, // Brownish for Gold theme
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
                
                // Edit/Add Icon
                if (_isAdmin)
                  IconButton(
                    onPressed: () => _showAddDonorDialog(day),
                    icon: Icon(
                      Icons.edit_note_rounded, // Changed icon to be more subtle
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 30).ms).slideX(begin: 0.05);
  }

  Widget _buildAddFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5E35B1), Color(0xFF7E57C2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: 0.4),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 
            20, 
            24, 
            MediaQuery.of(context).viewInsets.bottom + 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Tambah Donatur Takjil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5E35B1),
                ),
              ),
              const SizedBox(height: 24),
              
              // Day Selector
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50], // Premium light background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonFormField<int>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Hari Ramadan',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    prefixIcon: Icon(Icons.calendar_today_rounded, color: Color(0xFF5E35B1)),
                  ),
                  items: List.generate(30, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Hari ke-${i + 1} Ramadan'),
                  )),
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => selectedDay = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // Name Input
              _buildModernTextField(
                controller: nameController,
                label: 'Nama Donatur',
                icon: Icons.person_rounded,
                hint: 'Contoh: Hamba Allah',
              ),
              const SizedBox(height: 16),
              
              // Description Input
              _buildModernTextField(
                controller: descController,
                label: 'Menu / Keterangan (Opsional)',
                icon: Icons.restaurant_menu_rounded,
                hint: 'Contoh: Nasi Kotak 100 pax',
              ),
              const SizedBox(height: 16),
              
              // Contact Input
              _buildModernTextField(
                controller: contactController,
                label: 'No. WhatsApp (Opsional)',
                icon: Icons.phone_rounded,
                hint: '08xxxxxxxxxx',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama donatur wajib diisi')),
                      );
                      return;
                    }
                    
                    Navigator.pop(context);
                    
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
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Alhamdulillah, donatur berhasil ditambahkan'),
                            backgroundColor: const Color(0xFF5E35B1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menambah data: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    shadowColor: const Color(0xFF5E35B1).withValues(alpha: 0.4),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Simpan Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(icon, color: const Color(0xFF5E35B1)),
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
                backgroundColor: const Color(0xFF5E35B1).withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: Color(0xFF5E35B1)),
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

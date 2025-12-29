import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../models/tarawih_schedule.dart';
import '../../services/tarawih_service.dart';
import '../../services/auth_service.dart';
import '../../services/hijri_service.dart';

class TarawihScreen extends StatefulWidget {
  const TarawihScreen({super.key});

  @override
  State<TarawihScreen> createState() => _TarawihScreenState();
}

class _TarawihScreenState extends State<TarawihScreen> {
  final TarawihService _tarawihService = TarawihService();
  final AuthService _authService = AuthService();
  
  Map<int, TarawihSchedule> _scheduleMap = {};
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
      
      if (mounted) {
        setState(() => _isAdmin = isLoggedIn);
      }

      final schedules = await _tarawihService.getSchedulesMap();
      
      final now = DateTime.now();
      final hijriDate = HijriService.gregorianToHijri(now);
      // DEBUG: Default to 2 for testing UI
      final currentDay = hijriDate.month == 9 ? hijriDate.day : 2;
      
      if (mounted) {
        setState(() {
          _scheduleMap = schedules;
          _currentRamadanDay = currentDay;
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
          _buildSliverAppBar(),
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
      floatingActionButton: _isAdmin ? _buildAddFAB() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF00695C),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
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
              colors: [Color(0xFF00695C), Color(0xFF00897B)],
            ),
          ),
          child: SafeArea(
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
                      tag: 'hero_tarawih_icon',
                      child: Icon(
                        Icons.nights_stay_rounded,
                        size: 36,
                        color: AppColors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 12),
                  const Text(
                    'Jadwal Tarawih',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    '${_scheduleMap.length} malam terjadwal',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysList() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                    colors: [const Color(0xFF00695C), AppColors.gold],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Jadwal per Malam',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          ...List.generate(30, (index) {
            final day = index + 1;
            final schedule = _scheduleMap[day];
            final isToday = day == _currentRamadanDay;
            return _buildDayCard(day, schedule, isToday, index);
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDayCard(int day, TarawihSchedule? schedule, bool isToday, int index) {
    // Colorful Gradient Style (Teal Theme)
    final primaryColor = const Color(0xFF00695C);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isToday 
          ? LinearGradient(
              colors: [primaryColor, const Color(0xFF00897B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [Color(0xFFE0F2F1), Colors.white], // Light Teal Tint
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isToday 
              ? primaryColor.withValues(alpha: 0.3) 
              : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAdmin ? () => _showEditDialog(day, schedule) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Day badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.white.withValues(alpha: 0.2) : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isToday ? null : [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isToday ? AppColors.white : primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday)
                        Text(
                          'MALAM INI',
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Malam ke-$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isToday ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (schedule == null)
                        Text(
                          'Belum ada jadwal',
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday 
                              ? AppColors.white.withValues(alpha: 0.7) 
                              : AppColors.textSecondary.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (schedule.imamName != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_rounded, 
                                      size: 14, 
                                      color: isToday ? AppColors.white.withValues(alpha: 0.9) : primaryColor
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Imam: ${schedule.imamName}',
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: isToday ? AppColors.white.withValues(alpha: 0.9) : primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded, 
                                  size: 14, 
                                  color: isToday ? AppColors.white.withValues(alpha: 0.7) : AppColors.textSecondary
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${schedule.startTime ?? "-"} • ${schedule.rakaat} rakaat',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isToday ? AppColors.white.withValues(alpha: 0.7) : AppColors.textSecondary
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (_isAdmin)
                  Icon(
                    Icons.edit_rounded, 
                    size: 18, 
                    color: isToday 
                      ? AppColors.white.withValues(alpha: 0.6) 
                      : primaryColor.withValues(alpha: 0.5)
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (400 + index * 25).ms).slideX(begin: 0.05);
  }

  Widget _buildAddFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF00897B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditDialog(null, null),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Text('Atur Jadwal', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  void _showEditDialog(int? day, TarawihSchedule? schedule) {
    final imamController = TextEditingController(text: schedule?.imamName ?? '');
    final timeController = TextEditingController(text: schedule?.startTime ?? '19:30');
    final notesController = TextEditingController(text: schedule?.notes ?? '');
    int selectedDay = day ?? schedule?.ramadanDay ?? 1;
    int rakaat = schedule?.rakaat ?? 20;

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
          child: SingleChildScrollView(
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
                
                Text(
                  schedule != null ? 'Edit Jadwal Tarawih' : 'Tambah Jadwal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C),
                  ),
                ),
                const SizedBox(height: 24),

                // Day Selector
                if (day == null && schedule == null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<int>(
                      initialValue: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Malam ke-',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      items: List.generate(30, (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('Malam ke-${i + 1} Ramadan'),
                      )),
                      onChanged: (value) {
                        if (value != null) setSheetState(() => selectedDay = value);
                      },
                    ),
                  ),

                // Imam Input
                _buildModernTextField(
                  controller: imamController,
                  label: 'Nama Imam',
                  icon: Icons.person_rounded,
                  hint: 'Contoh: Ustadz Ahmad',
                  color: const Color(0xFF00695C),
                ),
                const SizedBox(height: 16),

                // Time Input
                _buildModernTextField(
                  controller: timeController,
                  label: 'Waktu Mulai',
                  icon: Icons.access_time_rounded,
                  hint: '19:30',
                  color: const Color(0xFF00695C),
                ),
                const SizedBox(height: 16),

                // Rakaat Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: DropdownButtonFormField<int>(
                    initialValue: rakaat,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Rakaat',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      prefixIcon: Icon(Icons.repeat_rounded, color: Color(0xFF00695C)),
                    ),
                    items: [8, 11, 20, 23].map((r) => DropdownMenuItem(
                      value: r,
                      child: Text('$r Rakaat'),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) setSheetState(() => rakaat = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Input
                _buildModernTextField(
                  controller: notesController,
                  label: 'Catatan (Opsional)',
                  icon: Icons.note_alt_rounded,
                  color: const Color(0xFF00695C),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      
                      final newSchedule = TarawihSchedule(
                        id: schedule?.id ?? const Uuid().v4(),
                        ramadanDay: day ?? selectedDay,
                        imamName: imamController.text.trim().isEmpty ? null : imamController.text.trim(),
                        startTime: timeController.text.trim().isEmpty ? null : timeController.text.trim(),
                        rakaat: rakaat,
                        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        createdAt: schedule?.createdAt ?? DateTime.now(),
                      );
                      
                      try {
                        await _tarawihService.upsertSchedule(newSchedule);
                        if (mounted) {
                          _loadData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jadwal berhasil disimpan'),
                                backgroundColor: Color(0xFF00695C),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00695C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: const Color(0xFF00695C).withValues(alpha: 0.4),
                    ),
                    child: const Text('Simpan Data', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
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
    Color? color,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(icon, color: color ?? AppColors.primary),
        ),
      ),
    );
  }
}

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
      final schedules = await _tarawihService.getSchedulesMap();
      
      final now = DateTime.now();
      final hijriDate = HijriService.gregorianToHijri(now);
      final currentDay = hijriDate.month == 9 ? hijriDate.day : 1;
      
      if (mounted) {
        setState(() {
          _isAdmin = isLoggedIn;
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
                    child: const Icon(
                      Icons.nights_stay_rounded,
                      size: 36,
                      color: AppColors.white,
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
    const color = Color(0xFF00695C);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: color, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
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
                    gradient: LinearGradient(
                      colors: isToday
                          ? [AppColors.primary, AppColors.primaryDark]
                          : [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
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
                          'MALAM INI',
                          style: TextStyle(
                            color: AppColors.white,
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
                          color: isToday ? color : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (schedule == null)
                        Text(
                          'Belum ada jadwal',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (schedule.imamName != null)
                              Row(
                                children: [
                                  Icon(Icons.person_rounded, size: 14, color: color),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Imam: ${schedule.imamName}',
                                    style: TextStyle(fontSize: 12, color: color),
                                  ),
                                ],
                              ),
                            if (schedule.startTime != null)
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Mulai: ${schedule.startTime}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            Row(
                              children: [
                                Icon(Icons.repeat_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${schedule.rakaat} rakaat',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (_isAdmin)
                  Icon(Icons.edit_rounded, size: 18, color: color.withValues(alpha: 0.5)),
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
    int selectedDay = day ?? 1;
    int rakaat = schedule?.rakaat ?? 20;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(schedule != null ? 'Edit Jadwal Malam ke-$day' : 'Tambah Jadwal Tarawih'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (day == null)
                  DropdownButtonFormField<int>(
                    value: selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Malam ke-',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: List.generate(30, (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('Malam ke-${i + 1}'),
                    )),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedDay = value);
                    },
                  ),
                if (day == null) const SizedBox(height: 16),
                TextField(
                  controller: imamController,
                  decoration: InputDecoration(
                    labelText: 'Nama Imam',
                    hintText: 'Contoh: Ustadz Ahmad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Waktu Mulai',
                    hintText: 'Contoh: 19:30',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: rakaat,
                  decoration: InputDecoration(
                    labelText: 'Jumlah Rakaat',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [8, 11, 20, 23].map((r) => DropdownMenuItem(
                    value: r,
                    child: Text('$r rakaat'),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => rakaat = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 2,
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
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jadwal berhasil disimpan'), backgroundColor: Color(0xFF00695C)),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan', style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

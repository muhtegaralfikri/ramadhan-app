import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/kajian.dart';
import '../../services/kajian_service.dart';
import '../../services/auth_service.dart';

class KajianScreen extends StatefulWidget {
  const KajianScreen({super.key});

  @override
  State<KajianScreen> createState() => _KajianScreenState();
}

class _KajianScreenState extends State<KajianScreen> {
  final KajianService _kajianService = KajianService();
  final AuthService _authService = AuthService();
  
  List<Kajian> _kajianList = [];
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
      
      if (mounted) {
        setState(() => _isAdmin = isLoggedIn);
      }

      final kajian = await _kajianService.getAllKajian();
      
      if (mounted) {
        setState(() {
          _kajianList = kajian;
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
                : _buildKajianList(),
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
      backgroundColor: const Color(0xFF7B1FA2),
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
              colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
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
                      tag: 'hero_kajian_icon',
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 36,
                        color: AppColors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 12),
                  const Text(
                    'Jadwal Kajian',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    '${_kajianList.length} kajian terjadwal',
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

  Widget _buildKajianList() {
    if (_kajianList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'Belum ada jadwal kajian',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...List.generate(_kajianList.length, (index) {
            return _buildKajianCard(_kajianList[index], index);
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildKajianCard(Kajian kajian, int index) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final isPast = kajian.date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPast ? AppColors.surface.withValues(alpha: 0.7) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B1FA2).withValues(alpha: isPast ? 0.05 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAdmin ? () => _showEditDialog(kajian) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B1FA2).withValues(alpha: isPast ? 0.1 : 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: isPast ? AppColors.textSecondary : const Color(0xFF7B1FA2),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kajian.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isPast ? AppColors.textSecondary : AppColors.textPrimary,
                            ),
                          ),
                          if (kajian.speaker != null)
                            Text(
                              kajian.speaker!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isPast ? AppColors.textSecondary : const Color(0xFF7B1FA2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isAdmin)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.error.withValues(alpha: 0.7)),
                        onPressed: () => _deleteKajian(kajian),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      dateFormat.format(kajian.date),
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (kajian.time != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        kajian.time!,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
                if (kajian.location != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        kajian.location!,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
                if (kajian.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    kajian.description!,
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (300 + index * 50).ms).slideX(begin: 0.05);
  }

  Widget _buildAddFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B1FA2).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditDialog(null),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.white, size: 20),
                SizedBox(width: 8),
                Text('Tambah Kajian', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  void _showEditDialog(Kajian? kajian) {
    final titleController = TextEditingController(text: kajian?.title ?? '');
    final speakerController = TextEditingController(text: kajian?.speaker ?? '');
    final timeController = TextEditingController(text: kajian?.time ?? '');
    final locationController = TextEditingController(text: kajian?.location ?? '');
    final descController = TextEditingController(text: kajian?.description ?? '');
    DateTime selectedDate = kajian?.date ?? DateTime.now();

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
                  kajian != null ? 'Edit Jadwal Kajian' : 'Tambah Kajian Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
                const SizedBox(height: 24),

                // Title Input
                _buildModernTextField(
                  controller: titleController,
                  label: 'Tema/Judul Kajian *',
                  icon: Icons.menu_book,
                  hint: 'Contoh: Fiqih Puasa',
                  color: const Color(0xFF7B1FA2),
                ),
                const SizedBox(height: 16),

                // Speaker Input
                _buildModernTextField(
                  controller: speakerController,
                  label: 'Penceramah',
                  icon: Icons.person_rounded,
                  hint: 'Contoh: Ustadz Hanan Attaki',
                  color: const Color(0xFF7B1FA2),
                ),
                const SizedBox(height: 16),

                // Date Picker Field
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF7B1FA2),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Color(0xFF7B1FA2)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: timeController,
                        label: 'Waktu',
                        icon: Icons.access_time_filled_rounded,
                        hint: '19:30',
                        color: const Color(0xFF7B1FA2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModernTextField(
                        controller: locationController,
                        label: 'Lokasi',
                        icon: Icons.location_on_rounded,
                        hint: 'Masjid Utama',
                        color: const Color(0xFF7B1FA2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description Input
                _buildModernTextField(
                  controller: descController,
                  label: 'Catatan / Deskripsi',
                  icon: Icons.notes_rounded,
                  color: const Color(0xFF7B1FA2),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Judul wajib diisi')),
                        );
                        return;
                      }
                      
                      Navigator.pop(context);

                      final newKajian = Kajian(
                        id: kajian?.id ?? const Uuid().v4(),
                        title: titleController.text.trim(),
                        speaker: speakerController.text.trim().isEmpty ? null : speakerController.text.trim(),
                        date: selectedDate,
                        time: timeController.text.trim().isEmpty ? null : timeController.text.trim(),
                        location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                        description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                        createdAt: kajian?.createdAt ?? DateTime.now(),
                      );
                      
                      try {
                        if (kajian != null) {
                          await _kajianService.updateKajian(newKajian);
                        } else {
                          await _kajianService.addKajian(newKajian);
                        }
                        if (mounted) {
                          _loadData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kajian berhasil disimpan'),
                                backgroundColor: Color(0xFF7B1FA2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B1FA2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text('Simpan Kajian', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _deleteKajian(Kajian kajian) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kajian?'),
        content: Text('Hapus "${kajian.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _kajianService.deleteKajian(kajian.id);
      _loadData();
    }
  }
}

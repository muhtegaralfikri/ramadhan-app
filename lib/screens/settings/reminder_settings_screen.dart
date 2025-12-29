import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ramadan_app/constants/app_colors.dart';
import 'package:ramadan_app/services/notification_service.dart';
import 'package:ramadan_app/services/prayer_times_service.dart';
import 'package:ramadan_app/services/location_service.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final PrayerTimesService _prayerService = PrayerTimesService();
  final LocationService _locationService = LocationService();

  bool _sahurEnabled = true;
  bool _iftarEnabled = true;
  bool _prayerEnabled = false;
  int _sahurMinutes = 30;
  int _iftarMinutes = 10;
  int _prayerMinutes = 15;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<int> _minuteOptions = [5, 10, 15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    _sahurEnabled = await _notificationService.isSahurReminderEnabled();
    _iftarEnabled = await _notificationService.isIftarReminderEnabled();
    _prayerEnabled = await _notificationService.isPrayerReminderEnabled();
    _sahurMinutes = await _notificationService.getSahurMinutesBefore();
    _iftarMinutes = await _notificationService.getIftarMinutesBefore();
    _prayerMinutes = await _notificationService.getPrayerMinutesBefore();
    
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    // Request permissions first
    final hasPermission = await _notificationService.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin notifikasi diperlukan untuk fitur pengingat'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    // Save preferences
    await _notificationService.setSahurReminderEnabled(_sahurEnabled);
    await _notificationService.setIftarReminderEnabled(_iftarEnabled);
    await _notificationService.setPrayerReminderEnabled(_prayerEnabled);
    await _notificationService.setSahurMinutesBefore(_sahurMinutes);
    await _notificationService.setIftarMinutesBefore(_iftarMinutes);
    await _notificationService.setPrayerMinutesBefore(_prayerMinutes);

    // Schedule notifications based on prayer times
    await _scheduleNotifications();

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Pengaturan tersimpan'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _scheduleNotifications() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) return;

      final prayerTimes = await _prayerService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
        date: DateTime.now(),
      );

      if (prayerTimes == null) return;

      final prayers = prayerTimes.toList();
      
      // Find Subuh time for Sahur reminder
      String? subuhTime;
      for (final p in prayers) {
        if (p['name'] == 'Subuh') {
          subuhTime = p['time'];
          break;
        }
      }

      // Find Maghrib time for Iftar reminder
      String? maghribTime;
      for (final p in prayers) {
        if (p['name'] == 'Maghrib') {
          maghribTime = p['time'];
          break;
        }
      }

      final now = DateTime.now();

      if (subuhTime != null && _sahurEnabled) {
        final parts = subuhTime.split(':');
        final subuhDateTime = DateTime(
          now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]),
        );
        await _notificationService.scheduleSahurReminder(
          subuhTime: subuhDateTime,
          minutesBefore: _sahurMinutes,
        );
      }

      if (maghribTime != null && _iftarEnabled) {
        final parts = maghribTime.split(':');
        final maghribDateTime = DateTime(
          now.year, now.month, now.day,
          int.parse(parts[0]), int.parse(parts[1]),
        );
        await _notificationService.scheduleIftarReminder(
          maghribTime: maghribDateTime,
          minutesBefore: _iftarMinutes,
        );
      }

      // Schedule prayer reminders for all 5 prayers
      if (_prayerEnabled) {
        for (final prayer in prayers) {
          final name = prayer['name'];
          final time = prayer['time'];

          // Ensure name and time are not null before using them
          if (name != null && name != 'Imsak' && name != 'Terbit' && time != null) {
            final parts = time.split(':');
            final prayerDateTime = DateTime(
              now.year, now.month, now.day,
              int.parse(parts[0]), int.parse(parts[1]),
            );
            await _notificationService.schedulePrayerReminder(
              prayerName: name,
              prayerTime: prayerDateTime,
              minutesBefore: _prayerMinutes,
            );
          }
        }
      } else {
        await _notificationService.cancelAllPrayerReminders();
      }
    } catch (e) {
      // Handle error silently
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
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6D4C41),
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
              colors: [Color(0xFF6D4C41), Color(0xFF8D6E63)],
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
                      tag: 'hero_reminder_icon',
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 36,
                        color: AppColors.white,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 12),
                  Text(
                    'Pengingat Puasa',
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
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Sahur Reminder Card
          _buildReminderCard(
            title: 'Pengingat Sahur',
            subtitle: 'Ingatkan sebelum waktu Subuh',
            icon: Icons.nightlight_round,
            iconColor: const Color(0xFF1565C0),
            enabled: _sahurEnabled,
            minutes: _sahurMinutes,
            onToggle: (value) => setState(() => _sahurEnabled = value),
            onMinutesChanged: (value) => setState(() => _sahurMinutes = value),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          // Iftar Reminder Card
          _buildReminderCard(
            title: 'Pengingat Berbuka',
            subtitle: 'Ingatkan sebelum waktu Maghrib',
            icon: Icons.wb_twilight_rounded,
            iconColor: const Color(0xFFE65100),
            enabled: _iftarEnabled,
            minutes: _iftarMinutes,
            onToggle: (value) => setState(() => _iftarEnabled = value),
            onMinutesChanged: (value) => setState(() => _iftarMinutes = value),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 16),
          
          // Prayer Time Reminder Card
          _buildReminderCard(
            title: 'Pengingat Sholat',
            subtitle: 'Ingatkan sebelum semua waktu sholat',
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFF2E7D32),
            enabled: _prayerEnabled,
            minutes: _prayerMinutes,
            onToggle: (value) => setState(() => _prayerEnabled = value),
            onMinutesChanged: (value) => setState(() => _prayerMinutes = value),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 32),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.save_rounded),
                        SizedBox(width: 8),
                        Text(
                          'Simpan Pengaturan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
          
          const SizedBox(height: 24),
          
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pengingat akan dijadwalkan otomatis berdasarkan waktu sholat lokasi Anda',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool enabled,
    required int minutes,
    required ValueChanged<bool> onToggle,
    required ValueChanged<int> onMinutesChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeThumbColor: iconColor,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Ingatkan sebelum:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<int>(
                    value: minutes,
                    underline: const SizedBox(),
                    isDense: true,
                    icon: Icon(Icons.arrow_drop_down, color: iconColor),
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _minuteOptions.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text('$m menit'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onMinutesChanged(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

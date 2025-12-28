import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // Preference keys
  static const String _sahurEnabledKey = 'sahur_reminder_enabled';
  static const String _iftarEnabledKey = 'iftar_reminder_enabled';
  static const String _sahurMinutesKey = 'sahur_minutes_before';
  static const String _iftarMinutesKey = 'iftar_minutes_before';
  static const String _prayerEnabledKey = 'prayer_reminder_enabled';
  static const String _prayerMinutesKey = 'prayer_minutes_before';

  // Notification IDs
  static const int _sahurNotificationId = 1001;
  static const int _iftarNotificationId = 1002;
  // Prayer notification IDs: Subuh=2001, Dzuhur=2002, Ashar=2003, Maghrib=2004, Isya=2005
  static const Map<String, int> _prayerNotificationIds = {
    'Subuh': 2001,
    'Dzuhur': 2002,
    'Ashar': 2003,
    'Maghrib': 2004,
    'Isya': 2005,
  };

  /// Initialize the notification service
  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap if needed
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true;
  }

  /// Schedule Sahur reminder
  Future<void> scheduleSahurReminder({
    required DateTime subuhTime,
    required int minutesBefore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_sahurEnabledKey) ?? true;
    
    if (!enabled) {
      await cancelSahurReminder();
      return;
    }

    final reminderTime = subuhTime.subtract(Duration(minutes: minutesBefore));
    
    // Don't schedule if time has passed
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await _notifications.zonedSchedule(
      _sahurNotificationId,
      '🌙 Waktu Sahur',
      'Ayo bangun untuk sahur! $minutesBefore menit lagi waktu Subuh',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'sahur_channel',
          'Pengingat Sahur',
          channelDescription: 'Notifikasi pengingat waktu sahur',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF2E7D32),
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedule Iftar reminder
  Future<void> scheduleIftarReminder({
    required DateTime maghribTime,
    required int minutesBefore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_iftarEnabledKey) ?? true;
    
    if (!enabled) {
      await cancelIftarReminder();
      return;
    }

    final reminderTime = maghribTime.subtract(Duration(minutes: minutesBefore));
    
    // Don't schedule if time has passed
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    await _notifications.zonedSchedule(
      _iftarNotificationId,
      '🌅 Waktu Berbuka',
      minutesBefore > 0 
          ? 'Sebentar lagi waktu berbuka! $minutesBefore menit menuju Maghrib'
          : 'Alhamdulillah, waktunya berbuka puasa!',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'iftar_channel',
          'Pengingat Berbuka',
          channelDescription: 'Notifikasi pengingat waktu berbuka puasa',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFE65100),
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel Sahur reminder
  Future<void> cancelSahurReminder() async {
    await _notifications.cancel(_sahurNotificationId);
  }

  /// Cancel Iftar reminder
  Future<void> cancelIftarReminder() async {
    await _notifications.cancel(_iftarNotificationId);
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // Preference getters and setters
  Future<bool> isSahurReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sahurEnabledKey) ?? true;
  }

  Future<void> setSahurReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sahurEnabledKey, enabled);
  }

  Future<bool> isIftarReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_iftarEnabledKey) ?? true;
  }

  Future<void> setIftarReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_iftarEnabledKey, enabled);
  }

  Future<int> getSahurMinutesBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sahurMinutesKey) ?? 30;
  }

  Future<void> setSahurMinutesBefore(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sahurMinutesKey, minutes);
  }

  Future<int> getIftarMinutesBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_iftarMinutesKey) ?? 10;
  }

  Future<void> setIftarMinutesBefore(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_iftarMinutesKey, minutes);
  }

  // Prayer reminder preferences
  Future<bool> isPrayerReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prayerEnabledKey) ?? false;
  }

  Future<void> setPrayerReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prayerEnabledKey, enabled);
  }

  Future<int> getPrayerMinutesBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prayerMinutesKey) ?? 15;
  }

  Future<void> setPrayerMinutesBefore(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prayerMinutesKey, minutes);
  }

  /// Schedule prayer time reminder
  Future<void> schedulePrayerReminder({
    required String prayerName,
    required DateTime prayerTime,
    required int minutesBefore,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prayerEnabledKey) ?? false;
    
    if (!enabled) {
      await cancelPrayerReminder(prayerName);
      return;
    }

    final notificationId = _prayerNotificationIds[prayerName];
    if (notificationId == null) return;

    final reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));
    
    // Don't schedule if time has passed
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    final emoji = _getPrayerEmoji(prayerName);
    final color = _getPrayerColor(prayerName);

    await _notifications.zonedSchedule(
      notificationId,
      '$emoji Waktu $prayerName',
      '$minutesBefore menit lagi masuk waktu $prayerName',
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Pengingat Sholat',
          channelDescription: 'Notifikasi pengingat waktu sholat',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: color,
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel specific prayer reminder
  Future<void> cancelPrayerReminder(String prayerName) async {
    final notificationId = _prayerNotificationIds[prayerName];
    if (notificationId != null) {
      await _notifications.cancel(notificationId);
    }
  }

  /// Cancel all prayer reminders
  Future<void> cancelAllPrayerReminders() async {
    for (final id in _prayerNotificationIds.values) {
      await _notifications.cancel(id);
    }
  }

  String _getPrayerEmoji(String prayerName) {
    switch (prayerName) {
      case 'Subuh': return '🌅';
      case 'Dzuhur': return '☀️';
      case 'Ashar': return '🌤️';
      case 'Maghrib': return '🌇';
      case 'Isya': return '🌙';
      default: return '🕌';
    }
  }

  Color _getPrayerColor(String prayerName) {
    switch (prayerName) {
      case 'Subuh': return const Color(0xFF1976D2);
      case 'Dzuhur': return const Color(0xFFFF9800);
      case 'Ashar': return const Color(0xFF689F38);
      case 'Maghrib': return const Color(0xFFE65100);
      case 'Isya': return const Color(0xFF5E35B1);
      default: return const Color(0xFF2E7D32);
    }
  }
}

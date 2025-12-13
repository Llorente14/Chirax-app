import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// NotificationService - Manages local notifications for streak reminders
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service and timezone
  static Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  /// Request notification permissions from user
  static Future<bool> requestPermissions() async {
    // Android 13+ requires explicit permission request
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS permission request
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedule daily reminder notification
  /// Testing: 18:32 | Production: 20:00
  static Future<void> scheduleDailyReminder() async {
    if (!_isInitialized) await init();

    // Cancel existing reminders first
    await cancelAll();

    // Notification details
    const androidDetails = AndroidNotificationDetails(
      'daily_streak', // Channel ID
      'Daily Streak Reminder', // Channel Name
      channelDescription: 'Reminder to maintain your daily streak',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Calculate next 18:32 (testing) - change to 20:00 for production
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20,
      0,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Schedule the notification
    await _notifications.zonedSchedule(
      0, // Notification ID
      '🔥 Jangan biarkan apinya padam!', // Title
      'Mochi kangen nih. Check-in sekarang yuk buat jaga streak!', // Body
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

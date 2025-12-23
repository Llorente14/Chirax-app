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

  /// Schedule daily reminder notifications
  /// 3x sehari: 12:00 (siang), 16:00 (sore), 20:00 (malam)
  static Future<void> scheduleDailyReminder() async {
    if (!_isInitialized) await init();

    // Cancel existing reminders first
    await cancelAll();

    // Schedule times and messages
    final schedules = [
      {
        'id': 1,
        'hour': 12,
        'minute': 0,
        'title': '☀️ Waktunya istirahat siang!',
        'body': 'Jangan lupa check-in sama Mochi yaa~ 💕',
      },
      {
        'id': 2,
        'hour': 16,
        'minute': 0,
        'title': '🌤️ Sore yang indah!',
        'body': 'Mochi nungguin kamu nih. Check-in yuk biar streak aman! 🔥',
      },
      {
        'id': 3,
        'hour': 20,
        'minute': 0,
        'title': '🌙 Jangan biarkan apinya padam!',
        'body': 'Mochi kangen nih. Check-in sekarang yuk buat jaga streak! 💫',
      },
    ];

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

    final now = tz.TZDateTime.now(tz.local);

    // Schedule each notification
    for (final schedule in schedules) {
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        schedule['hour'] as int,
        schedule['minute'] as int,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Schedule the notification
      await _notifications.zonedSchedule(
        schedule['id'] as int,
        schedule['title'] as String,
        schedule['body'] as String,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
    }
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

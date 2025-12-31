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

    // Initialize timezone database
    tz_data.initializeTimeZones();

    // Set timezone to Asia/Jakarta (WIB - UTC+7)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _isInitialized = true;
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    // Can be used to navigate to specific screen when notification is tapped
    // For now, just log it
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

  /// Show instant notification (for testing purposes)
  static Future<void> showInstantNotification({
    String title = '🔔 Test Notification',
    String body = 'Notifikasi berhasil! Mochi senang~',
  }) async {
    if (!_isInitialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'instant_test',
      'Instant Test Notifications',
      channelDescription: 'For testing notification functionality',
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

    await _notifications.show(
      999, // Test notification ID
      title,
      body,
      notificationDetails,
    );
  }

  /// Schedule daily reminder notifications
  /// 4x sehari: 12:29 (spesial), 14:00 (siang), 18:00 (sore), 21:00 (malam)
  static Future<void> scheduleDailyReminder() async {
    if (!_isInitialized) await init();

    // Cancel existing reminders first
    await cancelAll();

    // Schedule times and messages
    final schedules = [
      {
        'id': 1,
        'hour': 12,
        'minute': 29,
        'title': '💕 Waktu Spesial!',
        'body': 'Ini waktunya kamu dan dia~ Jangan lupa check-in! ✨',
      },
      {
        'id': 2,
        'hour': 14,
        'minute': 0,
        'title': '☀️ Waktunya istirahat siang!',
        'body': 'Jangan lupa check-in sama Mochi yaa~ 💕',
      },
      {
        'id': 3,
        'hour': 18,
        'minute': 0,
        'title': '🌤️ Sore yang indah!',
        'body': 'Mochi nungguin kamu nih. Check-in yuk biar streak aman! 🔥',
      },
      {
        'id': 4,
        'hour': 21,
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

  /// Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}

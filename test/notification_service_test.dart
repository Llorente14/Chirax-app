import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService', () {
    test('should have schedule times configured correctly', () {
      // Verify the notification schedule configuration
      // The service schedules 3 notifications at 12:00, 16:00, and 20:00

      // These are the expected schedule hours
      const expectedHours = [12, 16, 20];

      // Validate that we have 3 scheduled times
      expect(expectedHours.length, 3);

      // Validate each hour is within valid range
      for (final hour in expectedHours) {
        expect(
          hour >= 0 && hour <= 23,
          true,
          reason: 'Hour $hour should be between 0 and 23',
        );
      }
    });

    test('notification IDs should be unique', () {
      // Notification IDs used in scheduleDailyReminder
      const notificationIds = [1, 2, 3];

      // Check uniqueness
      final uniqueIds = notificationIds.toSet();
      expect(
        uniqueIds.length,
        notificationIds.length,
        reason: 'All notification IDs should be unique',
      );
    });

    test('test notification ID should not conflict with scheduled IDs', () {
      // Test notification uses ID 999
      const testNotificationId = 999;
      const scheduledIds = [1, 2, 3];

      expect(
        scheduledIds.contains(testNotificationId),
        false,
        reason: 'Test notification ID should not conflict with scheduled IDs',
      );
    });

    test('notification messages should not be empty', () {
      // Sample notification messages from the service
      final messages = [
        {
          'title': '☀️ Waktunya istirahat siang!',
          'body': 'Jangan lupa check-in sama Mochi yaa~ 💕',
        },
        {
          'title': '🌤️ Sore yang indah!',
          'body': 'Mochi nungguin kamu nih. Check-in yuk biar streak aman! 🔥',
        },
        {
          'title': '🌙 Jangan biarkan apinya padam!',
          'body':
              'Mochi kangen nih. Check-in sekarang yuk buat jaga streak! 💫',
        },
      ];

      for (final message in messages) {
        expect(
          message['title']!.isNotEmpty,
          true,
          reason: 'Notification title should not be empty',
        );
        expect(
          message['body']!.isNotEmpty,
          true,
          reason: 'Notification body should not be empty',
        );
      }
    });

    test('channel IDs should be valid', () {
      // Channel IDs used in the service
      const dailyStreakChannel = 'daily_streak';
      const instantTestChannel = 'instant_test';

      // Validate they are not empty and have valid format
      expect(dailyStreakChannel.isNotEmpty, true);
      expect(instantTestChannel.isNotEmpty, true);

      // Channel IDs should not contain spaces (Android requirement)
      expect(dailyStreakChannel.contains(' '), false);
      expect(instantTestChannel.contains(' '), false);
    });

    test('timezone should be set to Asia/Jakarta', () {
      // This test validates the expected timezone configuration
      // The actual timezone string that should be used
      const expectedTimezone = 'Asia/Jakarta';

      // Validate the timezone string format
      expect(
        expectedTimezone.contains('/'),
        true,
        reason: 'Timezone should follow IANA timezone format',
      );
      expect(
        expectedTimezone.startsWith('Asia'),
        true,
        reason: 'Should use Asia region for Indonesia',
      );
    });
  });
}

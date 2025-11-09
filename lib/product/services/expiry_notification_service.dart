// ignore_for_file: public_member_api_docs, avoid_catches_without_on_clauses

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing expiry date notifications
class ExpiryNotificationService {
  ExpiryNotificationService(this._notifications) {
    tz_data.initializeTimeZones();
  }

  final FlutterLocalNotificationsPlugin _notifications;

  /// Initialize notification service
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap (navigate to pantry page)
  }

  /// Schedule notifications for pantry items
  Future<void> scheduleNotifications(List<PantryItem> items) async {
    // Cancel all existing notifications
    await _notifications.cancelAll();

    final DateTime now = DateTime.now();

    for (final PantryItem item in items) {
      if (item.expiryDate == null) {
        continue;
      }

      final DateTime expiry = item.expiryDate!;
      final Duration difference = expiry.difference(now);

      // Skip if already expired (more than 1 day ago)
      if (difference.inDays < -1) {
        continue;
      }

      // Expired notification (within last day)
      if (difference.isNegative) {
        await _scheduleNotification(
          id: item.id.hashCode,
          title: tr('expiry_expired_title'),
          body: tr(
            'expiry_expired_body',
            namedArgs: <String, String>{'name': item.name},
          ),
          scheduledDate: now.add(const Duration(seconds: 5)),
        );
        continue;
      }

      // 3 days before expiry
      final DateTime threeDaysBefore = expiry.subtract(const Duration(days: 3));
      if (threeDaysBefore.isAfter(now) && difference.inDays >= 3) {
        await _scheduleNotification(
          id: item.id.hashCode + 1000,
          title: tr('expiry_3days_title'),
          body: tr(
            'expiry_3days_body',
            namedArgs: <String, String>{'name': item.name},
          ),
          scheduledDate: DateTime(
            threeDaysBefore.year,
            threeDaysBefore.month,
            threeDaysBefore.day,
            9,
          ),
        );
      }

      // 1 day before expiry
      final DateTime oneDayBefore = expiry.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now) && difference.inDays >= 1) {
        await _scheduleNotification(
          id: item.id.hashCode + 2000,
          title: tr('expiry_1day_title'),
          body: tr(
            'expiry_1day_body',
            namedArgs: <String, String>{'name': item.name},
          ),
          scheduledDate: DateTime(
            oneDayBefore.year,
            oneDayBefore.month,
            oneDayBefore.day,
            9,
          ),
        );
      }

      // On expiry day (morning 9 AM)
      if (difference.inDays == 0) {
        final DateTime expiryMorning = DateTime(
          expiry.year,
          expiry.month,
          expiry.day,
          9,
        );
        if (expiryMorning.isAfter(now)) {
          await _scheduleNotification(
            id: item.id.hashCode + 3000,
            title: tr('expiry_today_title'),
            body: tr(
              'expiry_today_body',
              namedArgs: <String, String>{'name': item.name},
            ),
            scheduledDate: expiryMorning,
          );
        }
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'expiry_notifications',
          'Son Kullanma Tarihi Bildirimleri',
          channelDescription:
              'Dolaptaki ürünlerin son kullanma tarihi bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) =>
      tz.TZDateTime.from(dateTime, tz.local);

  /// Cancel notification for a specific item
  Future<void> cancelItemNotifications(String itemId) async {
    await _notifications.cancel(itemId.hashCode);
    await _notifications.cancel(itemId.hashCode + 1000);
    await _notifications.cancel(itemId.hashCode + 2000);
    await _notifications.cancel(itemId.hashCode + 3000);
  }
}

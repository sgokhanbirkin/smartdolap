// ignore_for_file: public_member_api_docs, avoid_catches_without_on_clauses

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Service for managing expiry date notifications
/// Follows Single Responsibility Principle - only handles notification scheduling and cancellation
class ExpiryNotificationService {
  ExpiryNotificationService(this._notifications) {
    tz_data.initializeTimeZones();
  }

  final FlutterLocalNotificationsPlugin _notifications;
  bool _permissionChecked = false;
  bool? _permissionGranted;

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
    await _checkAndRequestPermissions();
  }

  /// Check and request notification permissions
  Future<void> _checkAndRequestPermissions() async {
    try {
      // Android permission check
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .areNotificationsEnabled();
        _permissionGranted = granted ?? false;
        _permissionChecked = true;

        if (_permissionGranted == false) {
          Logger.error('[ExpiryNotificationService] Notifications not enabled');
          await androidImplementation.requestNotificationsPermission();
          // Re-check after request
          _permissionGranted =
              await androidImplementation.areNotificationsEnabled() ?? false;
        }
      } else {
        // iOS - permissions are requested automatically
        _permissionGranted = true;
        _permissionChecked = true;
      }

      debugPrint(
        '[ExpiryNotificationService] Permission status: $_permissionGranted',
      );
    } catch (e) {
      Logger.error('[ExpiryNotificationService] Error checking permissions', e);
      _permissionGranted = false;
      _permissionChecked = true;
    }
  }

  /// Get permission status (for UI feedback)
  bool? get permissionGranted => _permissionGranted;

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap (navigate to pantry page)
    debugPrint(
      '[ExpiryNotificationService] Notification tapped: ${response.id}',
    );
  }

  /// Schedule notifications for pantry items
  /// Cancels existing notifications for each item before scheduling new ones
  Future<void> scheduleNotifications(List<PantryItem> items) async {
    if (!_permissionChecked) {
      await _checkAndRequestPermissions();
    }

    if (_permissionGranted == false) {
      Logger.error(
        '[ExpiryNotificationService] Cannot schedule notifications - permission not granted',
      );
      return;
    }

    try {
      for (final PantryItem item in items) {
        // Cancel existing notifications for this item first
        await cancelItemNotifications(item.id);

        // Schedule new notifications for this item
        await schedulePerItem(item);
      }

      debugPrint(
        '[ExpiryNotificationService] Scheduled notifications for ${items.length} items',
      );
    } catch (e) {
      Logger.error(
        '[ExpiryNotificationService] Error scheduling notifications',
        e,
      );
    }
  }

  /// Schedule notifications for a single pantry item
  /// Handles 3 days before, 1 day before, and same day notifications
  Future<void> schedulePerItem(PantryItem item) async {
    if (item.expiryDate == null) {
      return;
    }

    if (!_permissionChecked) {
      await _checkAndRequestPermissions();
    }

    if (_permissionGranted == false) {
      Logger.error(
        '[ExpiryNotificationService] Cannot schedule notification for ${item.name} - permission not granted',
      );
      return;
    }

    try {
      final DateTime now = DateTime.now();
      final DateTime expiry = item.expiryDate!;
      final Duration difference = expiry.difference(now);

      // Skip if already expired (more than 1 day ago)
      if (difference.inDays < -1) {
        debugPrint(
          '[ExpiryNotificationService] Skipping expired item: ${item.name}',
        );
        return;
      }

      // Expired notification (within last day)
      if (difference.isNegative) {
        final tz.TZDateTime scheduledDate = _convertToTZDateTime(
          now.add(const Duration(seconds: 5)),
        );
        await _scheduleNotification(
          id: item.id.hashCode,
          title: tr('expiry_expired_title'),
          body: tr(
            'expiry_expired_body',
            namedArgs: <String, String>{'name': item.name},
          ),
          scheduledDate: scheduledDate,
        );
        debugPrint(
          '[ExpiryNotificationService] Scheduled expired notification for ${item.name} @ $scheduledDate',
        );
        return;
      }

      // 3 days before expiry
      final DateTime threeDaysBefore = expiry.subtract(const Duration(days: 3));
      if (threeDaysBefore.isAfter(now) && difference.inDays >= 3) {
        final tz.TZDateTime scheduledDate = _convertToTZDateTime(
          DateTime(
            threeDaysBefore.year,
            threeDaysBefore.month,
            threeDaysBefore.day,
            9,
          ),
        );
        await _scheduleNotification(
          id: item.id.hashCode + 1000,
          title: tr('expiry_3days_title'),
          body: tr(
            'expiry_3days_body',
            namedArgs: <String, String>{'name': item.name},
          ),
          scheduledDate: scheduledDate,
        );
        debugPrint(
          '[ExpiryNotificationService] Scheduled 3-day notification for ${item.name} @ $scheduledDate',
        );
      }

      // 1 day before expiry
      final DateTime oneDayBefore = expiry.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now) && difference.inDays >= 1) {
        final tz.TZDateTime scheduledDate = _convertToTZDateTime(
          DateTime(oneDayBefore.year, oneDayBefore.month, oneDayBefore.day, 9),
        );
        await _scheduleNotification(
          id: item.id.hashCode + 2000,
          title: tr('expiry_1day_title'),
          body: tr(
            'expiry_1day_body',
            namedArgs: <String, String>{'name': item.name},
          ),
          scheduledDate: scheduledDate,
        );
        debugPrint(
          '[ExpiryNotificationService] Scheduled 1-day notification for ${item.name} @ $scheduledDate',
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
          final tz.TZDateTime scheduledDate = _convertToTZDateTime(
            expiryMorning,
          );
          await _scheduleNotification(
            id: item.id.hashCode + 3000,
            title: tr('expiry_today_title'),
            body: tr(
              'expiry_today_body',
              namedArgs: <String, String>{'name': item.name},
            ),
            scheduledDate: scheduledDate,
          );
          debugPrint(
            '[ExpiryNotificationService] Scheduled today notification for ${item.name} @ $scheduledDate',
          );
        }
      }
    } catch (e) {
      Logger.error(
        '[ExpiryNotificationService] Error scheduling notification for ${item.name}',
        e,
      );
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint(
        '[ExpiryNotificationService] Skipping notification - scheduled date is in the past',
      );
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
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) =>
      tz.TZDateTime.from(dateTime, tz.local);

  /// Cancel notification for a specific item
  /// Cancels all 4 notification IDs associated with the item
  Future<void> cancelItemNotifications(String itemId) async {
    try {
      final int baseId = itemId.hashCode;
      await _notifications.cancel(baseId);
      await _notifications.cancel(baseId + 1000);
      await _notifications.cancel(baseId + 2000);
      await _notifications.cancel(baseId + 3000);
      debugPrint(
        '[ExpiryNotificationService] Cancelled alarms for item: $itemId',
      );
    } catch (e) {
      Logger.error(
        '[ExpiryNotificationService] Error cancelling notifications for item: $itemId',
        e,
      );
    }
  }
}

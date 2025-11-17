import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Interface for expiry notification service
/// Follows Dependency Inversion Principle - depends on abstraction, not concrete implementation
abstract class IExpiryNotificationService {
  /// Schedule notifications for a single pantry item
  Future<void> schedulePerItem(PantryItem item);

  /// Schedule notifications for multiple pantry items
  Future<void> scheduleNotifications(List<PantryItem> items);

  /// Cancel all notifications for a specific item
  Future<void> cancelItemNotifications(String itemId);

  /// Schedule a custom notification (for smart notifications)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  /// Get permission status
  bool? get permissionGranted;

  /// Initialize notification service
  Future<void> initialize();
}

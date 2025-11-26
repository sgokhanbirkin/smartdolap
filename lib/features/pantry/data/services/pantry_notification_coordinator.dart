import 'package:flutter/foundation.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_notification_coordinator.dart';
import 'package:smartdolap/product/services/i_expiry_notification_service.dart';

/// Service for coordinating pantry item notifications
/// Follows Single Responsibility Principle - handles notification coordination logic
/// This service acts as a coordinator between PantryCubit and ExpiryNotificationService
class PantryNotificationCoordinator implements IPantryNotificationCoordinator {
  PantryNotificationCoordinator(this._notificationService);

  final IExpiryNotificationService _notificationService;

  /// Handle notification scheduling when a new item is added
  @override
  Future<void> handleItemAdded(PantryItem item) async {
    if (item.expiryDate != null) {
      try {
        await _notificationService.schedulePerItem(item);
      } on Object catch (error, stackTrace) {
        // Log error but don't fail the operation
        debugPrint(
          '[PantryNotificationCoordinator] Error scheduling notification for new item: $error\n$stackTrace',
        );
      }
    }
  }

  /// Handle notification updates when an item is updated
  @override
  Future<void> handleItemUpdated(PantryItem oldItem, PantryItem newItem) async {
    final bool expiryDateChanged = oldItem.expiryDate != newItem.expiryDate;
    if (expiryDateChanged) {
      try {
        // Cancel old notifications
        await _notificationService.cancelItemNotifications(newItem.id);

        // Schedule new notifications if item has expiry date
        if (newItem.expiryDate != null) {
          await _notificationService.schedulePerItem(newItem);
        }
      } on Object catch (error, stackTrace) {
        debugPrint(
          '[PantryNotificationCoordinator] Error updating notifications: $error\n$stackTrace',
        );
      }
    }
  }

  /// Handle notification cancellation when an item is deleted
  @override
  Future<void> handleItemDeleted(String itemId) async {
    try {
      await _notificationService.cancelItemNotifications(itemId);
    } on Object catch (error, stackTrace) {
      debugPrint(
        '[PantryNotificationCoordinator] Error cancelling notifications: $error\n$stackTrace',
      );
    }
  }

  /// Schedule notifications for a list of items (used when pantry is loaded)
  @override
  Future<void> scheduleForItems(List<PantryItem> items) async {
    try {
      await _notificationService.scheduleNotifications(items);
    } on Object catch (error, stackTrace) {
      debugPrint(
        '[PantryNotificationCoordinator] Error scheduling notifications: $error\n$stackTrace',
      );
    }
  }
}

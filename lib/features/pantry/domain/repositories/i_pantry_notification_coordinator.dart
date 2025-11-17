import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Interface for coordinating pantry item notifications
/// Follows Dependency Inversion Principle (DIP)
abstract class IPantryNotificationCoordinator {
  /// Handle notification scheduling when a new item is added
  Future<void> handleItemAdded(PantryItem item);

  /// Handle notification updates when an item is updated
  Future<void> handleItemUpdated(PantryItem oldItem, PantryItem newItem);

  /// Handle notification cancellation when an item is deleted
  Future<void> handleItemDeleted(String itemId);

  /// Schedule notifications for a list of items (used when pantry is loaded)
  Future<void> scheduleForItems(List<PantryItem> items);
}

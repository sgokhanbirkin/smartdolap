import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Interface for debounced notification scheduling
/// Follows Dependency Inversion Principle (DIP)
abstract class IPantryNotificationScheduler {
  /// Schedule notifications for items with debouncing
  /// Returns true if scheduling was actually performed, false if debounced
  Future<bool> scheduleDebounced(List<PantryItem> items);

  /// Cancel any pending debounced scheduling
  void cancelPending();

  /// Dispose resources
  void dispose();
}

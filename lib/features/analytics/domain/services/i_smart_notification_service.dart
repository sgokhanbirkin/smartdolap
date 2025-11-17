/// Service interface for smart notifications
/// Follows Dependency Inversion Principle (DIP)
abstract class ISmartNotificationService {
  /// Check and send dietary suggestions
  Future<void> checkAndSendDietarySuggestions({
    required String userId,
    required String householdId,
  });

  /// Check and send low stock notifications
  Future<void> checkAndSendLowStockNotifications({required String householdId});

  /// Schedule smart notifications
  Future<void> scheduleSmartNotifications({required String householdId});
}

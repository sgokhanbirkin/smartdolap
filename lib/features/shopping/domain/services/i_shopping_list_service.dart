/// Service interface for shopping list operations
/// Follows Dependency Inversion Principle (DIP)
abstract class IShoppingListService {
  /// Add item to pantry from shopping list
  Future<void> addToPantryFromShoppingList({
    required String householdId,
    required String itemId,
    required String userId,
    String? avatarId,
  });

  /// Complete item and add to pantry
  Future<void> completeAndAddToPantry({
    required String householdId,
    required String itemId,
    required String userId,
    String? avatarId,
  });
}

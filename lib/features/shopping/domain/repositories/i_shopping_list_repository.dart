import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';

/// Repository interface for shopping list
/// Follows Dependency Inversion Principle (DIP)
abstract class IShoppingListRepository {
  /// Watch shopping list items as a stream
  Stream<List<ShoppingListItem>> watchItems({
    required String householdId,
  });

  /// Get shopping list items
  Future<List<ShoppingListItem>> getItems({
    required String householdId,
  });

  /// Add a shopping list item
  Future<ShoppingListItem> addItem({
    required String householdId,
    required ShoppingListItem item,
  });

  /// Update a shopping list item
  Future<ShoppingListItem> updateItem({
    required String householdId,
    required ShoppingListItem item,
  });

  /// Delete a shopping list item
  Future<void> deleteItem({
    required String householdId,
    required String itemId,
  });

  /// Complete a shopping list item
  Future<ShoppingListItem> completeItem({
    required String householdId,
    required String itemId,
    required String completedByUserId,
  });
}


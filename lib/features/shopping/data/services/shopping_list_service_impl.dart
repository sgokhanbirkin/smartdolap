import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';
import 'package:smartdolap/features/shopping/domain/services/i_shopping_list_service.dart';
import 'package:uuid/uuid.dart';

/// Service implementation for shopping list operations
class ShoppingListServiceImpl implements IShoppingListService {
  ShoppingListServiceImpl(this._shoppingListRepository, this._pantryRepository);

  final IShoppingListRepository _shoppingListRepository;
  final IPantryRepository _pantryRepository;
  static const Uuid _uuid = Uuid();

  @override
  Future<void> addToPantryFromShoppingList({
    required String householdId,
    required String itemId,
    required String userId,
    String? avatarId,
  }) async {
    try {
      // Get shopping list item
      final List<ShoppingListItem> items = await _shoppingListRepository
          .getItems(householdId: householdId);
      final ShoppingListItem item = items.firstWhere(
        (ShoppingListItem i) => i.id == itemId,
        orElse: () => throw Exception('Shopping list item not found: $itemId'),
      );

      // Create pantry item from shopping list item
      final PantryItem pantryItem = PantryItem(
        id: _uuid.v4(),
        name: item.name,
        quantity: item.quantity ?? 1.0,
        unit: item.unit ?? 'adet',
        category: item.category,
        addedByUserId: userId,
        addedByAvatarId: avatarId,
        createdAt: DateTime.now(),
      );

      // Add to pantry
      await _pantryRepository.addItem(
        householdId: householdId,
        item: pantryItem,
      );

      Logger.info(
        '[ShoppingListService] Added ${pantryItem.name} to pantry from shopping list',
      );
    } catch (e) {
      Logger.error(
        '[ShoppingListService] Error adding to pantry from shopping list',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<void> completeAndAddToPantry({
    required String householdId,
    required String itemId,
    required String userId,
    String? avatarId,
  }) async {
    try {
      // Complete the item first
      await _shoppingListRepository.completeItem(
        householdId: householdId,
        itemId: itemId,
        completedByUserId: userId,
      );

      // Then add to pantry
      await addToPantryFromShoppingList(
        householdId: householdId,
        itemId: itemId,
        userId: userId,
        avatarId: avatarId,
      );

      Logger.info('[ShoppingListService] Completed and added item to pantry');
    } catch (e) {
      Logger.error(
        '[ShoppingListService] Error completing and adding to pantry',
        e,
      );
      rethrow;
    }
  }

  @override
  Future<int> completeAllCompletedAndAddToPantry({
    required String householdId,
    required String userId,
    String? avatarId,
  }) async {
    try {
      // Get all shopping list items
      final List<ShoppingListItem> items = await _shoppingListRepository
          .getItems(householdId: householdId);

      // Filter completed items
      final List<ShoppingListItem> completedItems = items
          .where((ShoppingListItem item) => item.isCompleted)
          .toList();

      if (completedItems.isEmpty) {
        Logger.info('[ShoppingListService] No completed items to add to pantry');
        return 0;
      }

      int addedCount = 0;

      // Add each completed item to pantry
      for (final ShoppingListItem item in completedItems) {
        try {
          // Create pantry item from shopping list item
          final PantryItem pantryItem = PantryItem(
            id: _uuid.v4(),
            name: item.name,
            quantity: item.quantity ?? 1.0,
            unit: item.unit ?? 'adet',
            category: item.category, // Category already determined when adding to shopping list
            addedByUserId: userId,
            addedByAvatarId: avatarId,
            createdAt: DateTime.now(),
          );

          // Add to pantry
          await _pantryRepository.addItem(
            householdId: householdId,
            item: pantryItem,
          );

          // Delete from shopping list
          await _shoppingListRepository.deleteItem(
            householdId: householdId,
            itemId: item.id,
          );

          addedCount++;
          Logger.info(
            '[ShoppingListService] Added ${pantryItem.name} to pantry and removed from shopping list',
          );
        } catch (e) {
          Logger.error(
            '[ShoppingListService] Error adding ${item.name} to pantry',
            e,
          );
          // Continue with next item instead of failing completely
        }
      }

      Logger.info(
        '[ShoppingListService] Completed and added $addedCount items to pantry',
      );
      return addedCount;
    } catch (e) {
      Logger.error(
        '[ShoppingListService] Error completing all and adding to pantry',
        e,
      );
      rethrow;
    }
  }
}

import 'package:smartdolap/features/shopping/domain/services/i_shopping_list_service.dart';

/// Use case for adding item to pantry from shopping list
class AddToPantryFromShoppingListUseCase {
  /// Creates a use case
  AddToPantryFromShoppingListUseCase(this._service);

  final IShoppingListService _service;

  /// Add item to pantry from shopping list
  Future<void> call({
    required String householdId,
    required String itemId,
    required String userId,
    String? avatarId,
  }) async {
    return _service.addToPantryFromShoppingList(
      householdId: householdId,
      itemId: itemId,
      userId: userId,
      avatarId: avatarId,
    );
  }
}

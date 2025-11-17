import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';

/// Use case for deleting shopping list item
class DeleteShoppingListItemUseCase {
  /// Creates a use case
  DeleteShoppingListItemUseCase(this._repository);

  final IShoppingListRepository _repository;

  /// Delete shopping list item
  Future<void> call({
    required String householdId,
    required String itemId,
  }) async {
    return _repository.deleteItem(householdId: householdId, itemId: itemId);
  }
}

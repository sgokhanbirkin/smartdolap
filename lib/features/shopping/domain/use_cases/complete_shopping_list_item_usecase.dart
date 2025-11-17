import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';

/// Use case for completing shopping list item
class CompleteShoppingListItemUseCase {
  /// Creates a use case
  CompleteShoppingListItemUseCase(this._repository);

  final IShoppingListRepository _repository;

  /// Complete shopping list item
  Future<ShoppingListItem> call({
    required String householdId,
    required String itemId,
    required String completedByUserId,
  }) async {
    return _repository.completeItem(
      householdId: householdId,
      itemId: itemId,
      completedByUserId: completedByUserId,
    );
  }
}

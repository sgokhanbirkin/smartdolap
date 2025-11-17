import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';

/// Use case for updating shopping list item
class UpdateShoppingListItemUseCase {
  /// Creates a use case
  UpdateShoppingListItemUseCase(this._repository);

  final IShoppingListRepository _repository;

  /// Update shopping list item
  Future<ShoppingListItem> call({
    required String householdId,
    required ShoppingListItem item,
  }) async {
    return _repository.updateItem(
      householdId: householdId,
      item: item,
    );
  }
}


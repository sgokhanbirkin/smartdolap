import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';

/// Use case for adding shopping list item
class AddShoppingListItemUseCase {
  /// Creates a use case
  AddShoppingListItemUseCase(this._repository);

  final IShoppingListRepository _repository;

  /// Add shopping list item
  Future<ShoppingListItem> call({
    required String householdId,
    required ShoppingListItem item,
  }) async => _repository.addItem(householdId: householdId, item: item);
}

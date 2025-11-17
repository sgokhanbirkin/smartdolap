// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';

/// Shopping list state base class
abstract class ShoppingListState {
  const ShoppingListState();
}

class ShoppingListInitial extends ShoppingListState {
  const ShoppingListInitial();
}

class ShoppingListLoading extends ShoppingListState {
  const ShoppingListLoading();
}

class ShoppingListLoaded extends ShoppingListState {
  const ShoppingListLoaded(this.items);
  final List<ShoppingListItem> items;
}

class ShoppingListFailure extends ShoppingListState {
  const ShoppingListFailure(this.message);
  final String message;
}

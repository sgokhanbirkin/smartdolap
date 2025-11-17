import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/add_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/complete_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/delete_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/domain/use_cases/update_shopping_list_item_usecase.dart';
import 'package:smartdolap/features/shopping/presentation/viewmodel/shopping_list_state.dart';

/// Cubit for managing shopping list state
class ShoppingListCubit extends Cubit<ShoppingListState> {
  ShoppingListCubit({
    required this.shoppingListRepository,
    required this.addShoppingListItem,
    required this.updateShoppingListItem,
    required this.deleteShoppingListItem,
    required this.completeShoppingListItem,
  }) : super(const ShoppingListInitial());

  final IShoppingListRepository shoppingListRepository;
  final AddShoppingListItemUseCase addShoppingListItem;
  final UpdateShoppingListItemUseCase updateShoppingListItem;
  final DeleteShoppingListItemUseCase deleteShoppingListItem;
  final CompleteShoppingListItemUseCase completeShoppingListItem;

  StreamSubscription<List<ShoppingListItem>>? _sub;

  Future<void> watch(String householdId) async {
    emit(const ShoppingListLoading());
    await _sub?.cancel();
    _sub = shoppingListRepository
        .watchItems(householdId: householdId)
        .listen(
          (List<ShoppingListItem> items) => emit(ShoppingListLoaded(items)),
          onError: (Object e) {
            Logger.error('[ShoppingListCubit] Error watching items', e);
            emit(ShoppingListFailure(e.toString()));
          },
        );
  }

  Future<void> refresh(String householdId) async {
    await watch(householdId);
  }

  Future<void> add(String householdId, ShoppingListItem item) async {
    try {
      await addShoppingListItem(householdId: householdId, item: item);
      Logger.info('[ShoppingListCubit] Added item: ${item.name}');
    } catch (e) {
      Logger.error('[ShoppingListCubit] Error adding item', e);
      emit(ShoppingListFailure(e.toString()));
    }
  }

  Future<void> update(String householdId, ShoppingListItem item) async {
    try {
      await updateShoppingListItem(householdId: householdId, item: item);
      Logger.info('[ShoppingListCubit] Updated item: ${item.name}');
    } catch (e) {
      Logger.error('[ShoppingListCubit] Error updating item', e);
      emit(ShoppingListFailure(e.toString()));
    }
  }

  Future<void> delete(String householdId, String itemId) async {
    try {
      await deleteShoppingListItem(householdId: householdId, itemId: itemId);
      Logger.info('[ShoppingListCubit] Deleted item: $itemId');
    } catch (e) {
      Logger.error('[ShoppingListCubit] Error deleting item', e);
      emit(ShoppingListFailure(e.toString()));
    }
  }

  Future<void> complete(
    String householdId,
    String itemId,
    String userId,
  ) async {
    try {
      await completeShoppingListItem(
        householdId: householdId,
        itemId: itemId,
        completedByUserId: userId,
      );
      Logger.info('[ShoppingListCubit] Completed item: $itemId');
    } catch (e) {
      Logger.error('[ShoppingListCubit] Error completing item', e);
      emit(ShoppingListFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

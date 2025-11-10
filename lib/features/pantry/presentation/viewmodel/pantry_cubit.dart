// ignore_for_file: public_member_api_docs, avoid_catches_without_on_clauses

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/data/services/pantry_notification_coordinator.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';

/// Pantry Cubit - Manages pantry state and operations
/// Follows Single Responsibility Principle - only handles pantry state management
/// Notification scheduling is delegated to PantryNotificationCoordinator (SRP)
class PantryCubit extends Cubit<PantryState> {
  PantryCubit({
    required this.listPantryItems,
    required this.addPantryItem,
    required this.updatePantryItem,
    required this.deletePantryItem,
    required this.notificationCoordinator,
  }) : super(const PantryInitial());

  final ListPantryItems listPantryItems;
  final AddPantryItem addPantryItem;
  final UpdatePantryItem updatePantryItem;
  final DeletePantryItem deletePantryItem;
  final PantryNotificationCoordinator notificationCoordinator;

  StreamSubscription<List<PantryItem>>? _sub;

  Future<void> watch(String userId) async {
    emit(const PantryLoading());
    await _sub?.cancel();
    _sub = listPantryItems(userId: userId).listen(
      (List<PantryItem> items) => emit(PantryLoaded(items)),
      onError: (Object e) => emit(PantryFailure(e.toString())),
    );
  }

  Future<void> refresh(String userId) async {
    await watch(userId);
  }

  Future<void> add(String userId, PantryItem item) async {
    try {
      await addPantryItem(userId: userId, item: item);
      // Delegate notification scheduling to coordinator
      await notificationCoordinator.handleItemAdded(item);
    } catch (e) {
      emit(PantryFailure(e.toString()));
    }
  }

  Future<void> update(String userId, PantryItem item) async {
    try {
      // Get old item to check if expiry date changed
      final PantryState currentState = state;
      PantryItem? oldItem;
      if (currentState is PantryLoaded) {
        oldItem = currentState.items.firstWhere(
          (PantryItem i) => i.id == item.id,
          orElse: () => item,
        );
      }

      await updatePantryItem(userId: userId, item: item);

      // Delegate notification updates to coordinator
      if (oldItem != null) {
        await notificationCoordinator.handleItemUpdated(oldItem, item);
      }
    } catch (e) {
      emit(PantryFailure(e.toString()));
    }
  }

  Future<void> remove(String userId, String itemId) async {
    try {
      await deletePantryItem(userId: userId, itemId: itemId);
      // Delegate notification cancellation to coordinator
      await notificationCoordinator.handleItemDeleted(itemId);
    } catch (e) {
      emit(PantryFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

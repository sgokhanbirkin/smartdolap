// ignore_for_file: public_member_api_docs, avoid_catches_without_on_clauses

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';
import 'package:smartdolap/product/services/expiry_notification_service.dart';

/// Pantry Cubit - Manages pantry state and operations
/// Follows Single Responsibility Principle - only handles pantry state management
class PantryCubit extends Cubit<PantryState> {
  PantryCubit({
    required this.listPantryItems,
    required this.addPantryItem,
    required this.updatePantryItem,
    required this.deletePantryItem,
    required this.expiryNotificationService,
  }) : super(const PantryInitial());

  final ListPantryItems listPantryItems;
  final AddPantryItem addPantryItem;
  final UpdatePantryItem updatePantryItem;
  final DeletePantryItem deletePantryItem;
  final ExpiryNotificationService expiryNotificationService;

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
      // Schedule notification for new item if it has expiry date
      if (item.expiryDate != null) {
        try {
          await expiryNotificationService.schedulePerItem(item);
          debugPrint(
            '[PantryCubit] Scheduled notification for new item: ${item.name}',
          );
        } catch (e) {
          Logger.error(
            '[PantryCubit] Error scheduling notification for new item',
            e,
          );
        }
      }
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

      // Cancel old notifications and schedule new ones if expiry date changed
      final bool expiryDateChanged = oldItem?.expiryDate != item.expiryDate;
      if (expiryDateChanged) {
        try {
          // Cancel old notifications
          await expiryNotificationService.cancelItemNotifications(item.id);
          debugPrint(
            '[PantryCubit] Cancelled old notifications for item: ${item.name}',
          );

          // Schedule new notifications if item has expiry date
          if (item.expiryDate != null) {
            await expiryNotificationService.schedulePerItem(item);
            debugPrint(
              '[PantryCubit] Scheduled new notifications for updated item: ${item.name}',
            );
          }
        } catch (e) {
          Logger.error(
            '[PantryCubit] Error updating notifications for item',
            e,
          );
        }
      }
    } catch (e) {
      emit(PantryFailure(e.toString()));
    }
  }

  Future<void> remove(String userId, String itemId) async {
    try {
      // Get item before deletion to cancel its notifications
      final PantryState currentState = state;
      PantryItem? itemToDelete;
      if (currentState is PantryLoaded) {
        itemToDelete = currentState.items.firstWhere(
          (PantryItem i) => i.id == itemId,
          orElse: () => PantryItem(id: itemId, name: ''),
        );
      }

      await deletePantryItem(userId: userId, itemId: itemId);

      // Cancel notifications for deleted item
      if (itemToDelete != null) {
        try {
          await expiryNotificationService.cancelItemNotifications(itemId);
          debugPrint(
            '[PantryCubit] Cancelled notifications for deleted item: ${itemToDelete.name}',
          );
        } catch (e) {
          Logger.error(
            '[PantryCubit] Error cancelling notifications for deleted item',
            e,
          );
        }
      }
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

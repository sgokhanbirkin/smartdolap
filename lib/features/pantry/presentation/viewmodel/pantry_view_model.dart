import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_notification_coordinator.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';

/// PantryViewModel - Business logic orchestration following MVVM pattern
///
/// Responsibilities:
/// - Orchestrate business logic between Use Cases and Cubit
/// - Handle data transformations
/// - Manage stream subscriptions
/// - Coordinate with notification services
///
/// SOLID Principles:
/// - Single Responsibility: Only handles pantry business logic orchestration
/// - Open/Closed: New operations can be added without modifying existing
/// - Dependency Inversion: Depends on abstractions (Use Cases, Interfaces)
/// - Interface Segregation: Uses specific use cases instead of fat interfaces
class PantryViewModel {
  /// Creates a PantryViewModel with required dependencies
  PantryViewModel({
    required PantryCubit cubit,
    required ListPantryItems listPantryItems,
    required AddPantryItem addPantryItem,
    required UpdatePantryItem updatePantryItem,
    required DeletePantryItem deletePantryItem,
    required IPantryNotificationCoordinator notificationCoordinator,
  })  : _cubit = cubit,
        _listPantryItems = listPantryItems,
        _addPantryItem = addPantryItem,
        _updatePantryItem = updatePantryItem,
        _deletePantryItem = deletePantryItem,
        _notificationCoordinator = notificationCoordinator;

  final PantryCubit _cubit;
  final ListPantryItems _listPantryItems;
  final AddPantryItem _addPantryItem;
  final UpdatePantryItem _updatePantryItem;
  final DeletePantryItem _deletePantryItem;
  final IPantryNotificationCoordinator _notificationCoordinator;

  StreamSubscription<List<PantryItem>>? _subscription;

  /// Starts watching pantry items for a household
  ///
  /// Sets up a stream subscription to listen for real-time updates
  /// from the repository. Updates are automatically reflected in the UI
  /// through the Cubit state.
  Future<void> watch(String householdId) async {
    _cubit.setLoading();
    await _subscription?.cancel();

    _subscription = _listPantryItems(householdId: householdId).listen(
      (List<PantryItem> items) {
        debugPrint('[PantryViewModel] Received ${items.length} items');
        _cubit.setLoaded(items);
      },
      onError: (Object error) {
        debugPrint('[PantryViewModel] Stream error: $error');
        _cubit.setError('pantry_load_error');
      },
    );
  }

  /// Refreshes pantry items
  ///
  /// Re-initializes the stream subscription to fetch latest data
  Future<void> refresh(String householdId) async {
    await watch(householdId);
  }

  /// Adds a new pantry item
  ///
  /// 1. Calls the add use case to persist the item
  /// 2. Schedules notifications through the coordinator
  /// 3. Stream will automatically update the UI
  Future<void> add(String householdId, PantryItem item) async {
    try {
      await _addPantryItem(householdId: householdId, item: item);
      await _notificationCoordinator.handleItemAdded(item);
      debugPrint('[PantryViewModel] Item added: ${item.name}');
    } on Exception catch (e) {
      debugPrint('[PantryViewModel] Add error: $e');
      _cubit.setError('pantry_add_error');
    }
  }

  /// Updates an existing pantry item
  ///
  /// 1. Gets the old item from current state for comparison
  /// 2. Calls the update use case to persist changes
  /// 3. Updates notifications if expiry date changed
  /// 4. Stream will automatically update the UI
  Future<void> update(String householdId, PantryItem item) async {
    try {
      // Get old item to check if expiry date changed
      final List<PantryItem>? currentItems = _cubit.currentItems;
      PantryItem? oldItem;
      if (currentItems != null) {
        oldItem = currentItems.firstWhere(
          (PantryItem i) => i.id == item.id,
          orElse: () => item,
        );
      }

      await _updatePantryItem(householdId: householdId, item: item);

      // Update notifications if item had expiry date change
      if (oldItem != null) {
        await _notificationCoordinator.handleItemUpdated(oldItem, item);
      }

      debugPrint('[PantryViewModel] Item updated: ${item.name}');
    } on Exception catch (e) {
      debugPrint('[PantryViewModel] Update error: $e');
      _cubit.setError('pantry_update_error');
    }
  }

  /// Removes a pantry item
  ///
  /// 1. Calls the delete use case to remove the item
  /// 2. Cancels any scheduled notifications for this item
  /// 3. Stream will automatically update the UI
  Future<void> remove(String householdId, String itemId) async {
    try {
      await _deletePantryItem(householdId: householdId, itemId: itemId);
      await _notificationCoordinator.handleItemDeleted(itemId);
      debugPrint('[PantryViewModel] Item removed: $itemId');
    } on Exception catch (e) {
      debugPrint('[PantryViewModel] Remove error: $e');
      _cubit.setError('pantry_delete_error');
    }
  }

  /// Finds an item by ID from current state
  PantryItem? findItem(String itemId) {
    final List<PantryItem>? items = _cubit.currentItems;
    if (items == null) {
      return null;
    }
    return items.cast<PantryItem?>().firstWhere(
          (PantryItem? i) => i != null && i.id == itemId,
          orElse: () => null,
        );
  }

  /// Disposes resources
  ///
  /// Must be called when the ViewModel is no longer needed
  /// to prevent memory leaks from stream subscriptions
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('[PantryViewModel] Disposed');
  }
}


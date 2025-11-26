// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

part 'pantry_state.dart';

/// Pantry Cubit - State-only implementation following MVVM pattern
///
/// Responsibilities:
/// - Emit state changes only
/// - No business logic (delegated to PantryViewModel)
///
/// SOLID Principles:
/// - Single Responsibility: Only handles state emission
/// - Open/Closed: State types can be extended without modifying cubit
/// - Dependency Inversion: Depends on abstract state types
class PantryCubit extends Cubit<PantryState> {
  /// Creates a PantryCubit with initial state
  PantryCubit() : super(const PantryState.initial());

  /// Sets loading state
  void setLoading() => emit(const PantryState.loading());

  /// Sets loaded state with items
  void setLoaded(List<PantryItem> items) => emit(PantryState.loaded(items));

  /// Sets error state with localized message key
  void setError(String messageKey) => emit(PantryState.failure(messageKey));

  /// Updates items in loaded state (for optimistic updates)
  void updateItems(List<PantryItem> items) {
    final PantryState currentState = state;
    if (currentState is _PantryLoaded) {
      emit(PantryState.loaded(items));
    }
  }

  /// Adds single item to current list (optimistic update)
  void addItem(PantryItem item) {
    final PantryState currentState = state;
    if (currentState is _PantryLoaded) {
      final List<PantryItem> updatedItems = <PantryItem>[
        ...currentState.items,
        item,
      ];
      emit(PantryState.loaded(updatedItems));
    }
  }

  /// Removes single item from current list (optimistic update)
  void removeItem(String itemId) {
    final PantryState currentState = state;
    if (currentState is _PantryLoaded) {
      final List<PantryItem> updatedItems = currentState.items
          .where((PantryItem i) => i.id != itemId)
          .toList();
      emit(PantryState.loaded(updatedItems));
    }
  }

  /// Updates single item in current list (optimistic update)
  void updateItem(PantryItem item) {
    final PantryState currentState = state;
    if (currentState is _PantryLoaded) {
      final List<PantryItem> updatedItems = currentState.items
          .map((PantryItem i) => i.id == item.id ? item : i)
          .toList();
      emit(PantryState.loaded(updatedItems));
    }
  }

  /// Gets current items if in loaded state
  List<PantryItem>? get currentItems {
    final PantryState currentState = state;
    if (currentState is _PantryLoaded) {
      return currentState.items;
    }
    return null;
  }
}

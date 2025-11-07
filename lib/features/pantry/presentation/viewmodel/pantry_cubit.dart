// ignore_for_file: public_member_api_docs, avoid_catches_without_on_clauses

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';

class PantryCubit extends Cubit<PantryState> {
  PantryCubit({
    required this.listPantryItems,
    required this.addPantryItem,
    required this.updatePantryItem,
    required this.deletePantryItem,
  }) : super(const PantryInitial());

  final ListPantryItems listPantryItems;
  final AddPantryItem addPantryItem;
  final UpdatePantryItem updatePantryItem;
  final DeletePantryItem deletePantryItem;

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
    } catch (e) {
      emit(PantryFailure(e.toString()));
    }
  }

  Future<void> update(String userId, PantryItem item) async {
    try {
      await updatePantryItem(userId: userId, item: item);
    } catch (e) {
      emit(PantryFailure(e.toString()));
    }
  }

  Future<void> remove(String userId, String itemId) async {
    try {
      await deletePantryItem(userId: userId, itemId: itemId);
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

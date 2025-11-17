// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';

/// Use case to add a pantry item
class AddPantryItem {
  const AddPantryItem(this.repository);

  final IPantryRepository repository;

  Future<PantryItem> call({
    required String householdId,
    required PantryItem item,
  }) =>
      repository.addItem(householdId: householdId, item: item);
}

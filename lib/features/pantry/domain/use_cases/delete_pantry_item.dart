// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';

/// Use case to delete a pantry item
class DeletePantryItem {
  const DeletePantryItem(this.repository);

  final IPantryRepository repository;

  Future<void> call({
    required String householdId,
    required String itemId,
  }) =>
      repository.deleteItem(householdId: householdId, itemId: itemId);
}

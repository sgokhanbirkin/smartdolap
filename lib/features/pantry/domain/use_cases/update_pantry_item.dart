// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';

/// Use case to update a pantry item
class UpdatePantryItem {
  const UpdatePantryItem(this.repository);

  final IPantryRepository repository;

  Future<PantryItem> call({required String userId, required PantryItem item}) =>
      repository.updateItem(userId: userId, item: item);
}

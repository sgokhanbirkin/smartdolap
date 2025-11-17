// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';

/// Use case to watch pantry items stream
class ListPantryItems {
  const ListPantryItems(this.repository);

  final IPantryRepository repository;

  Stream<List<PantryItem>> call({required String householdId}) =>
      repository.watchItems(householdId: householdId);
}

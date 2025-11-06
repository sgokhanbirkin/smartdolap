// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Pantry state base class
abstract class PantryState {
  const PantryState();
}

class PantryInitial extends PantryState {
  const PantryInitial();
}

class PantryLoading extends PantryState {
  const PantryLoading();
}

class PantryLoaded extends PantryState {
  const PantryLoaded(this.items);
  final List<PantryItem> items;
}

class PantryFailure extends PantryState {
  const PantryFailure(this.message);
  final String message;
}

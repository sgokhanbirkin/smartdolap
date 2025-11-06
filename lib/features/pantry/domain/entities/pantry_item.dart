// ignore_for_file: public_member_api_docs, always_use_package_imports

import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';

/// PantryItem entity stored under /users/{uid}/pantry/{itemId}
class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    this.quantity = 1.0,
    this.unit = '',
    this.expiryDate,
    this.ingredients = const <Ingredient>[],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final List<Ingredient> ingredients;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PantryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    List<Ingredient>? ingredients,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PantryItem(
    id: id ?? this.id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    expiryDate: expiryDate ?? this.expiryDate,
    ingredients: ingredients ?? this.ingredients,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

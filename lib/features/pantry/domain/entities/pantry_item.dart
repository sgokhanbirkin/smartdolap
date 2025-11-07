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
    this.imageUrl,
    this.ingredients = const <Ingredient>[],
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final DateTime? expiryDate;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PantryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    DateTime? expiryDate,
    String? imageUrl,
    List<Ingredient>? ingredients,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PantryItem(
    id: id ?? this.id,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    expiryDate: expiryDate ?? this.expiryDate,
    imageUrl: imageUrl ?? this.imageUrl,
    ingredients: ingredients ?? this.ingredients,
    category: category ?? this.category,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

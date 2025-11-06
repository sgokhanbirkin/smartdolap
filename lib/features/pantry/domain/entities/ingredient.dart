// ignore_for_file: public_member_api_docs
/// Ingredient entity used for pantry items and recipe suggestions
class Ingredient {
  const Ingredient({required this.name, this.unit = '', this.quantity = 1.0});

  final String name;
  final String unit;
  final double quantity;

  Ingredient copyWith({String? name, String? unit, double? quantity}) =>
      Ingredient(
        name: name ?? this.name,
        unit: unit ?? this.unit,
        quantity: quantity ?? this.quantity,
      );
}

// ignore_for_file: public_member_api_docs

/// Domain entity representing a scanned product from barcode lookup
/// This is the core business model, independent of data sources
class ScannedProduct {
  /// Product barcode (EAN-13, UPC, etc.)
  final String barcode;

  /// Product name
  final String name;

  /// Brand name (optional)
  final String? brand;

  /// Product category (e.g., "dairy", "vegetables")
  final String? category;

  /// Product image URL
  final String? imageUrl;

  /// Package quantity/size (e.g., "500g", "1L")
  final String? packageQuantity;

  /// Parsed quantity amount (e.g., 500.0)
  final double? amount;

  /// Parsed quantity unit (e.g., "g", "L", "kg")
  final String? unit;

  /// Nutritional information per 100g/100ml
  final NutritionInfo? nutrition;

  /// Data source (for transparency)
  final String? dataSource;

  const ScannedProduct({
    required this.barcode,
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.packageQuantity,
    this.amount,
    this.unit,
    this.nutrition,
    this.dataSource,
  });

  /// Create a copy with updated fields
  ScannedProduct copyWith({
    String? barcode,
    String? name,
    String? brand,
    String? category,
    String? imageUrl,
    String? packageQuantity,
    double? amount,
    String? unit,
    NutritionInfo? nutrition,
    String? dataSource,
  }) {
    return ScannedProduct(
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      packageQuantity: packageQuantity ?? this.packageQuantity,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      nutrition: nutrition ?? this.nutrition,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}

/// Nutritional information entity
class NutritionInfo {
  /// Calories per 100g/100ml
  final double? caloriesPer100g;

  /// Protein in grams per 100g/100ml
  final double? proteinPer100g;

  /// Carbohydrates in grams per 100g/100ml
  final double? carbsPer100g;

  /// Fat in grams per 100g/100ml
  final double? fatPer100g;

  /// Fiber in grams per 100g/100ml
  final double? fiberPer100g;

  /// Sugar in grams per 100g/100ml
  final double? sugarPer100g;

  /// Sodium in milligrams per 100g/100ml
  final double? sodiumPer100g;

  const NutritionInfo({
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.sodiumPer100g,
  });

  /// Check if nutrition data is available
  bool get hasData =>
      caloriesPer100g != null ||
      proteinPer100g != null ||
      carbsPer100g != null ||
      fatPer100g != null;

  /// Create a copy with updated fields
  NutritionInfo copyWith({
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? fiberPer100g,
    double? sugarPer100g,
    double? sodiumPer100g,
  }) => NutritionInfo(
    caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
    proteinPer100g: proteinPer100g ?? this.proteinPer100g,
    carbsPer100g: carbsPer100g ?? this.carbsPer100g,
    fatPer100g: fatPer100g ?? this.fatPer100g,
    fiberPer100g: fiberPer100g ?? this.fiberPer100g,
    sugarPer100g: sugarPer100g ?? this.sugarPer100g,
    sodiumPer100g: sodiumPer100g ?? this.sodiumPer100g,
  );
}

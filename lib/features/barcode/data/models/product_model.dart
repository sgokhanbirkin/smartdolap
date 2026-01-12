// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';

/// Data model for product information from external APIs
/// Handles JSON serialization/deserialization
///
/// This is the data layer representation, separate from domain entity
class ProductModel {
  const ProductModel({
    required this.barcode,
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.packageQuantity,
    this.nutrition,
    this.dataSource,
  });

  /// Create from JSON (OpenFoodFacts API format)
  factory ProductModel.fromOpenFoodFactsJson(
    Map<String, dynamic> json,
    String barcode,
  ) {
    // Extract nested product data
    final Map<String, dynamic>? product =
        json['product'] as Map<String, dynamic>?;

    if (product == null) {
      throw const FormatException('Invalid product data structure');
    }

    // Extract nutrition data
    final Map<String, dynamic>? nutriments =
        product['nutriments'] as Map<String, dynamic>?;

    return ProductModel(
      barcode: barcode,
      name:
          _extractString(product, 'product_name') ??
          _extractString(product, 'product_name_en') ??
          'Unknown Product',
      brand: _extractString(product, 'brands'),
      category: _extractCategory(product),
      imageUrl:
          _extractString(product, 'image_url') ??
          _extractString(product, 'image_front_url'),
      packageQuantity: _extractString(product, 'quantity'),
      nutrition: nutriments != null
          ? NutritionInfoModel.fromOpenFoodFactsJson(nutriments)
          : null,
      dataSource: 'OpenFoodFacts',
    );
  }

  /// Convert from domain entity
  factory ProductModel.fromEntity(ScannedProduct entity) => ProductModel(
    barcode: entity.barcode,
    name: entity.name,
    brand: entity.brand,
    category: entity.category,
    imageUrl: entity.imageUrl,
    packageQuantity: entity.packageQuantity,
    nutrition: entity.nutrition != null
        ? NutritionInfoModel.fromEntity(entity.nutrition!)
        : null,
    dataSource: entity.dataSource,
  );

  /// Create from generic JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    barcode: json['barcode'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String?,
    category: json['category'] as String?,
    imageUrl: json['imageUrl'] as String?,
    packageQuantity: json['packageQuantity'] as String?,
    nutrition: json['nutrition'] != null
        ? NutritionInfoModel.fromJson(json['nutrition'] as Map<String, dynamic>)
        : null,
    dataSource: json['dataSource'] as String?,
  );
  final String barcode;
  final String name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final String? packageQuantity;
  final NutritionInfoModel? nutrition;
  final String? dataSource;

  /// Extract string safely from JSON
  static String? _extractString(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value == null || value == '') {
      return null;
    }
    return value.toString().trim();
  }

  /// Extract and clean category
  static String? _extractCategory(Map<String, dynamic> json) {
    final String? categories = _extractString(json, 'categories');
    if (categories == null) {
      return null;
    }

    // Take the first category, clean it up
    final List<String> categoryList = categories.split(',');
    if (categoryList.isEmpty) {
      return null;
    }

    return categoryList.first.trim();
  }

  /// Convert to domain entity
  ScannedProduct toEntity() => ScannedProduct(
    barcode: barcode,
    name: name,
    brand: brand,
    category: category,
    imageUrl: imageUrl,
    packageQuantity: packageQuantity,
    nutrition: nutrition?.toEntity(),
    dataSource: dataSource,
  );

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    'barcode': barcode,
    'name': name,
    if (brand != null) 'brand': brand,
    if (category != null) 'category': category,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (packageQuantity != null) 'packageQuantity': packageQuantity,
    if (nutrition != null) 'nutrition': nutrition!.toJson(),
    if (dataSource != null) 'dataSource': dataSource,
  };
}

/// Nutrition information data model
class NutritionInfoModel {
  const NutritionInfoModel({
    this.caloriesPer100g,
    this.proteinPer100g,
    this.carbsPer100g,
    this.fatPer100g,
    this.fiberPer100g,
    this.sugarPer100g,
    this.sodiumPer100g,
  });

  /// Create from OpenFoodFacts nutriments JSON
  factory NutritionInfoModel.fromOpenFoodFactsJson(Map<String, dynamic> json) =>
      NutritionInfoModel(
        caloriesPer100g: _extractDouble(json, 'energy-kcal_100g'),
        proteinPer100g: _extractDouble(json, 'proteins_100g'),
        carbsPer100g: _extractDouble(json, 'carbohydrates_100g'),
        fatPer100g: _extractDouble(json, 'fat_100g'),
        fiberPer100g: _extractDouble(json, 'fiber_100g'),
        sugarPer100g: _extractDouble(json, 'sugars_100g'),
        sodiumPer100g: _extractDouble(json, 'sodium_100g'),
      );

  /// Convert from domain entity
  factory NutritionInfoModel.fromEntity(NutritionInfo entity) =>
      NutritionInfoModel(
        caloriesPer100g: entity.caloriesPer100g,
        proteinPer100g: entity.proteinPer100g,
        carbsPer100g: entity.carbsPer100g,
        fatPer100g: entity.fatPer100g,
        fiberPer100g: entity.fiberPer100g,
        sugarPer100g: entity.sugarPer100g,
        sodiumPer100g: entity.sodiumPer100g,
      );

  /// Create from generic JSON
  factory NutritionInfoModel.fromJson(Map<String, dynamic> json) =>
      NutritionInfoModel(
        caloriesPer100g: json['caloriesPer100g'] as double?,
        proteinPer100g: json['proteinPer100g'] as double?,
        carbsPer100g: json['carbsPer100g'] as double?,
        fatPer100g: json['fatPer100g'] as double?,
        fiberPer100g: json['fiberPer100g'] as double?,
        sugarPer100g: json['sugarPer100g'] as double?,
        sodiumPer100g: json['sodiumPer100g'] as double?,
      );
  final double? caloriesPer100g;
  final double? proteinPer100g;
  final double? carbsPer100g;
  final double? fatPer100g;
  final double? fiberPer100g;
  final double? sugarPer100g;
  final double? sodiumPer100g;

  /// Extract double safely from JSON
  static double? _extractDouble(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  /// Convert to domain entity
  NutritionInfo toEntity() => NutritionInfo(
    caloriesPer100g: caloriesPer100g,
    proteinPer100g: proteinPer100g,
    carbsPer100g: carbsPer100g,
    fatPer100g: fatPer100g,
    fiberPer100g: fiberPer100g,
    sugarPer100g: sugarPer100g,
    sodiumPer100g: sodiumPer100g,
  );

  /// Convert to JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
    if (caloriesPer100g != null) 'caloriesPer100g': caloriesPer100g,
    if (proteinPer100g != null) 'proteinPer100g': proteinPer100g,
    if (carbsPer100g != null) 'carbsPer100g': carbsPer100g,
    if (fatPer100g != null) 'fatPer100g': fatPer100g,
    if (fiberPer100g != null) 'fiberPer100g': fiberPer100g,
    if (sugarPer100g != null) 'sugarPer100g': sugarPer100g,
    if (sodiumPer100g != null) 'sodiumPer100g': sodiumPer100g,
  };
}

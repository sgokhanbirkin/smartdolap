import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';

/// Service for managing recipe filters
/// Follows Single Responsibility Principle - only handles filter logic
class RecipeFilterService {
  RecipeFilterService();

  final Map<String, dynamic> _activeFilters = <String, dynamic>{};

  /// Get current active filters
  Map<String, dynamic> get activeFilters => Map<String, dynamic>.unmodifiable(_activeFilters);

  /// Apply filters to recipes
  List<Recipe> applyFilters(List<Recipe> recipes) {
    if (_activeFilters.isEmpty) {
      return recipes;
    }

    List<Recipe> filtered = List<Recipe>.from(recipes);

    // Apply max calories filter
    if (_activeFilters.containsKey('maxCalories')) {
      final int? maxCalories = _activeFilters['maxCalories'] as int?;
      if (maxCalories != null && maxCalories > 0) {
        filtered = filtered.where((Recipe r) => r.calories == null || r.calories! <= maxCalories).toList();
      }
    }

    // Apply min fiber filter
    if (_activeFilters.containsKey('minFiber')) {
      final int? minFiber = _activeFilters['minFiber'] as int?;
      if (minFiber != null && minFiber > 0) {
        filtered = filtered.where((Recipe r) => r.fiber == null || r.fiber! >= minFiber).toList();
      }
    }

    // Apply difficulty filter
    if (_activeFilters.containsKey('difficulty')) {
      final String? difficulty = _activeFilters['difficulty'] as String?;
      if (difficulty != null && difficulty.isNotEmpty) {
        filtered = filtered.where((Recipe r) => r.difficulty?.toLowerCase() == difficulty.toLowerCase()).toList();
      }
    }

    // Apply duration filter
    if (_activeFilters.containsKey('maxDuration')) {
      final int? maxDuration = _activeFilters['maxDuration'] as int?;
      if (maxDuration != null && maxDuration > 0) {
        filtered = filtered.where((Recipe r) => r.durationMinutes == null || r.durationMinutes! <= maxDuration).toList();
      }
    }

    return filtered;
  }

  /// Set a filter value
  void setFilter(String key, Object? value) {
    if (value == null) {
      _activeFilters.remove(key);
    } else {
      _activeFilters[key] = value;
    }
  }

  /// Clear all filters
  void clearFilters() {
    _activeFilters.clear();
  }

  /// Check if any filters are active
  bool get hasActiveFilters => _activeFilters.isNotEmpty;

  /// Get filter count
  int get filterCount => _activeFilters.length;

  // ============================================================================
  // STATIC HELPER METHODS for repository use (backward compatibility)
  // These methods are used by RecipesRepositoryImpl for filtering recipes
  // ============================================================================

  /// Static helper: Filter recipes by exclude titles and ingredients
  /// Used by RecipesRepositoryImpl for repository-level filtering
  static List<Recipe> filterRecipes(
    List<Recipe> recipes,
    List<String> excludeTitles,
    List<Ingredient> ingredients,
  ) {
    List<Recipe> filtered = List<Recipe>.from(recipes);

    // Filter by exclude titles
    if (excludeTitles.isNotEmpty) {
      final Set<String> excludeSet = excludeTitles.map((String s) => s.toLowerCase()).toSet();
      filtered = filtered.where((Recipe r) => !excludeSet.contains(r.title.toLowerCase())).toList();
    }

    // Filter by ingredients (all ingredients must be present)
    if (ingredients.isNotEmpty) {
      final Set<String> ingredientNames = ingredients
          .map((Ingredient i) => i.name.toLowerCase())
          .toSet();
      filtered = filtered.where((Recipe r) {
        final Set<String> recipeIngredients = r.ingredients
            .map((String e) => e.toLowerCase())
            .toSet();
        return ingredientNames.every(recipeIngredients.contains);
      }).toList();
    }

    return filtered;
  }

  /// Static helper: Take first N recipes
  /// Used by RecipesRepositoryImpl for limiting results
  static List<Recipe> takeFirst(List<Recipe> recipes, int count) {
    if (recipes.length <= count) {
      return recipes;
    }
    return recipes.take(count).toList();
  }
}

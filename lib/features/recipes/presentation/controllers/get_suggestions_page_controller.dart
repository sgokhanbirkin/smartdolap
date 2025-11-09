import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Controller for get suggestions page - handles state management
class GetSuggestionsPageController {
  /// Creates a get suggestions page controller
  GetSuggestionsPageController({
    required this.initialItems,
    String? initialMeal,
  }) {
    _currentItems = List<PantryItem>.from(initialItems);
    _selectedMeal = initialMeal ?? 'dinner';
    _selectedIngredients.addAll(_currentItems.map((PantryItem e) => e.name));
    _initializeCategories();
  }

  final List<PantryItem> initialItems;
  List<PantryItem> _currentItems = <PantryItem>[];
  final Set<String> _selectedIngredients = <String>{};
  String _selectedMeal = 'dinner';
  final Map<String, bool> _expandedCategories = <String, bool>{};

  // Getters
  List<PantryItem> get currentItems => _currentItems;
  Set<String> get selectedIngredients => _selectedIngredients;
  String get selectedMeal => _selectedMeal;
  Map<String, bool> get expandedCategories => _expandedCategories;

  void _initializeCategories() {
    final Set<String> categories = _currentItems
        .map((PantryItem e) => PantryCategoryHelper.normalize(e.category))
        .toSet();
    for (final String category in categories) {
      _expandedCategories[category] = true;
    }
  }

  /// Group items by category
  Map<String, List<PantryItem>> groupByCategory(List<PantryItem> items) {
    final Map<String, List<PantryItem>> grouped = <String, List<PantryItem>>{};
    for (final PantryItem item in items) {
      final String category = PantryCategoryHelper.normalize(item.category);
      grouped.putIfAbsent(category, () => <PantryItem>[]).add(item);
    }
    // Sort categories
    final List<String> sortedCategories = grouped.keys.toList()
      ..sort(
        (String a, String b) => PantryCategoryHelper.categories
            .indexOf(a)
            .compareTo(PantryCategoryHelper.categories.indexOf(b)),
      );
    final Map<String, List<PantryItem>> sorted = <String, List<PantryItem>>{};
    for (final String category in sortedCategories) {
      sorted[category] = grouped[category]!;
    }
    return sorted;
  }

  /// Update selected meal
  void updateMeal(String meal) {
    _selectedMeal = meal;
  }

  /// Toggle category expansion
  void toggleCategory(String category) {
    _expandedCategories[category] = !(_expandedCategories[category] ?? false);
  }

  /// Toggle ingredient selection
  void toggleIngredient(String ingredient) {
    if (_selectedIngredients.contains(ingredient)) {
      _selectedIngredients.remove(ingredient);
    } else {
      _selectedIngredients.add(ingredient);
    }
  }

  /// Toggle select all/deselect all
  void toggleSelectAll() {
    if (_selectedIngredients.length == _currentItems.length) {
      _selectedIngredients.clear();
    } else {
      _selectedIngredients.addAll(_currentItems.map((PantryItem e) => e.name));
    }
  }

  /// Add new ingredient to the list
  void addIngredient(PantryItem item) {
    _currentItems.add(item);
    _selectedIngredients.add(item.name);
    final String category =
        PantryCategoryHelper.normalize(item.category ?? 'diğer');
    _expandedCategories[category] = true;
  }

  /// Check if at least one ingredient is selected
  bool get hasSelectedIngredients => _selectedIngredients.isNotEmpty;
}


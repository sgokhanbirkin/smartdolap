import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/category_colors.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/category_selector_widget.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
import 'dart:async';

/// Get suggestions page - Select ingredients by category and get AI suggestions
class GetSuggestionsPage extends StatefulWidget {
  const GetSuggestionsPage({
    required this.items,
    required this.userId,
    this.meal,
    super.key,
  });

  final List<PantryItem> items;
  final String userId;
  final String? meal;

  @override
  State<GetSuggestionsPage> createState() => _GetSuggestionsPageState();
}

class _GetSuggestionsPageState extends State<GetSuggestionsPage> {
  final Set<String> _selectedIngredients = <String>{};
  String _selectedMeal = 'dinner'; // Key olarak tutulacak
  final Map<String, bool> _expandedCategories = <String, bool>{};
  bool _isLoading = false;
  final TextEditingController _noteController = TextEditingController();
  List<PantryItem> _currentItems = <PantryItem>[];

  // Meal key'leri
  static const List<String> _mealKeys = <String>[
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  ];

  @override
  void initState() {
    super.initState();
    _currentItems = List<PantryItem>.from(widget.items);
    // Tüm ürünleri başlangıçta seçili yap
    _selectedIngredients.addAll(_currentItems.map((PantryItem e) => e.name));
    // Öğün seçimi - widget.meal key olarak geliyorsa kullan, değilse varsayılan "dinner"
    if (widget.meal != null && _mealKeys.contains(widget.meal)) {
      _selectedMeal = widget.meal!;
    } else {
      _selectedMeal = 'dinner';
    }
    // Tüm kategorileri başlangıçta açık yap
    final Set<String> categories = _currentItems
        .map((PantryItem e) => PantryCategoryHelper.normalize(e.category))
        .toSet();
    for (final String category in categories) {
      _expandedCategories[category] = true;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Map<String, List<PantryItem>> _groupByCategory(List<PantryItem> items) {
    final Map<String, List<PantryItem>> grouped = <String, List<PantryItem>>{};
    for (final PantryItem item in items) {
      final String category = PantryCategoryHelper.normalize(item.category);
      grouped.putIfAbsent(category, () => <PantryItem>[]).add(item);
    }
    // Kategorileri sırala
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

  Future<void> _showAddIngredientDialog() async {
    final TextEditingController nameController = TextEditingController();
    String? selectedCategory;
    String? suggestedCategory;
    bool isCategorizing = false;
    bool categoryLocked = false;
    Timer? categoryDebounce;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          void onNameChanged(String value) {
            categoryDebounce?.cancel();
            final String name = value.trim();
            if (name.length < 2) {
              setDialogState(() {
                suggestedCategory = null;
                selectedCategory = null;
                isCategorizing = false;
                categoryLocked = false;
              });
              return;
            }

            // Hızlı tahmin
            final String quickGuess = PantryCategoryHelper.guess(name);
            setDialogState(() {
              suggestedCategory = quickGuess;
              if (!categoryLocked) {
                selectedCategory = quickGuess;
              }
            });

            // AI ile kategori önerisi
            categoryDebounce = Timer(
              const Duration(milliseconds: 600),
              () async {
                setDialogState(() => isCategorizing = true);
                try {
                  final String cat = await sl<IOpenAIService>().categorizeItem(
                    name,
                  );
                  if (nameController.text.trim() != name) {
                    return;
                  }
                  setDialogState(() {
                    isCategorizing = false;
                    suggestedCategory = cat;
                    if (!categoryLocked) {
                      selectedCategory = cat;
                    }
                  });
                } on Exception catch (_) {
                  setDialogState(() => isCategorizing = false);
                }
              },
            );
          }

          return AlertDialog(
            title: Text(tr('add_ingredient')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: tr('ingredient_name'),
                      border: const OutlineInputBorder(),
                      hintText: tr('pantry_item_placeholder'),
                    ),
                    autofocus: true,
                    onChanged: onNameChanged,
                  ),
                  SizedBox(height: AppSizes.spacingM),
                  CategorySelectorWidget(
                    selectedCategory: selectedCategory,
                    isCategorizing: isCategorizing,
                    suggestedCategory: suggestedCategory,
                    onCategorySelected: (String? value) {
                      setDialogState(() {
                        selectedCategory = value;
                        categoryLocked = value != null;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  categoryDebounce?.cancel();
                  Navigator.of(dialogContext).pop(false);
                },
                child: Text(tr('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    categoryDebounce?.cancel();
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: Text(tr('add')),
              ),
            ],
          );
        },
      ),
    );

    categoryDebounce?.cancel();

    if (result == true && nameController.text.trim().isNotEmpty) {
      final PantryItem newItem = PantryItem(
        id: '',
        name: nameController.text.trim(),
        quantity: 1,
        unit: 'adet',
        category: selectedCategory != null
            ? PantryCategoryHelper.normalize(selectedCategory!)
            : null,
      );

      // PantryCubit'e ekle
      try {
        await context.read<PantryCubit>().add(widget.userId, newItem);
        // Listeyi güncelle
        setState(() {
          _currentItems.add(newItem);
          _selectedIngredients.add(newItem.name);
          // Kategoriyi açık yap
          final String category = PantryCategoryHelper.normalize(
            newItem.category ?? 'diğer',
          );
          _expandedCategories[category] = true;
        });
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tr('error')}: $e'),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
      }
    }

    nameController.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      _expandedCategories[category] = !(_expandedCategories[category] ?? false);
    });
  }

  void _toggleIngredient(String ingredient) {
    setState(() {
      if (_selectedIngredients.contains(ingredient)) {
        _selectedIngredients.remove(ingredient);
      } else {
        _selectedIngredients.add(ingredient);
      }
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('select_at_least_one_ingredient')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final RecipesCubit recipesCubit = context.read<RecipesCubit>();
      await recipesCubit.loadWithSelection(
        widget.userId,
        _selectedIngredients.toList(),
        _selectedMeal,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('error_getting_suggestions')),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<PantryItem>> grouped = _groupByCategory(
      _currentItems,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(tr('get_suggestions'))),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Öğün seçimi
                  Text(
                    tr('meal'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: AppSizes.spacingS),
                  DropdownButton<String>(
                    value: _selectedMeal,
                    isExpanded: true,
                    items: _mealKeys
                        .map(
                          (String key) => DropdownMenuItem<String>(
                            value: key,
                            child: Text(tr(key)),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) {
                      if (v != null) {
                        setState(() => _selectedMeal = v);
                      }
                    },
                  ),
                  SizedBox(height: AppSizes.verticalSpacingL),
                  // Kategoriler ve ürünler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        tr('select_ingredients'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: tr('add_ingredient'),
                        onPressed: _showAddIngredientDialog,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.spacingS),
                  ...grouped.entries.map(
                    (MapEntry<String, List<PantryItem>> entry) =>
                        _CategoryGroupWidget(
                          category: entry.key,
                          items: entry.value,
                          selectedIngredients: _selectedIngredients,
                          isExpanded: _expandedCategories[entry.key] ?? true,
                          onToggleCategory: () => _toggleCategory(entry.key),
                          onToggleIngredient: _toggleIngredient,
                        ),
                  ),
                  SizedBox(height: AppSizes.verticalSpacingL),
                  // Not alanı
                  Text(
                    tr('note'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: AppSizes.spacingS),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: tr('note_hint'),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.note_outlined),
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                ],
              ),
            ),
          ),
          // Alt butonlar
          Container(
            padding: EdgeInsets.all(AppSizes.padding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        // Tümünü seç/seçimi kaldır
                        if (_selectedIngredients.length ==
                            _currentItems.length) {
                          _selectedIngredients.clear();
                        } else {
                          _selectedIngredients.addAll(
                            _currentItems.map((PantryItem e) => e.name),
                          );
                        }
                      });
                    },
                    child: Text(
                      _selectedIngredients.length == _currentItems.length
                          ? tr('deselect_all')
                          : tr('select_all'),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.spacingM),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmSelection,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(tr('get_suggestions')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying a category group with expandable items
class _CategoryGroupWidget extends StatelessWidget {
  const _CategoryGroupWidget({
    required this.category,
    required this.items,
    required this.selectedIngredients,
    required this.isExpanded,
    required this.onToggleCategory,
    required this.onToggleIngredient,
  });

  final String category;
  final List<PantryItem> items;
  final Set<String> selectedIngredients;
  final bool isExpanded;
  final VoidCallback onToggleCategory;
  final ValueChanged<String> onToggleIngredient;

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = CategoryColors.getCategoryColor(category);
    final Color categoryIconColor = CategoryColors.getCategoryIconColor(
      category,
    );
    final int selectedCount = items
        .where((PantryItem item) => selectedIngredients.contains(item.name))
        .length;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: onToggleCategory,
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.spacingM,
                vertical: AppSizes.spacingS,
              ),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    PantryCategoryHelper.iconFor(category),
                    color: categoryIconColor,
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        fontWeight: FontWeight.w600,
                        color: categoryIconColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingS,
                      vertical: AppSizes.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                    ),
                    child: Text(
                      '$selectedCount/${items.length}',
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        fontWeight: FontWeight.bold,
                        color: categoryIconColor,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: categoryIconColor,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            SizedBox(height: AppSizes.spacingS),
            Wrap(
              spacing: AppSizes.spacingS,
              runSpacing: AppSizes.spacingS,
              children: items
                  .map(
                    (PantryItem item) => FilterChip(
                      label: Text(item.name),
                      selected: selectedIngredients.contains(item.name),
                      onSelected: (bool selected) =>
                          onToggleIngredient(item.name),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

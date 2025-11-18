import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/controllers/get_suggestions_page_controller.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/add_ingredient_dialog_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/get_suggestions_action_buttons_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/ingredients_selection_section_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/meal_selector_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/note_field_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipe_loading_overlay_widget.dart';

/// Get suggestions page - Select ingredients by category and get AI suggestions
class GetSuggestionsPage extends StatefulWidget {
  /// Creates a get suggestions page
  const GetSuggestionsPage({
    required this.items,
    required this.userId,
    this.meal,
    super.key,
  });

  /// List of pantry items
  final List<PantryItem> items;

  /// Household ID (for pantry access)
  final String userId; // Actually householdId

  /// Optional meal key
  final String? meal;

  @override
  State<GetSuggestionsPage> createState() => _GetSuggestionsPageState();
}

class _GetSuggestionsPageState extends State<GetSuggestionsPage> {
  late GetSuggestionsPageController _controller;
  bool _isLoading = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = GetSuggestionsPageController(
      initialItems: widget.items,
      initialMeal: widget.meal,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _showAddIngredientDialog() async {
    final Map<String, String?>? result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (BuildContext context) => const AddIngredientDialogWidget(),
    );

    if (result != null &&
        result['name'] != null &&
        result['name']!.isNotEmpty) {
      final PantryItem newItem = PantryItem(
        id: '',
        name: result['name']!,
        quantity: 1,
        unit: 'adet',
        category: result['category'] != null
            ? PantryCategoryHelper.normalize(result['category']!)
            : null,
      );

      try {
        await context.read<PantryCubit>().add(widget.userId, newItem);
        setState(() {
          _controller.addIngredient(newItem);
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
  }

  Future<void> _confirmSelection() async {
    if (!_controller.hasSelectedIngredients) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('select_at_least_one_ingredient')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Show full-screen loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (BuildContext context) => RecipeLoadingOverlayWidget(
        selectedIngredients: _controller.selectedIngredients.toList(),
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      ),
    );

    try {
      final RecipesCubit recipesCubit = context.read<RecipesCubit>();
      await recipesCubit.loadWithSelection(
        widget.userId,
        _controller.selectedIngredients.toList(),
        _controller.selectedMeal,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      );

      if (mounted) {
        // Close loading overlay
        Navigator.of(context).pop();
        setState(() => _isLoading = false);
        // Close suggestions page
        Navigator.of(context).pop(true);
      }
    } on Exception {
      if (mounted) {
        // Close loading overlay
        Navigator.of(context).pop();
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
  Widget build(BuildContext context) => Scaffold(
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
                // Meal selector
                MealSelectorWidget(
                  selectedMeal: _controller.selectedMeal,
                  onMealChanged: (String meal) {
                    setState(() {
                      _controller.updateMeal(meal);
                    });
                  },
                ),
                SizedBox(height: AppSizes.verticalSpacingL),
                // Ingredients selection section
                IngredientsSelectionSectionWidget(
                  items: _controller.currentItems,
                  selectedIngredients: _controller.selectedIngredients,
                  expandedCategories: _controller.expandedCategories,
                  onToggleCategory: (String category) {
                    setState(() {
                      _controller.toggleCategory(category);
                    });
                  },
                  onToggleIngredient: (String ingredient) {
                    setState(() {
                      _controller.toggleIngredient(ingredient);
                    });
                  },
                  onAddIngredient: _showAddIngredientDialog,
                ),
                SizedBox(height: AppSizes.verticalSpacingL),
                // Note field
                NoteFieldWidget(controller: _noteController),
              ],
            ),
          ),
        ),
        // Action buttons
        GetSuggestionsActionButtonsWidget(
          selectedCount: _controller.selectedIngredients.length,
          totalCount: _controller.currentItems.length,
          isLoading: _isLoading,
          onToggleSelectAll: () {
            setState(() {
              _controller.toggleSelectAll();
            });
          },
          onConfirm: _confirmSelection,
        ),
      ],
    ),
  );
}

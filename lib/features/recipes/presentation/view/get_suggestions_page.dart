import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_view_model.dart';
import 'package:smartdolap/features/recipes/presentation/controllers/get_suggestions_page_controller.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_view_model.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/add_ingredient_dialog_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/get_suggestions_action_buttons_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/ingredients_selection_section_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/meal_selector_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/note_field_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipe_loading_overlay_widget.dart';
import 'package:smartdolap/features/sync/presentation/cubit/sync_worker_cubit.dart';
import 'package:smartdolap/product/router/app_router.dart';

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
  RecipesViewModel? _recipesViewModel;
  PantryViewModel? _pantryViewModel;
  OverlayEntry? _loadingOverlay;

  @override
  void initState() {
    super.initState();
    _controller = GetSuggestionsPageController(
      initialItems: widget.items,
      initialMeal: widget.meal,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recipesViewModel ??= sl<RecipesViewModel>(
      param1: context.read<RecipesCubit>(),
    );
    _pantryViewModel ??= context.read<PantryViewModel>();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _recipesViewModel?.dispose();
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
        unit: 'adet',
        category: result['category'] != null
            ? PantryCategoryHelper.normalize(result['category']!)
            : null,
      );

      try {
        final PantryViewModel? pantryViewModel = _pantryViewModel;
        if (pantryViewModel == null) {
          throw StateError('PantryViewModel not initialized');
        }
        await pantryViewModel.add(widget.userId, newItem);
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

    // Show loading overlay with ingredient animation
    _showLoadingOverlay();

    try {
      final RecipesViewModel? viewModel = _recipesViewModel;
      if (viewModel == null) {
        throw StateError('RecipesViewModel not initialized');
      }

      await viewModel
          .loadWithSelection(
            widget.userId,
            _controller.selectedIngredients.toList(),
            _controller.selectedMeal,
            note: _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
          )
          .timeout(const Duration(seconds: 60));

      // Hide loading overlay
      _hideLoadingOverlay();

      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);

      // Get generated recipes from cubit state
      final RecipesCubit cubit = context.read<RecipesCubit>();
      final RecipesState state = cubit.state;

      if (state is RecipesLoaded && state.recipes.isNotEmpty) {
        // Navigate to results page with recipes
        await Navigator.of(context).pushReplacementNamed(
          AppRouter.recipeSuggestionsResults,
          arguments: <String, dynamic>{
            'recipes': state.recipes,
            'meal': _controller.selectedMeal,
          },
        );
      } else {
        // No recipes found, show message and pop
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tr('no_recipes_found')),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
        Navigator.of(context).pop(false);
      }
    } on TimeoutException {
      _hideLoadingOverlay();
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('suggestions_timeout')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } on Exception {
      _hideLoadingOverlay();
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('error_getting_suggestions')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }

  void _showLoadingOverlay() {
    _loadingOverlay = OverlayEntry(
      builder: (BuildContext context) => RecipeLoadingOverlayWidget(
        selectedIngredients: _controller.selectedIngredients.toList(),
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      ),
    );
    Overlay.of(context).insert(_loadingOverlay!);
  }

  void _hideLoadingOverlay() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  @override
  Widget build(BuildContext context) => BlocProvider<SyncWorkerCubit>.value(
    value: sl<SyncWorkerCubit>(),
    child: BackgroundWrapper(
      child: Scaffold(
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
                    SizedBox(height: AppSizes.verticalSpacingM),
                    const _SyncStatusBanner(),
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
      ),
    ),
  );
}

class _SyncStatusBanner extends StatelessWidget {
  const _SyncStatusBanner();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SyncWorkerCubit, SyncWorkerState>(
        builder: (BuildContext context, SyncWorkerState state) {
          if (state.status == SyncWorkerStatus.failure) {
            return _SyncBannerContainer(
              icon: Icons.error_outline,
              color: Theme.of(context).colorScheme.errorContainer,
              text: tr('sync_error_banner'),
            );
          }

          final bool shouldShow =
              state.pending > 0 || state.status == SyncWorkerStatus.running;
          if (!shouldShow) {
            return const SizedBox.shrink();
          }

          final String message = tr(
            'sync_pending_banner',
            namedArgs: <String, String>{'count': state.pending.toString()},
          );

          return _SyncBannerContainer(
            icon: Icons.cloud_upload_outlined,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            text: message,
          );
        },
      );
}

class _SyncBannerContainer extends StatelessWidget {
  const _SyncBannerContainer({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(AppSizes.spacingM),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppSizes.radius),
    ),
    child: Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: AppSizes.spacingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.textS,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/recipes/data/services/recipes_page_data_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/utils/meal_time_order_helper.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/compact_recipe_card_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/recipe_card_skeleton.dart';

/// Meal recipes page - Shows all recipes for a specific meal with pagination
class MealRecipesPage extends StatefulWidget {
  const MealRecipesPage({required this.meal, required this.userId, super.key});

  final String meal;
  final String userId;

  @override
  State<MealRecipesPage> createState() => _MealRecipesPageState();
}

class _MealRecipesPageState extends State<MealRecipesPage> {
  final ScrollController _scrollController = ScrollController();
  RecipesPageDataService? _dataService;
  RecipesCubit? _recipesCubit;
  List<Recipe> _recipes = <Recipe>[];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<String> _selectedRecipeTitles = <String>{};

  @override
  void initState() {
    super.initState();
    _recipesCubit = sl<RecipesCubit>();
    _dataService = RecipesPageDataService(recipesCubit: _recipesCubit!);
    _loadInitialRecipes();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialRecipes() async {
    if (_isLoading || _dataService == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<Recipe> recipes = await _dataService!.loadMealRecipes(
        widget.userId,
        widget.meal,
      );
      if (mounted) {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      debugPrint('Error loading meal recipes: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedRecipeTitles.clear();
      }
    });
  }

  void _toggleRecipeSelection(String title) {
    setState(() {
      if (_selectedRecipeTitles.contains(title)) {
        _selectedRecipeTitles.remove(title);
      } else {
        _selectedRecipeTitles.add(title);
      }
    });
  }

  void _selectAllRecipes() {
    setState(() {
      if (_selectedRecipeTitles.length == _recipes.length) {
        _selectedRecipeTitles.clear();
      } else {
        _selectedRecipeTitles.addAll(_recipes.map((Recipe r) => r.title));
      }
    });
  }

  Widget _buildRecipeCard(Recipe? recipe) {
    if (recipe == null) {
      return const SizedBox.shrink();
    }

    final bool isSelected = _selectedRecipeTitles.contains(recipe.title);

    return GestureDetector(
      onLongPress: () {
        if (!_isSelectionMode) {
          _toggleSelectionMode();
        }
        _toggleRecipeSelection(recipe.title);
      },
      child: Stack(
        children: <Widget>[
          CompactRecipeCardWidget(
            recipe: recipe,
            onTap: _isSelectionMode
                ? () => _toggleRecipeSelection(recipe.title)
                : () => Navigator.of(
                    context,
                  ).pushNamed(AppRouter.recipeDetail, arguments: recipe),
          ),
          if (_isSelectionMode)
            Positioned(
              top: AppSizes.spacingS,
              right: AppSizes.spacingS,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedRecipes() async {
    if (_selectedRecipeTitles.isEmpty) {
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('delete_recipes')),
        content: Text(
          tr(
            'delete_recipes_confirm',
            namedArgs: <String, String>{
              'count': _selectedRecipeTitles.length.toString(),
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      // Seçilen tariflerin listesini kaydet
      final List<String> titlesToDelete = _selectedRecipeTitles.toList();

      // Hive'dan sil
      final UserRecipeService userRecipeService = sl<UserRecipeService>();
      await userRecipeService.deleteRecipesByTitles(titlesToDelete);

      // Cache'den sil
      if (_recipesCubit != null) {
        await _recipesCubit!.deleteRecipesFromCache(
          widget.userId,
          widget.meal,
          titlesToDelete,
        );
      }

      // UI'dan sil
      setState(() {
        _recipes.removeWhere((Recipe r) => titlesToDelete.contains(r.title));
        _selectedRecipeTitles.clear();
        _isSelectionMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                'recipes_deleted',
                namedArgs: <String, String>{
                  'count': titlesToDelete.length.toString(),
                },
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: AppSizes.padding,
              right: AppSizes.padding,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${tr('error')}: $e',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: AppSizes.padding,
              right: AppSizes.padding,
            ),
          ),
        );
      }
    }
  }

  Future<void> _showGetSuggestionsDialog(BuildContext context) async {
    if (!context.mounted) {
      return;
    }
    final BuildContext authContext = context;
    final AuthState st = authContext.read<AuthCubit>().state;
    await st.whenOrNull(
      authenticated: (domain.User user) async {
        final IPantryRepository repo = sl<IPantryRepository>();
        final List<PantryItem> items = await repo.getItems(userId: user.id);

        if (!authContext.mounted) {
          return;
        }
        final BuildContext dialogContext = authContext;
        final bool? ok = await Navigator.of(dialogContext).pushNamed<bool>(
          AppRouter.getSuggestions,
          arguments: <String, dynamic>{
            'items': items,
            'meal': widget.meal,
            'userId': user.id,
          },
        );
        if (ok == true && dialogContext.mounted) {
          // Öneriler yüklendi, sayfayı yenile
          await _loadInitialRecipes();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: MealTimeOrderHelper.getMealAppBarColor(widget.meal),
      foregroundColor: Colors.white,
      title: Text(
        '${tr('you_can_make')} - ${MealTimeOrderHelper.getMealName(widget.meal)}',
        style: TextStyle(fontSize: AppSizes.textM, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        if (_isSelectionMode) ...[
          IconButton(
            icon: Icon(
              _selectedRecipeTitles.length == _recipes.length
                  ? Icons.deselect
                  : Icons.select_all,
            ),
            tooltip: _selectedRecipeTitles.length == _recipes.length
                ? tr('deselect_all')
                : tr('select_all'),
            onPressed: _selectAllRecipes,
          ),
          if (_selectedRecipeTitles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: tr('delete'),
              onPressed: _deleteSelectedRecipes,
            ),
        ],
        IconButton(
          icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
          tooltip: _isSelectionMode ? tr('cancel') : tr('select_recipes'),
          onPressed: _toggleSelectionMode,
        ),
      ],
    ),
    body: _isLoading
        ? GridView.builder(
            padding: EdgeInsets.all(AppSizes.padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveGrid.getCrossAxisCount(context),
              crossAxisSpacing: AppSizes.spacingS,
              mainAxisSpacing: AppSizes.verticalSpacingS,
              childAspectRatio: ResponsiveGrid.getChildAspectRatio(context),
            ),
            itemCount: 6, // Show 6 skeleton cards
            itemBuilder: (BuildContext context, int index) =>
                const RecipeCardSkeleton(),
          )
        : _recipes.isEmpty
        ? EmptyState(
            messageKey: 'no_recipes_yet',
            lottieAsset: 'assets/animations/Recipe_Book.json',
          )
        : GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(AppSizes.padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveGrid.getCrossAxisCount(context),
              crossAxisSpacing: AppSizes.spacingS,
              mainAxisSpacing: AppSizes.verticalSpacingS,
              childAspectRatio: ResponsiveGrid.getChildAspectRatio(context),
            ),
            itemCount: _recipes.length,
            itemBuilder: (BuildContext context, int index) =>
                _buildRecipeCard(_recipes[index]),
          ),
    floatingActionButton: _isSelectionMode
        ? null
        : BlocBuilder<AuthCubit, AuthState>(
            builder: (BuildContext context, AuthState state) => state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_) => const SizedBox.shrink(),
              unauthenticated: () => const SizedBox.shrink(),
              authenticated: (domain.User user) =>
                  FloatingActionButton.extended(
                    onPressed: () => _showGetSuggestionsDialog(context),
                    icon: const Icon(Icons.lightbulb),
                    label: Text(tr('get_suggestions')),
                  ),
            ),
          ),
  );
}

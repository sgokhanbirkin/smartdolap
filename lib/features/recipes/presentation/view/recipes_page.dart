import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/recipes/data/services/recipes_page_data_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/controllers/recipes_page_controller.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipes_advanced_sections_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipes_search_bar_widget.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/recipes_search_results_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/error_state.dart';

/// Recipes page - Shows available recipes
class RecipesPage extends StatefulWidget {
  /// Recipes page constructor
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');
  Timer? _searchDebounce;
  RecipesPageController? _controller;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchQuery.value != _searchController.text) {
        _searchQuery.value = _searchController.text;
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchQuery.dispose();
    _scrollController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState state) => state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(
          child: CustomLoadingIndicator(
            type: LoadingType.pulsingGrid,
            size: 50,
          ),
        ),
        error: (_) => const EmptyState(messageKey: 'recipes_empty_message'),
        unauthenticated: () =>
            const EmptyState(messageKey: 'recipes_empty_message'),
        authenticated: (domain.User user) {
          return MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<RecipesCubit>(
                create: (BuildContext _) => sl<RecipesCubit>(),
              ),
              BlocProvider<PantryCubit>(
                create: (BuildContext _) => sl<PantryCubit>()..watch(user.id),
              ),
            ],
            child: Builder(
              builder: (BuildContext inner) {
                final RecipesCubit recipesCubit = inner.read<RecipesCubit>();
                final PantryCubit pantryCubit = inner.read<PantryCubit>();
                final RecipesPageDataService dataService =
                    RecipesPageDataService(recipesCubit: recipesCubit);

                // Initialize controller if not already initialized
                _controller ??= RecipesPageController(
                  recipesCubit: recipesCubit,
                  dataService: dataService,
                  pantryCubit: pantryCubit,
                  userId: user.id,
                );

                return SafeArea(
                  child: BlocBuilder<RecipesCubit, RecipesState>(
                    builder: (BuildContext context, RecipesState recipesState) {
                      return ValueListenableBuilder<String>(
                        valueListenable: _searchQuery,
                        builder:
                            (
                              BuildContext context,
                              String query,
                              Widget? child,
                            ) {
                              return _buildContent(
                                context,
                                recipesState,
                                query,
                                user,
                              );
                            },
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );

  Widget _buildContent(
    BuildContext context,
    RecipesState recipesState,
    String query,
    domain.User user,
  ) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    // Search mode
    if (query.isNotEmpty) {
      final List<Recipe> filteredRecipes = _controller!.filterRecipes(
        recipesState is RecipesLoaded
            ? recipesState.recipes
            : _controller!.allCachedRecipes.value,
        query,
      );

      return Column(
        children: <Widget>[
          RecipesSearchBarWidget(
            controller: _searchController,
            query: query,
            onQueryChanged: (String value) {
              _searchQuery.value = value;
            },
            onClear: () {
              _searchController.clear();
              _searchQuery.value = '';
            },
            onGetSuggestions: () async {
              await _openGetSuggestions(context, user);
            },
          ),
          Expanded(
            child: RecipesSearchResultsWidget(
              recipes: filteredRecipes,
              onRecipeTap: (Recipe recipe) =>
                  _openRecipeDetail(context, recipe),
              scrollController: _scrollController,
            ),
          ),
        ],
      );
    }

    // Normal mode - show search bar and sections
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        // Search bar
        SliverToBoxAdapter(
          child: RecipesSearchBarWidget(
            controller: _searchController,
            query: query,
            onQueryChanged: (String value) {
              _searchQuery.value = value;
            },
            onClear: () {
              _searchController.clear();
              _searchQuery.value = '';
            },
            onGetSuggestions: () async {
              await _openGetSuggestions(context, user);
            },
          ),
        ),
        // Advanced sections
        ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: _controller!.allDataNotifier,
          builder:
              (BuildContext context, Map<String, dynamic> data, Widget? child) {
                // Null safety check with safe casting
                if (data.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                final dynamic favoritesData = data['favorites'];
                final dynamic breakfastData = data['breakfast'];
                final dynamic snackData = data['snack'];
                final dynamic lunchData = data['lunch'];
                final dynamic dinnerData = data['dinner'];
                final dynamic madeData = data['made'];
                final dynamic loadingStatesData = data['loadingStates'];

                final List<Recipe> favorites = favoritesData is List<Recipe>
                    ? favoritesData
                    : <Recipe>[];
                final List<Recipe> breakfast = breakfastData is List<Recipe>
                    ? breakfastData
                    : <Recipe>[];
                final List<Recipe> snack = snackData is List<Recipe>
                    ? snackData
                    : <Recipe>[];
                final List<Recipe> lunch = lunchData is List<Recipe>
                    ? lunchData
                    : <Recipe>[];
                final List<Recipe> dinner = dinnerData is List<Recipe>
                    ? dinnerData
                    : <Recipe>[];
                final List<Recipe> made = madeData is List<Recipe>
                    ? madeData
                    : <Recipe>[];
                final Map<String, bool> loadingStates =
                    loadingStatesData is Map<String, bool>
                    ? loadingStatesData
                    : <String, bool>{};

                return SliverToBoxAdapter(
                  child: RecipesAdvancedSectionsWidget(
                    favorites: favorites,
                    breakfastRecipes: breakfast,
                    snackRecipes: snack,
                    lunchRecipes: lunch,
                    dinnerRecipes: dinner,
                    madeRecipes: made,
                    loadingStates: loadingStates,
                    onRecipeTap: (Recipe recipe) =>
                        _openRecipeDetail(context, recipe),
                    activeUserId: _controller!.userId,
                  ),
                );
              },
        ),
        // Error state
        if (recipesState is RecipesFailure)
          SliverToBoxAdapter(
            child: ErrorState(
              messageKey: recipesState.message,
              onRetry: () {
                _controller?.recipesCubit.load(_controller!.userId);
              },
              lottieAsset: 'assets/animations/Cooking.json',
            ),
          ),
      ],
    );
  }

  Future<void> _openRecipeDetail(BuildContext context, Recipe recipe) async {
    final bool? recipeMade = await Navigator.of(
      context,
    ).pushNamed<bool>(AppRouter.recipeDetail, arguments: recipe);
    if (recipeMade == true && mounted) {
      _controller?.loadMadeRecipes();
    }
  }

  Future<void> _openGetSuggestions(
    BuildContext context,
    domain.User user,
  ) async {
    if (user.householdId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('household_setup_description')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
      return;
    }

    try {
      final IPantryRepository pantryRepo = sl<IPantryRepository>();
      final List<PantryItem> pantryItems = (await pantryRepo.getItems(
        householdId: user.householdId!,
      )).cast<PantryItem>();

      if (!context.mounted) {
        return;
      }

      await Navigator.of(context).pushNamed<bool>(
        AppRouter.getSuggestions,
        arguments: <String, dynamic>{
          'items': pantryItems,
          'householdId': user.householdId!,
          'meal': null,
        },
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tr('error')}: $e'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    }
  }
}

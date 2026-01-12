import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/recipes/data/services/recipes_page_data_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/utils/meal_time_order_helper.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_view_model.dart';

/// Recipes page controller that coordinates cache + listener services while keeping
/// the widget tree agnostic of Hive streams and heavy orchestration logic.
/// Responsibilities are delegated to:
/// - `_RecipesCacheManager` for cache + data loading orchestration
/// - `_RecipesListenerManager` for Hive/pantry subscriptions
/// This keeps the controller focused on wiring and exposes only ValueNotifiers to the UI.
class RecipesPageController {
  /// Creates a recipes page controller
  RecipesPageController({
    required this.recipesViewModel,
    required this.dataService,
    required this.pantryCubit,
    required this.userId,
  }) {
    _initialize();
  }

  final RecipesViewModel recipesViewModel;
  final RecipesPageDataService dataService;
  final PantryCubit pantryCubit;
  final String userId;
  late final _RecipesCacheManager _cacheManager;
  late final _RecipesListenerManager _listenerManager;

  // Data holders
  final ValueNotifier<List<Recipe>> favorites = ValueNotifier<List<Recipe>>(
    <Recipe>[],
  );
  final ValueNotifier<List<Recipe>> breakfastRecipes =
      ValueNotifier<List<Recipe>>(<Recipe>[]);
  final ValueNotifier<List<Recipe>> snackRecipes = ValueNotifier<List<Recipe>>(
    <Recipe>[],
  );
  final ValueNotifier<List<Recipe>> lunchRecipes = ValueNotifier<List<Recipe>>(
    <Recipe>[],
  );
  final ValueNotifier<List<Recipe>> dinnerRecipes = ValueNotifier<List<Recipe>>(
    <Recipe>[],
  );
  final ValueNotifier<List<Recipe>> madeRecipes = ValueNotifier<List<Recipe>>(
    <Recipe>[],
  );
  final ValueNotifier<List<Recipe>> allCachedRecipes =
      ValueNotifier<List<Recipe>>(<Recipe>[]);

  // Loading states
  final ValueNotifier<Map<String, bool>> loadingStates =
      ValueNotifier<Map<String, bool>>(<String, bool>{
        'breakfast': false,
        'snack': false,
        'lunch': false,
        'dinner': false,
        'favorites': false,
        'made': false,
      });

  // Combined data notifier for easier listening
  final ValueNotifier<Map<String, dynamic>> allDataNotifier =
      ValueNotifier<Map<String, dynamic>>(<String, dynamic>{
        'favorites': <Recipe>[],
        'breakfast': <Recipe>[],
        'snack': <Recipe>[],
        'lunch': <Recipe>[],
        'dinner': <Recipe>[],
        'made': <Recipe>[],
        'loadingStates': <String, bool>{
          'breakfast': false,
          'snack': false,
          'lunch': false,
          'dinner': false,
          'favorites': false,
          'made': false,
        },
      });

  // Lifecycle state
  bool _isDisposed = false;

  // Cache kontrolü için flag - static olarak tutuluyor
  static final Map<String, bool> _initialLoadFlags = <String, bool>{};

  void _initialize() {
    _cacheManager = _RecipesCacheManager(
      userId: userId,
      dataService: dataService,
      favorites: favorites,
      breakfastRecipes: breakfastRecipes,
      snackRecipes: snackRecipes,
      lunchRecipes: lunchRecipes,
      dinnerRecipes: dinnerRecipes,
      madeRecipes: madeRecipes,
      allCachedRecipes: allCachedRecipes,
      loadingStates: loadingStates,
      allDataNotifier: allDataNotifier,
      isDisposed: () => _isDisposed,
    );
    _listenerManager = _RecipesListenerManager(
      pantryCubit: pantryCubit,
      isDisposed: () => _isDisposed,
      refreshFavorites: _cacheManager.refreshFavorites,
      refreshMadeRecipes: _cacheManager.loadMadeRecipes,
      refreshRecommendations: () => recipesViewModel.load(userId),
    );

    _cacheManager.updateCombinedData();
    _listenerManager.initialize();

    // User bazlı ilk yükleme kontrolü
    final bool hasLoadedForUser = _initialLoadFlags[userId] ?? false;

    loadingStates.value = _cacheManager.buildInitialLoadingState(
      hasLoadedBefore: hasLoadedForUser,
    );
    _cacheManager.updateCombinedData();

    if (!hasLoadedForUser) {
      // İlk kez bu user için yükleme yapılıyor
      _initialLoadFlags[userId] = true;
      _cacheManager.loadAllData();
    } else {
      _cacheManager.loadFromCache();
    }
  }

  Future<void> loadMadeRecipes() => _cacheManager.loadMadeRecipes();

  /// Filter recipes by search query
  List<Recipe> filterRecipes(List<Recipe> recipes, String query) {
    if (query.isEmpty) {
      return recipes;
    }

    final String lowerQuery = query.toLowerCase();
    return recipes.where((Recipe recipe) {
      final bool matchesTitle = recipe.title.toLowerCase().contains(lowerQuery);
      final bool matchesIngredients = recipe.ingredients.any(
        (String ingredient) => ingredient.toLowerCase().contains(lowerQuery),
      );
      return matchesTitle || matchesIngredients;
    }).toList();
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _listenerManager.dispose();
    favorites.dispose();
    breakfastRecipes.dispose();
    snackRecipes.dispose();
    lunchRecipes.dispose();
    dinnerRecipes.dispose();
    madeRecipes.dispose();
    allCachedRecipes.dispose();
    loadingStates.dispose();
    allDataNotifier.dispose();
  }
}

class _RecipesCacheManager {
  _RecipesCacheManager({
    required this.userId,
    required this.dataService,
    required this.favorites,
    required this.breakfastRecipes,
    required this.snackRecipes,
    required this.lunchRecipes,
    required this.dinnerRecipes,
    required this.madeRecipes,
    required this.allCachedRecipes,
    required this.loadingStates,
    required this.allDataNotifier,
    required this.isDisposed,
  });

  final String userId;
  final RecipesPageDataService dataService;
  final ValueNotifier<List<Recipe>> favorites;
  final ValueNotifier<List<Recipe>> breakfastRecipes;
  final ValueNotifier<List<Recipe>> snackRecipes;
  final ValueNotifier<List<Recipe>> lunchRecipes;
  final ValueNotifier<List<Recipe>> dinnerRecipes;
  final ValueNotifier<List<Recipe>> madeRecipes;
  final ValueNotifier<List<Recipe>> allCachedRecipes;
  final ValueNotifier<Map<String, bool>> loadingStates;
  final ValueNotifier<Map<String, dynamic>> allDataNotifier;
  final bool Function() isDisposed;

  final Map<String, bool> _isLoadingMeal = <String, bool>{};

  Map<String, bool> buildInitialLoadingState({required bool hasLoadedBefore}) {
    final Map<String, bool> states = <String, bool>{
      'breakfast': false,
      'snack': false,
      'lunch': false,
      'dinner': false,
      'favorites': false,
      'made': false,
    };

    if (!hasLoadedBefore) {
      for (final String meal in MealTimeOrderHelper.getOrderedMeals()) {
        states[meal] = true;
        _isLoadingMeal[meal] = true;
      }
    }

    return states;
  }

  Future<void> loadFromCache() async {
    if (isDisposed()) {
      return;
    }

    try {
      favorites.value = await dataService.loadFavorites();
      updateCombinedData();

      for (final String meal in MealTimeOrderHelper.getOrderedMeals()) {
        if (isDisposed()) {
          return;
        }
        await _loadMealRecipes(meal);
      }

      if (isDisposed()) {
        return;
      }

      madeRecipes.value = await dataService.loadMadeRecipes(userId);
      updateCombinedData();
    } on Exception catch (error) {
      debugPrint('[RecipesCacheManager] Cache load error: $error');
    }
  }

  Future<void> loadAllData() async {
    if (isDisposed()) {
      return;
    }

    try {
      favorites.value = await dataService.loadFavorites();
      updateCombinedData();

      final List<Future<void>> futures = MealTimeOrderHelper.getOrderedMeals()
          .map(_loadMealRecipes)
          .toList();
      await Future.wait(futures);

      if (isDisposed()) {
        return;
      }

      madeRecipes.value = await dataService.loadMadeRecipes(userId);
      updateCombinedData();
    } on Exception catch (error) {
      debugPrint('[RecipesCacheManager] Error loading meals: $error');
    }
  }

  Future<void> refreshFavorites() async {
    if (isDisposed()) {
      return;
    }
    try {
      favorites.value = await dataService.loadFavorites();
      updateCombinedData();
    } on Exception catch (error) {
      debugPrint('[RecipesCacheManager] Favorites load error: $error');
    }
  }

  Future<void> loadMadeRecipes() async {
    if (isDisposed()) {
      return;
    }
    try {
      final List<Recipe> loaded = await dataService.loadMadeRecipes(userId);
      if (isDisposed()) {
        return;
      }
      madeRecipes.value = loaded;
      updateCombinedData();
    } on Exception catch (error) {
      debugPrint('[RecipesCacheManager] Made recipes load error: $error');
    }
  }

  void updateCombinedData() {
    if (isDisposed()) {
      return;
    }

    final List<Recipe> combined = <Recipe>[
      ...favorites.value,
      ...breakfastRecipes.value,
      ...snackRecipes.value,
      ...lunchRecipes.value,
      ...dinnerRecipes.value,
      ...madeRecipes.value,
    ];

    final Set<String> seenTitles = <String>{};
    final List<Recipe> uniqueRecipes = combined.where((Recipe recipe) {
      if (seenTitles.contains(recipe.title)) {
        return false;
      }
      seenTitles.add(recipe.title);
      return true;
    }).toList();

    if (isDisposed()) {
      return;
    }

    allCachedRecipes.value = uniqueRecipes;
    allDataNotifier.value = <String, dynamic>{
      'favorites': favorites.value,
      'breakfast': breakfastRecipes.value,
      'snack': snackRecipes.value,
      'lunch': lunchRecipes.value,
      'dinner': dinnerRecipes.value,
      'made': madeRecipes.value,
      'loadingStates': loadingStates.value,
    };
  }

  Future<void> _loadMealRecipes(String meal) async {
    _setMealLoading(meal, true);
    try {
      final List<Recipe> recipes = await dataService.loadMealRecipes(
        userId,
        meal,
      );
      if (isDisposed()) {
        return;
      }
      _assignMeal(meal, recipes);
    } on Exception catch (error) {
      debugPrint('[RecipesCacheManager] Meal load error ($meal): $error');
    } finally {
      _setMealLoading(meal, false);
    }
  }

  void _assignMeal(String meal, List<Recipe> recipes) {
    switch (meal) {
      case 'breakfast':
        breakfastRecipes.value = recipes;
        break;
      case 'snack':
        snackRecipes.value = recipes;
        break;
      case 'lunch':
        lunchRecipes.value = recipes;
        break;
      case 'dinner':
        dinnerRecipes.value = recipes;
        break;
    }
    updateCombinedData();
  }

  void _setMealLoading(String meal, bool isLoading) {
    if (_isLoadingMeal[meal] == isLoading || isDisposed()) {
      return;
    }

    _isLoadingMeal[meal] = isLoading;
    loadingStates.value = <String, bool>{
      ...loadingStates.value,
      meal: isLoading,
    };
    updateCombinedData();
  }
}

class _RecipesListenerManager {
  _RecipesListenerManager({
    required this.pantryCubit,
    required this.isDisposed,
    required this.refreshFavorites,
    required this.refreshMadeRecipes,
    required this.refreshRecommendations,
  }) : _favoritesFuture = Hive.isBoxOpen('favorite_recipes')
           ? Future<Box<dynamic>>.value(Hive.box<dynamic>('favorite_recipes'))
           : Hive.openBox<dynamic>('favorite_recipes'),
       _userRecipesFuture = Hive.isBoxOpen('profile_box')
           ? Future<Box<dynamic>>.value(Hive.box<dynamic>('profile_box'))
           : Hive.openBox<dynamic>('profile_box');

  final PantryCubit pantryCubit;
  final bool Function() isDisposed;
  final Future<void> Function() refreshFavorites;
  final Future<void> Function() refreshMadeRecipes;
  final Future<void> Function() refreshRecommendations;

  final Future<Box<dynamic>> _favoritesFuture;
  final Future<Box<dynamic>> _userRecipesFuture;

  StreamSubscription<PantryState>? _pantrySubscription;
  VoidCallback? _favoritesListener;
  VoidCallback? _madeRecipesListener;
  Timer? _pantryDebounceTimer;
  Timer? _madeRecipesDebounceTimer;
  DateTime? _lastPantryUpdate;
  DateTime? _lastMadeRecipesUpdate;
  bool _madeRecipesListenerAdded = false;
  String? _lastUserRecipesHash;
  List<String> _lastPantryItems = <String>[];
  bool _isPantryRefreshInProgress = false;

  void initialize() {
    if (isDisposed()) {
      return;
    }
    _setupFavoritesListener();
    _setupMadeRecipesListener();
    _setupPantryListener();
  }

  void dispose() {
    _pantryDebounceTimer?.cancel();
    _madeRecipesDebounceTimer?.cancel();
    _pantrySubscription?.cancel();

    _favoritesFuture.then((Box<dynamic> box) {
      if (_favoritesListener != null) {
        box.listenable().removeListener(_favoritesListener!);
      }
    });

    _userRecipesFuture.then((Box<dynamic> box) {
      if (_madeRecipesListener != null) {
        box.listenable().removeListener(_madeRecipesListener!);
      }
    });
  }

  void _setupFavoritesListener() {
    _favoritesListener = () {
      if (isDisposed()) {
        return;
      }
      unawaited(refreshFavorites());
    };

    _favoritesFuture.then((Box<dynamic> box) {
      if (!isDisposed() && _favoritesListener != null) {
        box.listenable().addListener(_favoritesListener!);
      }
    });
  }

  void _setupMadeRecipesListener() {
    if (isDisposed() || _madeRecipesListenerAdded) {
      return;
    }

    _madeRecipesListener = () {
      if (isDisposed()) {
        return;
      }
      _userRecipesFuture.then((Box<dynamic> box) {
        if (isDisposed()) {
          return;
        }
        final List<dynamic>? currentRecipes =
            box.get('user_recipes') as List<dynamic>?;
        final String currentHash = currentRecipes?.toString() ?? '';

        if (_lastUserRecipesHash == currentHash) {
          return;
        }

        _lastUserRecipesHash = currentHash;
        _scheduleMadeRecipesRefresh();
      });
    };

    _userRecipesFuture.then((Box<dynamic> box) {
      if (isDisposed() || _madeRecipesListener == null) {
        return;
      }
      box.listenable().addListener(_madeRecipesListener!);
      _madeRecipesListenerAdded = true;

      final List<dynamic>? initialRecipes =
          box.get('user_recipes') as List<dynamic>?;
      _lastUserRecipesHash = initialRecipes?.toString() ?? '';
    });
  }

  void _setupPantryListener() {
    _pantrySubscription = pantryCubit.stream.listen((PantryState state) {
      if (isDisposed()) {
        return;
      }
      state.maybeWhen(loaded: _handlePantryItems, orElse: () {});
    });
  }

  void _handlePantryItems(List<PantryItem> items) {
    if (items.isEmpty) {
      return;
    }
    final List<String> currentItems = items
        .map((PantryItem item) => '${item.id}_${item.name}')
        .toList();

    if (_lastPantryItems.isEmpty) {
      _lastPantryItems = currentItems;
      return;
    }

    final bool itemsChanged =
        _lastPantryItems.length != currentItems.length ||
        !_lastPantryItems.every(currentItems.contains);
    if (!itemsChanged) {
      return;
    }

    _lastPantryItems = currentItems;
    final DateTime now = DateTime.now();
    _pantryDebounceTimer?.cancel();

    if (_lastPantryUpdate != null &&
        now.difference(_lastPantryUpdate!).inSeconds < 3) {
      _pantryDebounceTimer = Timer(const Duration(seconds: 3), () {
        if (!isDisposed()) {
          _refreshRecommendations();
        }
      });
      return;
    }

    _lastPantryUpdate = now;
    _refreshRecommendations();
  }

  void _scheduleMadeRecipesRefresh() {
    final DateTime now = DateTime.now();
    _madeRecipesDebounceTimer?.cancel();

    if (_lastMadeRecipesUpdate != null &&
        now.difference(_lastMadeRecipesUpdate!).inSeconds < 2) {
      _madeRecipesDebounceTimer = Timer(const Duration(seconds: 2), () {
        if (!isDisposed()) {
          unawaited(refreshMadeRecipes());
        }
      });
      return;
    }

    _lastMadeRecipesUpdate = now;
    unawaited(refreshMadeRecipes());
  }

  void _refreshRecommendations() {
    if (_isPantryRefreshInProgress || isDisposed()) {
      return;
    }
    _isPantryRefreshInProgress = true;
    refreshRecommendations().whenComplete(() {
      _isPantryRefreshInProgress = false;
    });
  }
}

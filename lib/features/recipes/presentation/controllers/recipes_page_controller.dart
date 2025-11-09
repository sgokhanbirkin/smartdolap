import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';
import 'package:smartdolap/features/recipes/data/services/recipes_page_data_service.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/utils/meal_time_order_helper.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';

/// Controller for recipes page - handles data loading and state management
class RecipesPageController {
  /// Creates a recipes page controller
  RecipesPageController({
    required this.recipesCubit,
    required this.dataService,
    required this.pantryCubit,
    required this.userId,
  }) {
    _initialize();
  }

  final RecipesCubit recipesCubit;
  final RecipesPageDataService dataService;
  final PantryCubit pantryCubit;
  final String userId;

  // Data holders
  final ValueNotifier<List<Recipe>> favorites = ValueNotifier<List<Recipe>>([]);
  final ValueNotifier<List<Recipe>> breakfastRecipes =
      ValueNotifier<List<Recipe>>([]);
  final ValueNotifier<List<Recipe>> snackRecipes = ValueNotifier<List<Recipe>>(
    [],
  );
  final ValueNotifier<List<Recipe>> lunchRecipes = ValueNotifier<List<Recipe>>(
    [],
  );
  final ValueNotifier<List<Recipe>> dinnerRecipes = ValueNotifier<List<Recipe>>(
    [],
  );
  final ValueNotifier<List<Recipe>> madeRecipes = ValueNotifier<List<Recipe>>(
    [],
  );
  final ValueNotifier<List<Recipe>> allCachedRecipes =
      ValueNotifier<List<Recipe>>([]);

  // Loading states
  final ValueNotifier<Map<String, bool>> loadingStates =
      ValueNotifier<Map<String, bool>>({
        'breakfast': false,
        'snack': false,
        'lunch': false,
        'dinner': false,
        'favorites': false,
        'made': false,
      });

  // Combined data notifier for easier listening
  final ValueNotifier<Map<String, dynamic>> allDataNotifier =
      ValueNotifier<Map<String, dynamic>>({
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

  // Listeners and subscriptions
  StreamSubscription<PantryState>? _pantrySubscription;
  VoidCallback? _favoritesListener;
  VoidCallback? _madeRecipesListener;
  Timer? _pantryDebounceTimer;
  Timer? _madeRecipesDebounceTimer;
  DateTime? _lastPantryUpdate;
  DateTime? _lastMadeRecipesUpdate;
  bool _isLoadingRecipes = false;
  bool _madeRecipesListenerAdded = false;
  String? _lastUserRecipesHash;
  final Map<String, bool> _isLoadingMeal = <String, bool>{};
  List<String> _lastPantryItems = <String>[];

  late Future<Box<dynamic>> _favoritesFuture;
  late Future<Box<dynamic>> _userRecipesFuture;

  void _initialize() {
    _favoritesFuture = Hive.isBoxOpen('favorite_recipes')
        ? Future<Box<dynamic>>.value(Hive.box<dynamic>('favorite_recipes'))
        : Hive.openBox<dynamic>('favorite_recipes');
    _userRecipesFuture = Hive.isBoxOpen('profile_box')
        ? Future<Box<dynamic>>.value(Hive.box<dynamic>('profile_box'))
        : Hive.openBox<dynamic>('profile_box');

    // Initialize allDataNotifier with current values immediately
    _updateAllCachedRecipes();

    _setupListeners();
    _loadAllData();
  }

  void _setupListeners() {
    // Favorites listener
    _favoritesListener = () => _loadFavorites();
    _favoritesFuture.then((Box<dynamic> box) {
      box.listenable().addListener(_favoritesListener!);
    });

    // Made recipes listener
    if (!_madeRecipesListenerAdded) {
      _madeRecipesListener = () {
        debugPrint(
          '[RecipesPageController] profile_box değişti, yaptıklarım kontrol ediliyor...',
        );

        _userRecipesFuture.then((Box<dynamic> box) {
          final List<dynamic>? currentRecipes =
              box.get('user_recipes') as List<dynamic>?;
          final String currentHash = currentRecipes?.toString() ?? '';

          if (_lastUserRecipesHash == currentHash) {
            debugPrint(
              '[RecipesPageController] user_recipes değişmedi, atlanıyor',
            );
            return;
          }

          _lastUserRecipesHash = currentHash;

          final DateTime now = DateTime.now();
          _madeRecipesDebounceTimer?.cancel();

          if (_lastMadeRecipesUpdate != null &&
              now.difference(_lastMadeRecipesUpdate!).inSeconds < 2) {
            _madeRecipesDebounceTimer = Timer(
              const Duration(seconds: 2),
              () => loadMadeRecipes(),
            );
            return;
          }

          _lastMadeRecipesUpdate = now;
          loadMadeRecipes();
        });
      };

      _userRecipesFuture.then((Box<dynamic> box) {
        if (!_madeRecipesListenerAdded) {
          box.listenable().addListener(_madeRecipesListener!);
          _madeRecipesListenerAdded = true;

          final List<dynamic>? initialRecipes =
              box.get('user_recipes') as List<dynamic>?;
          _lastUserRecipesHash = initialRecipes?.toString() ?? '';

          debugPrint('[RecipesPageController] profile_box listener eklendi');
        }
      });
    }

    // Pantry listener
    _pantrySubscription?.cancel();
    _pantrySubscription = pantryCubit.stream.listen((PantryState pantryState) {
      if (pantryState is PantryLoaded && pantryState.items.isNotEmpty) {
        final List<String> currentItems = pantryState.items
            .map((item) => '${item.id}_${item.name}')
            .toList();

        if (_lastPantryItems.isEmpty) {
          _lastPantryItems = currentItems;
          return;
        }

        final bool itemsChanged =
            _lastPantryItems.length != currentItems.length ||
            !_lastPantryItems.every((item) => currentItems.contains(item));

        if (!itemsChanged) {
          return;
        }

        _lastPantryItems = currentItems;
        final DateTime now = DateTime.now();
        _pantryDebounceTimer?.cancel();

        if (_lastPantryUpdate != null &&
            now.difference(_lastPantryUpdate!).inSeconds < 3) {
          _pantryDebounceTimer = Timer(
            const Duration(seconds: 3),
            () => _handlePantryUpdate(),
          );
          return;
        }

        _lastPantryUpdate = now;
        _handlePantryUpdate();
      }
    });
  }

  Future<void> _loadAllData() async {
    try {
      // Load favorites
      favorites.value = await dataService.loadFavorites();

      // Load meal recipes
      final List<String> orderedMeals = MealTimeOrderHelper.getOrderedMeals();
      final List<Future<void>> mealLoadFutures = orderedMeals.map((
        String meal,
      ) async {
        if (_isLoadingMeal[meal] == true) {
          debugPrint(
            '[RecipesPageController] Meal zaten yükleniyor, atlanıyor: $meal',
          );
          return;
        }

        try {
          final List<Recipe> mealRecipes = await dataService.loadMealRecipes(
            userId,
            meal,
          );

          switch (meal) {
            case 'breakfast':
              breakfastRecipes.value = mealRecipes;
              break;
            case 'snack':
              snackRecipes.value = mealRecipes;
              break;
            case 'lunch':
              lunchRecipes.value = mealRecipes;
              break;
            case 'dinner':
              dinnerRecipes.value = mealRecipes;
              break;
          }
        } catch (e) {
          debugPrint('[RecipesPageController] Meal yükleme hatası ($meal): $e');
        }
      }).toList();

      await Future.wait(mealLoadFutures);

      // Load made recipes
      madeRecipes.value = await dataService.loadMadeRecipes();

      // Combine all recipes for search
      _updateAllCachedRecipes();
    } on Exception catch (e) {
      debugPrint('[RecipesPageController] Error loading data: $e');
    }
  }

  void _updateAllCachedRecipes() {
    final List<Recipe> combined = <Recipe>[
      ...favorites.value,
      ...breakfastRecipes.value,
      ...snackRecipes.value,
      ...lunchRecipes.value,
      ...dinnerRecipes.value,
      ...madeRecipes.value,
    ];

    // Remove duplicates by title
    final Set<String> seenTitles = <String>{};
    allCachedRecipes.value = combined.where((Recipe recipe) {
      if (seenTitles.contains(recipe.title)) {
        return false;
      }
      seenTitles.add(recipe.title);
      return true;
    }).toList();

    // Update combined data notifier
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

  Future<void> _loadFavorites() async {
    try {
      favorites.value = await dataService.loadFavorites();
      _updateAllCachedRecipes();
    } on Exception catch (e) {
      debugPrint('[RecipesPageController] Error loading favorites: $e');
    }
  }

  Future<void> loadMadeRecipes() async {
    debugPrint('[RecipesPageController] _loadMadeRecipes çağrıldı');
    try {
      madeRecipes.value = await dataService.loadMadeRecipes();
      _updateAllCachedRecipes();
      debugPrint(
        '[RecipesPageController] ${madeRecipes.value.length} yaptıklarım tarifi yüklendi',
      );
    } on Exception catch (e) {
      debugPrint('[RecipesPageController] Error loading made recipes: $e');
    }
  }

  void _handlePantryUpdate() {
    if (_isLoadingRecipes) {
      return;
    }

    debugPrint(
      '[RecipesPageController] Pantry değişti, öneriler güncelleniyor...',
    );
    _isLoadingRecipes = true;
    recipesCubit
        .load(userId)
        .then((_) {
          _isLoadingRecipes = false;
        })
        .catchError((Object error) {
          _isLoadingRecipes = false;
          debugPrint(
            '[RecipesPageController] Pantry güncelleme hatası: $error',
          );
        });
  }

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

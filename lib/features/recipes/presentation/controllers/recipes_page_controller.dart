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
/// TODO(SOLID-SRP): This controller has too many responsibilities:
/// - Data loading (should be in RecipesPageDataService)
/// - State management (should be in RecipesCubit)
/// - Cache management (should be in CacheService)
/// - Listener management (should be in ListenerService)
/// Consider refactoring following Single Responsibility Principle
/// TODO(RESPONSIVE): Add responsive breakpoints for different screen sizes
/// TODO(LOCALIZATION): Ensure all debug messages are localization-ready
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
  bool _isDisposed = false;

  // Cache kontrolü için flag - static olarak tutuluyor
  static final Map<String, bool> _initialLoadFlags = <String, bool>{};

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

    // User bazlı ilk yükleme kontrolü
    final bool hasLoadedForUser = _initialLoadFlags[userId] ?? false;

    // Başlangıçta tüm meal'ler için loading state'lerini true yap
    // Bu sayede "Henüz tarif yok" mesajı yerine loading indicator gösterilir
    final List<String> orderedMeals = MealTimeOrderHelper.getOrderedMeals();
    final Map<String, bool> initialLoadingStates = <String, bool>{
      'breakfast': false,
      'snack': false,
      'lunch': false,
      'dinner': false,
      'favorites': false,
      'made': false,
    };

    // İlk yükleme için tüm meal'leri loading yap
    if (!hasLoadedForUser) {
      for (final String meal in orderedMeals) {
        initialLoadingStates[meal] = true;
        _isLoadingMeal[meal] = true;
      }
    }

    loadingStates.value = initialLoadingStates;
    _updateAllCachedRecipes();

    if (!hasLoadedForUser) {
      // İlk kez bu user için yükleme yapılıyor
      _initialLoadFlags[userId] = true;
      _loadAllData();
    } else {
      // Daha önce yüklenmiş, cache'den hızlı yükleme
      _loadFromCache();
    }
  }

  /// Load data from cache only (no API calls)
  Future<void> _loadFromCache() async {
    if (_isDisposed) {
      return;
    }

    try {
      // Load favorites from cache
      favorites.value = await dataService.loadFavorites();

      // Load meal recipes from cache (loadMeal will check cache first)
      final List<String> orderedMeals = MealTimeOrderHelper.getOrderedMeals();
      for (final String meal in orderedMeals) {
        if (_isDisposed) {
          return;
        }

        // Set loading state for this meal
        _isLoadingMeal[meal] = true;
        if (!_isDisposed) {
          loadingStates.value = <String, bool>{
            ...loadingStates.value,
            meal: true,
          };
          _updateAllCachedRecipes();
        }

        try {
          // loadMeal cache kontrolü yapıyor, cache varsa API çağrısı yapmıyor
          final List<Recipe> mealRecipes = await dataService.loadMealRecipes(
            userId,
            meal,
          );

          if (_isDisposed) {
            return;
          }

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
          debugPrint(
            '[RecipesPageController] Cache yükleme hatası ($meal): $e',
          );
        } finally {
          // Clear loading state
          _isLoadingMeal[meal] = false;
          if (!_isDisposed) {
            loadingStates.value = <String, bool>{
              ...loadingStates.value,
              meal: false,
            };
            _updateAllCachedRecipes();
          }
        }
      }

      if (_isDisposed) {
        return;
      }

      // Load made recipes
      madeRecipes.value = await dataService.loadMadeRecipes();

      if (_isDisposed) {
        return;
      }

      // Combine all recipes for search
      _updateAllCachedRecipes();
    } on Exception catch (e) {
      debugPrint('[RecipesPageController] Error loading from cache: $e');
    }
  }

  void _setupListeners() {
    if (_isDisposed) {
      return;
    }

    // Favorites listener
    _favoritesListener = () {
      if (!_isDisposed) {
        _loadFavorites();
      }
    };
    _favoritesFuture.then((Box<dynamic> box) {
      if (!_isDisposed && _favoritesListener != null) {
        box.listenable().addListener(_favoritesListener!);
      }
    });

    // Made recipes listener
    if (!_madeRecipesListenerAdded && !_isDisposed) {
      _madeRecipesListener = () {
        if (_isDisposed) {
          return;
        }

        debugPrint(
          '[RecipesPageController] profile_box değişti, yaptıklarım kontrol ediliyor...',
        );

        _userRecipesFuture.then((Box<dynamic> box) {
          if (_isDisposed) {
            return;
          }

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
            _madeRecipesDebounceTimer = Timer(const Duration(seconds: 2), () {
              if (!_isDisposed) {
                loadMadeRecipes();
              }
            });
            return;
          }

          _lastMadeRecipesUpdate = now;
          if (!_isDisposed) {
            loadMadeRecipes();
          }
        });
      };

      _userRecipesFuture.then((Box<dynamic> box) {
        if (!_isDisposed &&
            !_madeRecipesListenerAdded &&
            _madeRecipesListener != null) {
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
    if (_isDisposed) {
      return;
    }

    _pantrySubscription?.cancel();
    _pantrySubscription = pantryCubit.stream.listen((PantryState pantryState) {
      if (_isDisposed) {
        return;
      }

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
          _pantryDebounceTimer = Timer(const Duration(seconds: 3), () {
            if (!_isDisposed) {
              _handlePantryUpdate();
            }
          });
          return;
        }

        _lastPantryUpdate = now;
        if (!_isDisposed) {
          _handlePantryUpdate();
        }
      }
    });
  }

  Future<void> _loadAllData() async {
    if (_isDisposed) {
      return;
    }

    try {
      // Load favorites
      if (!_isDisposed) {
        favorites.value = await dataService.loadFavorites();
      }

      if (_isDisposed) {
        return;
      }

      // Load meal recipes
      final List<String> orderedMeals = MealTimeOrderHelper.getOrderedMeals();
      final List<Future<void>> mealLoadFutures = orderedMeals.map((
        String meal,
      ) async {
        if (_isDisposed) {
          return;
        }

        // Set loading state (eğer zaten true değilse)
        if (_isLoadingMeal[meal] != true) {
          _isLoadingMeal[meal] = true;
          if (!_isDisposed) {
            loadingStates.value = <String, bool>{
              ...loadingStates.value,
              meal: true,
            };
            _updateAllCachedRecipes();
          }
        }

        try {
          final List<Recipe> mealRecipes = await dataService.loadMealRecipes(
            userId,
            meal,
          );

          if (_isDisposed) {
            return;
          }

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
        } finally {
          // Clear loading state - HER ZAMAN temizle
          _isLoadingMeal[meal] = false;
          if (!_isDisposed) {
            loadingStates.value = <String, bool>{
              ...loadingStates.value,
              meal: false,
            };
            _updateAllCachedRecipes();
          }
        }
      }).toList();

      await Future.wait(mealLoadFutures);

      if (_isDisposed) {
        return;
      }

      // Load made recipes
      madeRecipes.value = await dataService.loadMadeRecipes();

      if (_isDisposed) {
        return;
      }

      // Combine all recipes for search
      _updateAllCachedRecipes();
    } on Exception catch (e) {
      debugPrint('[RecipesPageController] Error loading data: $e');
    }
  }

  void _updateAllCachedRecipes() {
    if (_isDisposed) {
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

    // Remove duplicates by title
    final Set<String> seenTitles = <String>{};
    final List<Recipe> uniqueRecipes = combined.where((Recipe recipe) {
      if (seenTitles.contains(recipe.title)) {
        return false;
      }
      seenTitles.add(recipe.title);
      return true;
    }).toList();

    if (_isDisposed) {
      return;
    }

    allCachedRecipes.value = uniqueRecipes;

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
    if (_isDisposed) {
      return;
    }

    try {
      final List<Recipe> loadedFavorites = await dataService.loadFavorites();

      if (_isDisposed) {
        return;
      }

      favorites.value = loadedFavorites;
      _updateAllCachedRecipes();
    } on Exception catch (e) {
      debugPrint('[RecipesPageController] Error loading favorites: $e');
    }
  }

  Future<void> loadMadeRecipes() async {
    if (_isDisposed) {
      return;
    }

    debugPrint('[RecipesPageController] _loadMadeRecipes çağrıldı');
    try {
      final List<Recipe> loadedMadeRecipes = await dataService
          .loadMadeRecipes();

      if (_isDisposed) {
        return;
      }

      madeRecipes.value = loadedMadeRecipes;
      _updateAllCachedRecipes();
      debugPrint(
        '[RecipesPageController] ${madeRecipes.value.length} yaptıklarım tarifi yüklendi',
      );
    } on Exception catch (e) {
      debugPrint('[RecipesPageController] Error loading made recipes: $e');
    }
  }

  void _handlePantryUpdate() {
    if (_isDisposed || _isLoadingRecipes) {
      return;
    }

    debugPrint(
      '[RecipesPageController] Pantry değişti, öneriler güncelleniyor...',
    );
    _isLoadingRecipes = true;
    recipesCubit
        .load(userId)
        .then((_) {
          if (!_isDisposed) {
            _isLoadingRecipes = false;
          }
        })
        .catchError((Object error) {
          if (!_isDisposed) {
            _isLoadingRecipes = false;
          }
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
    _isDisposed = true;

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

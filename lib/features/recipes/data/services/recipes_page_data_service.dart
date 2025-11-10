// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_cubit.dart';

/// Service for loading recipes page data - SRP: Single responsibility for data loading
class RecipesPageDataService {
  /// Constructor
  RecipesPageDataService({
    required this.recipesCubit,
    UserRecipeService? userRecipeService,
  }) : _userRecipeService = userRecipeService ?? sl<UserRecipeService>();

  final RecipesCubit recipesCubit;
  final UserRecipeService _userRecipeService;

  /// Load favorites from Hive
  Future<List<Recipe>> loadFavorites() async {
    final Box<dynamic> favoritesBox = Hive.isBoxOpen('favorite_recipes')
        ? Hive.box<dynamic>('favorite_recipes')
        : await Hive.openBox<dynamic>('favorite_recipes');

    return favoritesBox.values
        .map<Recipe>(
          (dynamic value) => Recipe.fromMap(value as Map<dynamic, dynamic>),
        )
        .toList();
  }

  /// Load recipes for a specific meal
  Future<List<Recipe>> loadMealRecipes(String userId, String meal) async {
    return recipesCubit.loadMeal(userId, meal);
  }

  /// Load made recipes (recipes marked as made - with or without photo)
  Future<List<Recipe>> loadMadeRecipes() async {
    debugPrint('[RecipesPageDataService] Yaptıklarım yükleniyor...');
    final List<UserRecipe> allRecipes = _userRecipeService.fetch();
    debugPrint('[RecipesPageDataService] Toplam ${allRecipes.length} tarif bulundu');
    
    // Yaptıklarım: createManual ile eklenen TÜM tarifler
    // (isAIRecommendation true/false fark etmez, createManual ile eklenen her tarif "yaptım" sayılır)
    final List<UserRecipe> madeUserRecipes = allRecipes.toList();
    
    debugPrint('[RecipesPageDataService] ${madeUserRecipes.length} yaptıklarım tarifi bulundu');
    for (final UserRecipe ur in madeUserRecipes) {
      debugPrint('[RecipesPageDataService] - ${ur.title} (imagePath: ${ur.imagePath ?? "yok"}, isAI: ${ur.isAIRecommendation})');
    }

    return madeUserRecipes
        .map<Recipe>(
          (UserRecipe ur) => Recipe(
            id: ur.id,
            title: ur.title,
            ingredients: ur.ingredients,
            steps: ur.steps,
            imageUrl: ur.imagePath,
            category: ur.tags.isNotEmpty ? ur.tags.first : null,
          ),
        )
        .toList();
  }

  /// Load all meal recipes in parallel
  Future<Map<String, List<Recipe>>> loadAllMealRecipes(String userId) async {
    final List<String> orderedMeals = <String>[
      'breakfast',
      'snack',
      'lunch',
      'dinner',
    ];

    final Map<String, List<Recipe>> mealRecipes = <String, List<Recipe>>{};

    final List<Future<void>> mealLoadFutures = orderedMeals.map(
      (String meal) async {
        try {
          final List<Recipe> recipes = await loadMealRecipes(userId, meal);
          mealRecipes[meal] = recipes;
        } catch (e) {
          debugPrint('[RecipesPageDataService] Meal yükleme hatası ($meal): $e');
          mealRecipes[meal] = <Recipe>[];
        }
      },
    ).toList();

    await Future.wait(mealLoadFutures);
    return mealRecipes;
  }
}


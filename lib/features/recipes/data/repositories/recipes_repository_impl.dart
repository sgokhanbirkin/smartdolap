// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

class RecipesRepositoryImpl implements IRecipesRepository {
  RecipesRepositoryImpl(this._firestore, this._pantry, this._openai);

  final FirebaseFirestore _firestore;
  final IPantryRepository _pantry;
  final IOpenAIService _openai;

  @override
  Future<List<Recipe>> suggestFromPantry({required String userId}) async {
    final List<dynamic> pantryItemsRaw = await _pantry.getItems(userId: userId);
    final List<PantryItem> pantryItems = pantryItemsRaw.cast<PantryItem>();
    final List<Ingredient> ingredients = pantryItems
        .map<Ingredient>(
          (PantryItem i) =>
              Ingredient(name: i.name, unit: i.unit, quantity: i.quantity),
        )
        .toList();

    final List<RecipeSuggestion> suggestions = await _openai.suggestRecipes(
      ingredients,
      servings: 2,
      count: 6,
    );

    final List<Recipe> recipes = <Recipe>[];
    for (final RecipeSuggestion s in suggestions) {
      final DocumentReference<Map<String, dynamic>> doc = _firestore
          .collection('recipes')
          .doc();
      final Set<String> pantryNames = ingredients
          .map((Ingredient e) => e.name.toLowerCase())
          .toSet();
      final int missing = s.ingredients
          .where((String name) => !pantryNames.contains(name.toLowerCase()))
          .length;

      await doc.set(<String, dynamic>{
        'title': s.title,
        'ingredients': s.ingredients,
        'steps': s.steps,
        'calories': s.calories,
        'durationMinutes': s.durationMinutes,
        'difficulty': s.difficulty,
        'imageUrl': s.imageUrl,
        'category': s.category,
        'missingCount': missing,
        'fiber': s.fiber,
        'createdAt': DateTime.now().toIso8601String(),
      });
      recipes.add(
        Recipe(
          id: doc.id,
          title: s.title,
          ingredients: s.ingredients,
          steps: s.steps,
          calories: s.calories,
          durationMinutes: s.durationMinutes,
          difficulty: s.difficulty,
          imageUrl: s.imageUrl,
          category: s.category,
          missingCount: missing,
          fiber: s.fiber,
        ),
      );
    }
    return recipes;
  }
}

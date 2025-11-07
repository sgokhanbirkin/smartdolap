// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/domain/repositories/i_recipes_repository.dart';
import 'package:smartdolap/product/services/image_lookup_service.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

class RecipesRepositoryImpl implements IRecipesRepository {
  RecipesRepositoryImpl(
    this._firestore,
    this._pantry,
    this._openai,
    this._promptPrefs,
    this._imageLookup,
  );

  final FirebaseFirestore _firestore;
  final IPantryRepository _pantry;
  final IOpenAIService _openai;
  final PromptPreferenceService _promptPrefs;
  final ImageLookupService _imageLookup;

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

    final PromptPreferences prefs = _promptPrefs.getPreferences();
    final String contextPrompt = prefs.composePrompt(
      tr(
        'pantry_ingredients_prompt',
        namedArgs: <String, String>{
          'ingredients': ingredients.map((Ingredient e) => e.name).join(', '),
        },
      ),
    );

    final List<RecipeSuggestion> suggestions = await _openai.suggestRecipes(
      ingredients,
      servings: prefs.servings,
      query: contextPrompt,
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

      String? imageUrl = s.imageUrl;
      // OpenAI'den gelen imageUrl'ler genelde çalışmıyor, ImageLookupService kullan
      if (imageUrl == null ||
          imageUrl.isEmpty ||
          imageUrl.contains('example.com')) {
        imageUrl = await _imageLookup.search(
          '${s.title} ${tr('recipe_search_suffix')}',
        );
      }

      await doc.set(<String, dynamic>{
        'title': s.title,
        'ingredients': s.ingredients,
        'steps': s.steps,
        'calories': s.calories,
        'durationMinutes': s.durationMinutes,
        'difficulty': s.difficulty,
        'imageUrl': imageUrl,
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
          imageUrl: imageUrl,
          category: s.category,
          missingCount: missing,
          fiber: s.fiber,
        ),
      );
    }
    await _promptPrefs.incrementGenerated(recipes.length);
    return recipes;
  }

  @override
  Future<Recipe?> getRecipeDetail(String recipeId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('recipes')
          .doc(recipeId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final Map<String, dynamic> data = doc.data()!;
      return Recipe(
        id: doc.id,
        title: data['title'] as String? ?? '',
        ingredients: (data['ingredients'] as List<dynamic>?)
                ?.map<String>((dynamic e) => e.toString())
                .toList() ??
            <String>[],
        steps: (data['steps'] as List<dynamic>?)
                ?.map<String>((dynamic e) => e.toString())
                .toList() ??
            <String>[],
        calories: data['calories'] as int?,
        durationMinutes: data['durationMinutes'] as int?,
        difficulty: data['difficulty'] as String?,
        imageUrl: data['imageUrl'] as String?,
        category: data['category'] as String?,
        missingCount: data['missingCount'] as int?,
        fiber: (data['fiber'] as num?)?.toInt(),
      );
    } catch (e) {
      return null;
    }
  }
}

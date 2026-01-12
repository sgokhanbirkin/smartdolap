import 'package:smartdolap/core/constants/api_constants.dart';
import 'package:smartdolap/core/services/api_service.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/entities/ingredient.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

/// Service to interact with Backend Recipe API
class RecipeApiService {
  RecipeApiService(this._apiService);

  final ApiService _apiService;

  /// Generate recipes from ingredients
  Future<List<RecipeSuggestion>> generateRecipes({
    required List<Ingredient> ingredients,
    int servings = 2,
    int count = 6,
    String? query,
    List<String>? excludeTitles,
    String? meal,
  }) async {
    Logger.info('[RecipeApiService] Generating recipes via Backend...');

    try {
      // Use dio directly for custom payload
      final response = await _apiService.dio.post<Map<String, dynamic>>(
        ApiConstants.generateRecipe,
        data: <String, dynamic>{
          'ingredients': ingredients
              .map(
                (e) => {'name': e.name, 'quantity': e.quantity, 'unit': e.unit},
              )
              .toList(),
          'servings': servings,
          'count': count,
          'query': query,
          'excludeTitles': excludeTitles,
          'meal': meal,
          'preferences': {'servings': servings, 'meal': meal},
        },
      );

      if (response.data == null) {
        throw Exception('Empty response from backend');
      }

      if (response.data!['success'] == true) {
        final Map<String, dynamic> data =
            response.data!['data'] as Map<String, dynamic>;
        final List<dynamic> recipesJson = data['recipes'] as List<dynamic>;

        return recipesJson.map((e) {
          final Map<String, dynamic> item = e as Map<String, dynamic>;
          return RecipeSuggestion(
            title: item['title'] as String,
            ingredients: (item['ingredients'] as List).cast<String>(),
            steps: (item['steps'] as List).cast<String>(),
            calories: item['calories'] as int?,
            durationMinutes: item['durationMinutes'] as int?,
            difficulty: item['difficulty'] as String?,
            category: item['category'] as String?,
            fiber: item['fiber'] as int?,
            imageSearchQuery: item['imageSearchQuery'] as String?,
            imageUrl: item['imageUrl'] as String?,
          );
        }).toList();
      } else {
        throw Exception(response.data!['error'] ?? 'Backend error');
      }
    } catch (e) {
      Logger.error('[RecipeApiService] Recipe generation failed', e);
      rethrow;
    }
  }
}

// ignore_for_file: public_member_api_docs

import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';

/// User recipe repository contract — data source abstraction
/// Follows Dependency Inversion Principle - high-level modules depend on abstraction
abstract class IUserRecipeRepository {
  /// Returns all persisted recipes in insertion order
  List<UserRecipe> fetch();

  /// Saves the provided recipe and returns the refreshed cache
  Future<List<UserRecipe>> addRecipe(UserRecipe recipe);

  /// Creates a manual recipe entry from raw form values
  Future<List<UserRecipe>> createManual({
    required String title,
    required List<String> ingredients,
    required List<String> steps,
    String description = '',
    List<String>? tags,
    String? imagePath,
    String? videoPath,
  });

  /// Deletes recipes by their titles
  Future<List<UserRecipe>> deleteRecipesByTitles(List<String> titles);
}


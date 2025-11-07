import 'package:hive/hive.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:uuid/uuid.dart';

/// Stores user created and AI curated recipes in Hive.
class UserRecipeService {
  /// Creates a service backed by the provided Hive box.
  UserRecipeService(this._box);

  final Box<dynamic> _box;
  static const String _userRecipesKey = 'user_recipes';
  static const Uuid _uuid = Uuid();

  /// Returns all persisted recipes in insertion order.
  List<UserRecipe> fetch() {
    final List<dynamic>? raw = _box.get(_userRecipesKey) as List<dynamic>?;
    if (raw == null) {
      return <UserRecipe>[];
    }
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(UserRecipe.fromMap)
        .toList(growable: true);
  }

  /// Saves the provided recipe and returns the refreshed cache.
  Future<List<UserRecipe>> addRecipe(UserRecipe recipe) async {
    final List<UserRecipe> all = fetch();
    all.add(recipe);
    await _box.put(
      _userRecipesKey,
      all.map((UserRecipe e) => e.toMap()).toList(growable: false),
    );
    return all;
  }

  /// Creates a manual recipe entry from raw form values.
  Future<List<UserRecipe>> createManual({
    required String title,
    required List<String> ingredients,
    required List<String> steps,
    String description = '',
    List<String>? tags,
    String? imagePath,
    String? videoPath,
  }) async {
    final UserRecipe recipe = UserRecipe(
      id: _uuid.v4(),
      title: title,
      description: description,
      ingredients: ingredients,
      steps: steps,
      tags: tags ?? <String>[],
      imagePath: imagePath,
      videoPath: videoPath,
      createdAt: DateTime.now(),
    );
    return addRecipe(recipe);
  }
}

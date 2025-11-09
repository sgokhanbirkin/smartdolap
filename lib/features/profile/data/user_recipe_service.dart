import 'package:hive/hive.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_user_recipe_repository.dart';
import 'package:uuid/uuid.dart';

/// Stores user created and AI curated recipes in Hive.
/// Implements IUserRecipeRepository to follow Dependency Inversion Principle
class UserRecipeService implements IUserRecipeRepository {
  /// Creates a service backed by the provided Hive box.
  UserRecipeService(this._box);

  final Box<dynamic> _box;
  static const String _userRecipesKey = 'user_recipes';
  static const Uuid _uuid = Uuid();

  @override
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

  @override
  Future<List<UserRecipe>> addRecipe(UserRecipe recipe) async {
    final List<UserRecipe> all = fetch();
    all.add(recipe);
    await _box.put(
      _userRecipesKey,
      all.map((UserRecipe e) => e.toMap()).toList(growable: false),
    );
    return all;
  }

  @override
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

  @override
  Future<List<UserRecipe>> deleteRecipesByTitles(List<String> titles) async {
    final List<UserRecipe> all = fetch();
    final Set<String> titlesSet = titles.toSet();
    final List<UserRecipe> remaining = all
        .where((UserRecipe r) => !titlesSet.contains(r.title))
        .toList();
    await _box.put(
      _userRecipesKey,
      remaining.map((UserRecipe e) => e.toMap()).toList(growable: false),
    );
    return remaining;
  }
}

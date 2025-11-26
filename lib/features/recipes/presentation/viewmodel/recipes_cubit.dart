import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_state.dart';

/// RecipesCubit - State-only cubit for recipes feature.
///
/// Responsibilities:
/// - Emit loading/loaded/error states
/// - Hold no business logic (delegated to RecipesViewModel)
/// - Provide helper getters for current state
///
/// SOLID Principles:
/// - Single Responsibility: Manages state emission only
/// - Open/Closed: Easily extended with new state helpers
/// - Dependency Inversion: Consumers depend on this abstraction
class RecipesCubit extends Cubit<RecipesState> {
  /// Creates a recipes cubit with initial state.
  RecipesCubit() : super(const RecipesInitial());

  /// Emit loading state.
  void setLoading() => emit(const RecipesLoading());

  /// Emit loaded state with recipes.
  void setLoaded(
    List<Recipe> recipes, {
    bool isLoadingMore = false,
    Map<String, dynamic>? activeFilters,
    List<Recipe>? allRecipes,
  }) => emit(
    RecipesLoaded(
      recipes,
      isLoadingMore: isLoadingMore,
      activeFilters: activeFilters ?? const <String, dynamic>{},
      allRecipes: allRecipes,
    ),
  );

  /// Emit failure state with localized message key.
  void setFailure(String messageKey) => emit(RecipesFailure(messageKey));

  /// Read current cubit state.
  RecipesState get currentState => state;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';

part 'comment_state.freezed.dart';

/// Comment state - represents the state of comments loading/display
@freezed
class CommentState with _$CommentState {
  /// Initial state
  const factory CommentState.initial() = _Initial;

  /// Loading state
  const factory CommentState.loading() = _Loading;

  /// Loaded state with comments
  const factory CommentState.loaded(List<RecipeComment> comments) = _Loaded;

  /// Error state
  const factory CommentState.error(String message) = _Error;
}

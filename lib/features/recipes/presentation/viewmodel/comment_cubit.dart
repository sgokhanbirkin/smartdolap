import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/add_comment_usecase.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/delete_comment_usecase.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/watch_global_comments_usecase.dart';
import 'package:smartdolap/features/recipes/domain/use_cases/watch_household_comments_usecase.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_state.dart';
import 'package:uuid/uuid.dart';

/// Comment cubit - manages comment state and operations
class CommentCubit extends Cubit<CommentState> {
  /// Comment cubit constructor
  CommentCubit({
    required this.watchGlobalCommentsUseCase,
    required this.watchHouseholdCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(const CommentState.initial());

  final WatchGlobalCommentsUseCase watchGlobalCommentsUseCase;
  final WatchHouseholdCommentsUseCase watchHouseholdCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  StreamSubscription<List<RecipeComment>>? _commentsSubscription;
  static const Uuid _uuid = Uuid();

  /// Watch comments for a recipe
  /// If isHouseholdOnly is true, watches household comments
  /// Otherwise, watches global comments
  void watchComments(
    String recipeId, {
    String? householdId,
    bool isHouseholdOnly = false,
  }) {
    emit(const CommentState.loading());

    _commentsSubscription?.cancel();

    final Stream<List<RecipeComment>> commentsStream = isHouseholdOnly
        ? watchHouseholdCommentsUseCase.call(recipeId, householdId!)
        : watchGlobalCommentsUseCase.call(recipeId);

    _commentsSubscription = commentsStream.listen(
      (List<RecipeComment> comments) {
        emit(CommentState.loaded(comments));
      },
      onError: (Object error) {
        emit(CommentState.error(error.toString()));
      },
    );
  }

  /// Add a comment
  Future<void> addComment(
    String recipeId,
    String text,
    String userId,
    String userName, {
    String? avatarId,
    String? householdId,
    bool isHouseholdOnly = false,
    int? rating,
  }) async {
    if (text.trim().isEmpty) {
      return;
    }

    // Don't emit error state if we're already in loaded state
    // Just rethrow the error so caller can handle it
    try {
      final RecipeComment comment = RecipeComment(
        id: _uuid.v4(),
        recipeId: recipeId,
        userId: userId,
        userName: userName,
        avatarId: avatarId,
        text: text.trim(),
        createdAt: DateTime.now(),
        isHouseholdOnly: isHouseholdOnly,
        householdId: householdId,
        rating: rating,
      );

      await addCommentUseCase.call(comment);
      // Success - state will be updated by stream listener
    } catch (e) {
      // Only emit error if we're not in loaded state
      // Otherwise, let the stream handle state updates
      state.maybeWhen(
        loaded: (_) {
          // Don't change state, just rethrow
        },
        orElse: () {
          emit(CommentState.error(e.toString()));
        },
      );
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(
    String commentId,
    String recipeId, {
    String? householdId,
    bool isHouseholdOnly = false,
  }) async {
    try {
      await deleteCommentUseCase.call(
        commentId: commentId,
        recipeId: recipeId,
        isHouseholdOnly: isHouseholdOnly,
        householdId: householdId,
      );
      // Success - state will be updated by stream listener
    } catch (e) {
      // Only emit error if we're not in loaded state
      state.maybeWhen(
        loaded: (_) {
          // Don't change state, just rethrow
        },
        orElse: () {
          emit(CommentState.error(e.toString()));
        },
      );
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _commentsSubscription?.cancel();
    return super.close();
  }
}

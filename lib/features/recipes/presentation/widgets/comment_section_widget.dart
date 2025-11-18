import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_state.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/comment_item_widget.dart';

/// Comment section widget - displays comments list and input field
/// Responsive: Adapts layout for tablet/desktop screens
class CommentSectionWidget extends StatefulWidget {
  /// Comment section widget constructor
  const CommentSectionWidget({
    required this.recipeId,
    required this.currentUserId,
    required this.currentUserName,
    required this.isHouseholdOnly,
    this.currentAvatarId,
    this.householdId,
    super.key,
  });

  /// Recipe ID
  final String recipeId;

  /// Current user ID
  final String currentUserId;

  /// Current user name
  final String currentUserName;

  /// Current user avatar ID
  final String? currentAvatarId;

  /// Whether comments are household-only (true) or global (false)
  final bool isHouseholdOnly;

  /// Household ID (required if isHouseholdOnly is true)
  final String? householdId;

  @override
  State<CommentSectionWidget> createState() => _CommentSectionWidgetState();
}

class _CommentSectionWidgetState extends State<CommentSectionWidget> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Start watching comments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentCubit>().watchComments(
        widget.recipeId,
        householdId: widget.householdId,
        isHouseholdOnly: widget.isHouseholdOnly,
      );
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final String text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    try {
      await context.read<CommentCubit>().addComment(
        widget.recipeId,
        text,
        widget.currentUserId,
        widget.currentUserName,
        avatarId: widget.currentAvatarId,
        householdId: widget.householdId,
        isHouseholdOnly: widget.isHouseholdOnly,
      );

      _commentController.clear();
      _focusNode.unfocus();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('comment_error')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('delete_comment')),
        content: Text(tr('delete_comment_confirm')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<CommentCubit>().deleteComment(
          commentId,
          widget.recipeId,
          householdId: widget.householdId,
          isHouseholdOnly: widget.isHouseholdOnly,
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('comment_deleted')),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('comment_delete_error')),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;

    return BlocBuilder<CommentCubit, CommentState>(
      builder: (BuildContext context, CommentState state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section title
            Padding(
              padding: EdgeInsets.only(bottom: AppSizes.spacingM),
              child: Text(
                widget.isHouseholdOnly
                    ? tr('household_comments')
                    : tr('global_comments'),
                style: TextStyle(
                  fontSize: isTablet ? AppSizes.textXL : AppSizes.textL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Comments list
            Expanded(
              child: state.when(
                initial: () => const SizedBox.shrink(),
                loading: () => Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.spacingL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        SizedBox(height: AppSizes.spacingM),
                        Text(
                          tr('loading_comments'),
                          style: TextStyle(
                            fontSize: isTablet
                                ? AppSizes.textM
                                : AppSizes.textS,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loaded: (List<RecipeComment> comments) {
                  if (comments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.spacingL),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.comment_outlined,
                              size: (isTablet ? 64.0 : 48.0).sp,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            SizedBox(height: AppSizes.spacingM),
                            Text(
                              tr('no_comments'),
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppSizes.textM
                                    : AppSizes.textS,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: AppSizes.spacingL),
                    itemCount: comments.length,
                    itemBuilder: (BuildContext context, int index) {
                      final RecipeComment comment = comments[index];
                      return CommentItemWidget(
                        comment: comment,
                        currentUserId: widget.currentUserId,
                        onDelete: () => _deleteComment(comment.id),
                      );
                    },
                  );
                },
                error: (String message) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.spacingL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          size: (isTablet ? 64.0 : 48.0).sp,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: AppSizes.spacingM),
                        Text(
                          tr('comment_error'),
                          style: TextStyle(
                            fontSize: isTablet
                                ? AppSizes.textM
                                : AppSizes.textS,
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSizes.spacingXS),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: isTablet
                                ? AppSizes.textS
                                : AppSizes.textXS,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Comment input
            Container(
              padding: EdgeInsets.all(AppSizes.spacingS),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: tr('comment_hint'),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingS,
                          vertical: AppSizes.spacingXS,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingXS),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _postComment,
                    tooltip: tr('post_comment'),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

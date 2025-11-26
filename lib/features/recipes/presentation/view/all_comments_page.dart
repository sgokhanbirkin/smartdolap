import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_state.dart';
import 'package:smartdolap/features/recipes/presentation/widgets/comment_item_widget.dart';

/// All comments page - Shows all comments for a recipe
class AllCommentsPage extends StatelessWidget {
  /// All comments page constructor
  const AllCommentsPage({
    required this.recipeId,
    required this.currentUserId,
    required this.isHouseholdOnly,
    this.householdId,
    super.key,
  });

  final String recipeId;
  final String currentUserId;
  final bool isHouseholdOnly;
  final String? householdId;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;

    return BlocProvider<CommentCubit>(
      create: (_) => sl<CommentCubit>()
        ..watchComments(
          recipeId,
          householdId: householdId,
          isHouseholdOnly: isHouseholdOnly,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('all_comments')),
        ),
        body: BlocBuilder<CommentCubit, CommentState>(
          builder: (BuildContext context, CommentState state) => state.when(
              initial: () => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Calculate average rating
                final List<int> ratings = comments
                    .where((RecipeComment c) => c.rating != null)
                    .map((RecipeComment c) => c.rating!)
                    .toList();
                final double averageRating = ratings.isEmpty
                    ? 0.0
                    : ratings.reduce((int a, int b) => a + b) / ratings.length;

                return Column(
                  children: <Widget>[
                    // Average rating card
                    if (ratings.isNotEmpty)
                      Container(
                        margin: EdgeInsets.all(AppSizes.padding),
                        padding: EdgeInsets.all(AppSizes.spacingM),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              tr('average_rating'),
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppSizes.textM
                                    : AppSizes.textS,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: AppSizes.spacingS),
                            Row(
                              children: List<Widget>.generate(5, (int index) => Icon(
                                  index < averageRating.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 24.sp,
                                  color: Colors.amber,
                                )),
                            ),
                            SizedBox(width: AppSizes.spacingS),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppSizes.textL
                                    : AppSizes.textM,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: AppSizes.spacingXS),
                            Text(
                              '(${ratings.length} ${tr('ratings')})',
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppSizes.textS
                                    : AppSizes.textXS,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Comments list
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(AppSizes.padding),
                        itemCount: comments.length,
                        itemBuilder: (BuildContext context, int index) {
                          final RecipeComment comment = comments[index];
                          return CommentItemWidget(
                            comment: comment,
                            currentUserId: currentUserId,
                            onDelete: () => context
                                .read<CommentCubit>()
                                .deleteComment(
                                  comment.id,
                                  recipeId,
                                  householdId: householdId,
                                  isHouseholdOnly: isHouseholdOnly,
                                ),
                          );
                        },
                      ),
                    ),
                  ],
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
                          fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSizes.spacingXS),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: isTablet ? AppSizes.textS : AppSizes.textXS,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }
}


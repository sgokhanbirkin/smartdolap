import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_cubit.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/comment_state.dart';

/// Recipe rating widget - displays average rating and allows user to rate
class RecipeRatingWidget extends StatefulWidget {
  /// Recipe rating widget constructor
  const RecipeRatingWidget({
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
  State<RecipeRatingWidget> createState() => _RecipeRatingWidgetState();
}

class _RecipeRatingWidgetState extends State<RecipeRatingWidget> {
  int? _userRating;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;

    return BlocProvider<CommentCubit>(
      create: (_) => sl<CommentCubit>()
        ..watchComments(
          widget.recipeId,
          householdId: widget.householdId,
          isHouseholdOnly: widget.isHouseholdOnly,
        ),
      child: BlocBuilder<CommentCubit, CommentState>(
        builder: (BuildContext context, CommentState state) => state.maybeWhen(
          loaded: (List<RecipeComment> comments) {
            // Calculate average rating from comments
            final List<int> ratings = comments
                .where((RecipeComment c) => c.rating != null)
                .map((RecipeComment c) => c.rating!)
                .toList();

            // Find user's rating
            RecipeComment? userComment;
            userComment = comments.cast<RecipeComment?>().firstWhere(
              (RecipeComment? c) =>
                  c != null && c.userId == widget.currentUserId,
              orElse: () => null,
            );
            final int? existingUserRating = userComment?.rating;

            final double averageRating = ratings.isEmpty
                ? 0.0
                : ratings.reduce((int a, int b) => a + b) / ratings.length;

            return Container(
              padding: EdgeInsets.all(AppSizes.spacingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Average rating display
                  if (ratings.isNotEmpty) ...<Widget>[
                    Row(
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
                          children: List<Widget>.generate(
                            5,
                            (int index) => Icon(
                              index < averageRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 20.sp,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSizes.spacingXS),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.spacingM),
                  ],
                  // User rating section
                  Row(
                    children: <Widget>[
                      Text(
                        tr('your_rating'),
                        style: TextStyle(
                          fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      ...List<Widget>.generate(5, (int index) {
                        final int ratingValue = index + 1;
                        final bool isSelected =
                            (_userRating ?? existingUserRating ?? 0) >=
                            ratingValue;

                        return GestureDetector(
                          onTap: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _userRating = ratingValue;
                                  });
                                  _submitRating(ratingValue);
                                },
                          child: Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: Icon(
                              isSelected ? Icons.star : Icons.star_border,
                              size: 24.sp,
                              color: _isSubmitting ? Colors.grey : Colors.amber,
                            ),
                          ),
                        );
                      }),
                      if (_isSubmitting)
                        Padding(
                          padding: EdgeInsets.only(left: AppSizes.spacingS),
                          child: SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Future<void> _submitRating(int rating) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final CommentCubit cubit = context.read<CommentCubit>();

      // Kullanıcının mevcut yorumunu bul
      final CommentState currentState = cubit.state;
      final List<RecipeComment> comments = currentState.maybeWhen(
        loaded: (List<RecipeComment> c) => c,
        orElse: () => <RecipeComment>[],
      );

      RecipeComment? existingComment;
      existingComment = comments.cast<RecipeComment?>().firstWhere(
        (RecipeComment? c) => c != null && c.userId == widget.currentUserId,
        orElse: () => null,
      );

      // Kullanıcı bilgilerini al
      final AuthCubit authCubit = context.read<AuthCubit>();
      final AuthState authState = authCubit.state;

      final domain.User? user = authState.maybeWhen(
        authenticated: (domain.User u) => u,
        orElse: () => null,
      );

      if (user == null) {
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Eğer kullanıcının yorumu varsa ve sadece rating güncelleniyorsa
      // Yeni bir yorum ekle (sadece rating ile, text boş)
      if (existingComment == null) {
        // Yeni rating-only yorum ekle
        await cubit.addComment(
          widget.recipeId,
          '', // Boş text - sadece rating
          widget.currentUserId,
          user.displayName ?? user.email,
          avatarId: user.avatarId,
          householdId: widget.householdId,
          isHouseholdOnly: widget.isHouseholdOnly,
          rating: rating,
        );
      } else {
        // Mevcut yorumu güncelleme için yeni bir yorum ekle
        // (Not: Gerçek uygulamada updateComment metodu olmalı)
        // Şimdilik yeni bir yorum ekleyelim
        await cubit.addComment(
          widget.recipeId,
          existingComment.text.isEmpty ? '' : existingComment.text,
          widget.currentUserId,
          existingComment.userName,
          avatarId: existingComment.avatarId,
          householdId: widget.householdId,
          isHouseholdOnly: widget.isHouseholdOnly,
          rating: rating,
        );
      }

      setState(() {
        _isSubmitting = false;
      });
    } on Object {
      setState(() {
        _isSubmitting = false;
      });
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('rating_error')),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

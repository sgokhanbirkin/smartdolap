import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/features/recipes/domain/entities/recipe_comment.dart';

/// Comment item widget - displays a single comment
/// Responsive: Adapts layout for tablet/desktop screens
class CommentItemWidget extends StatelessWidget {
  /// Comment item widget constructor
  const CommentItemWidget({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
    super.key,
  });

  /// The comment to display
  final RecipeComment comment;

  /// Current user ID (to show delete button only for own comments)
  final String currentUserId;

  /// Callback when delete button is pressed
  final VoidCallback onDelete;

  /// Format time as relative (e.g., "2 hours ago", "just now")
  String _formatTime(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return tr('days_ago', args: <String>[difference.inDays.toString()]);
    } else if (difference.inHours > 0) {
      return tr('hours_ago', args: <String>[difference.inHours.toString()]);
    } else if (difference.inMinutes > 0) {
      return tr('minutes_ago', args: <String>[difference.inMinutes.toString()]);
    } else {
      return tr('just_now');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;
    final bool canDelete = comment.userId == currentUserId;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Avatar
          AvatarWidget(
            avatarId: comment.avatarId,
            size: isTablet ? 48.w : 40.w,
          ),
          SizedBox(width: AppSizes.spacingS),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // User name and time
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: TextStyle(
                          fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.spacingXS),
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: isTablet ? AppSizes.textS : AppSizes.textXS,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                // Rating stars (if available)
                if (comment.rating != null) ...<Widget>[
                  Row(
                    children: List<Widget>.generate(5, (int index) => Icon(
                        index < comment.rating!
                            ? Icons.star
                            : Icons.star_border,
                        size: (isTablet ? 16.0 : 14.0).sp,
                        color: Colors.amber,
                      )),
                  ),
                  SizedBox(height: 4.h),
                ],
                // Comment text
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                  ),
                ),
              ],
            ),
          ),
          // Delete button (only for own comments)
          if (canDelete)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: isTablet ? 24.sp : 20.sp,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onDelete,
              tooltip: tr('delete_comment'),
            ),
        ],
      ),
    );
  }
}

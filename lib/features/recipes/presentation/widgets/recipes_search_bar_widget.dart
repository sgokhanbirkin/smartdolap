import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Search bar widget for recipes page
class RecipesSearchBarWidget extends StatelessWidget {
  /// Creates a recipes search bar widget
  const RecipesSearchBarWidget({
    required this.controller,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    super.key,
  });

  /// Text editing controller for search input
  final TextEditingController controller;

  /// Current search query
  final String query;

  /// Callback when query changes
  final ValueChanged<String> onQueryChanged;

  /// Callback when clear button is pressed
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.padding),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radius * 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .shadow
                  .withValues(alpha: 0.05),
              blurRadius: AppSizes.spacingS,
              offset: Offset(0, AppSizes.spacingS),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onQueryChanged,
          style: TextStyle(
            fontSize: AppSizes.text,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: tr('search'),
            hintStyle: TextStyle(
              fontSize: AppSizes.text,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 24,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingM + 2,
            ),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}


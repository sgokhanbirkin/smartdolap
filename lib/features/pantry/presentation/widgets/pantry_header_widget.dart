import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/presentation/view/pantry_page.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/view_mode_toggle_widget.dart';

/// Widget for pantry page header with title, subtitle, search bar, and view mode toggle
class PantryHeaderWidget extends StatelessWidget {
  /// Creates a pantry header widget
  const PantryHeaderWidget({
    required this.searchController,
    required this.searchQuery,
    required this.viewMode,
    super.key,
  });

  /// Controller for search text field
  final TextEditingController searchController;

  /// ValueNotifier for search query (debounced)
  final ValueNotifier<String> searchQuery;

  /// ValueNotifier for view mode
  final ValueNotifier<PantryViewMode> viewMode;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        tr('pantry_title'),
        style: TextStyle(
          fontSize: AppSizes.textHeading,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      SizedBox(height: AppSizes.spacingXS),
      Text(
        tr('pantry_subtitle'),
        style: TextStyle(
          fontSize: AppSizes.textS,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingM),
      Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radius * 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: AppSizes.spacingS,
                    offset: Offset(0, AppSizes.spacingS),
                  ),
                ],
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: searchQuery,
                builder: (BuildContext context, String query, Widget? child) => TextField(
                  controller: searchController,
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
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
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
            ),
          ),
          SizedBox(width: AppSizes.spacingS),
          ValueListenableBuilder<PantryViewMode>(
            valueListenable: viewMode,
            builder: (BuildContext context, PantryViewMode mode, Widget? child) => ViewModeToggleWidget(
              viewMode: mode,
              onViewModeChanged: (PantryViewMode newMode) => viewMode.value = newMode,
            ),
          ),
        ],
      ),
    ],
  );
}


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';

/// Widget for action buttons at the bottom of get suggestions page
class GetSuggestionsActionButtonsWidget extends StatelessWidget {
  /// Creates action buttons widget
  const GetSuggestionsActionButtonsWidget({
    required this.selectedCount,
    required this.totalCount,
    required this.isLoading,
    required this.onToggleSelectAll,
    required this.onConfirm,
    super.key,
  });

  /// Number of selected ingredients
  final int selectedCount;

  /// Total number of ingredients
  final int totalCount;

  /// Whether loading state is active
  final bool isLoading;

  /// Callback when select all/deselect all is pressed
  final VoidCallback onToggleSelectAll;

  /// Callback when confirm button is pressed
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onToggleSelectAll,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  selectedCount == totalCount
                      ? tr('deselect_all')
                      : tr('select_all'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.spacingM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : onConfirm,
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(tr('get_suggestions')),
            ),
          ),
        ],
      ),
    );
}


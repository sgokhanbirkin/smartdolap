import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Widget for selecting expiry date
class ExpiryDatePickerWidget extends StatelessWidget {
  /// Creates an expiry date picker widget
  const ExpiryDatePickerWidget({
    required this.expiryDate,
    required this.onDateSelected,
    super.key,
  });

  /// The currently selected expiry date (nullable)
  final DateTime? expiryDate;

  /// Callback when a date is selected
  final ValueChanged<DateTime?> onDateSelected;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
      ),
    ),
    child: InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.padding * 0.75,
          vertical: AppSizes.padding * 0.6,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.calendar_today,
              size: AppSizes.iconS,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    tr('expiry_date'),
                    style: TextStyle(
                      fontSize: AppSizes.textS,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSizes.spacingXS * 0.5),
                  Text(
                    expiryDate == null
                        ? tr('expiry_date')
                        : '${expiryDate!.day}.'
                              '${expiryDate!.month}.'
                              '${expiryDate!.year}',
                    style: TextStyle(
                      fontSize: AppSizes.textS,
                      color: expiryDate == null
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: AppSizes.iconS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    ),
  );
}

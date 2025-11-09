import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/unit_dropdown_widget.dart';

/// Widget for quantity and unit fields
class PantryItemQuantityUnitWidget extends StatelessWidget {
  /// Creates a quantity and unit widget
  const PantryItemQuantityUnitWidget({
    required this.quantityController,
    required this.unitController,
    required this.unitOptions,
    required this.fieldDecoration,
    super.key,
  });

  /// Controller for quantity text field
  final TextEditingController quantityController;

  /// Controller for unit text field
  final TextEditingController unitController;

  /// Available unit options
  final List<String> unitOptions;

  /// Field decoration builder
  final InputDecoration Function(BuildContext, {String? hint}) fieldDecoration;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
            side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.padding * 0.75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  tr('quantity'),
                  style: TextStyle(
                    fontSize: AppSizes.textS,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSizes.spacingXS * 0.5),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: AppSizes.text),
                  decoration: fieldDecoration(
                    context,
                    hint: tr('pantry_quantity_placeholder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(width: AppSizes.spacingM),
      Expanded(
        child: UnitDropdownWidget(
          unitController: unitController,
          unitOptions: unitOptions,
        ),
      ),
    ],
  );
}


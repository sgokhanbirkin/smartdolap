import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';

/// Widget for selecting unit with autocomplete
class UnitDropdownWidget extends StatelessWidget {
  /// Creates a unit dropdown widget
  const UnitDropdownWidget({
    required this.unitController,
    required this.unitOptions,
    this.wrapInCard = true,
    super.key,
  });

  /// Controller for the unit text field
  final TextEditingController unitController;

  /// Available unit options
  final List<String> unitOptions;

  /// Whether to wrap content in a Card (default: true for AddPantryItemPage)
  final bool wrapInCard;

  InputDecoration _fieldDecoration(BuildContext context, {String? hint}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingS + 2,
        ),
      );

  Widget _buildContent(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        tr('unit'),
        style: TextStyle(
          fontSize: AppSizes.textS,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      SizedBox(height: AppSizes.spacingXS * 0.5),
      Autocomplete<String>(
        initialValue: TextEditingValue(text: unitController.text),
        optionsBuilder: (TextEditingValue v) {
          final String q = v.text.toLowerCase();
          return unitOptions.where((String o) => o.contains(q));
        },
        onSelected: (String v) => unitController.text = v,
        fieldViewBuilder: (
          BuildContext context,
          TextEditingController controller,
          FocusNode node,
          VoidCallback onFieldSubmitted,
        ) {
          controller.text = unitController.text;
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
          controller.addListener(() => unitController.text = controller.text);
          return TextFormField(
            controller: controller,
            focusNode: node,
            style: TextStyle(fontSize: AppSizes.text),
            decoration: _fieldDecoration(
              context,
              hint: tr('pantry_unit_placeholder'),
            ),
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: EdgeInsets.all(wrapInCard ? AppSizes.padding * 0.75 : 0),
      child: _buildContent(context),
    );

    if (!wrapInCard) {
      return content;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: content,
    );
  }
}


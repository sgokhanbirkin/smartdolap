import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';

/// Get suggestions dialog widget
class GetSuggestionsDialogWidget extends StatelessWidget {
  const GetSuggestionsDialogWidget({
    required this.items,
    required this.onConfirm,
    super.key,
  });

  final List<PantryItem> items;
  final ValueChanged<Map<String, String>> onConfirm;

  @override
  Widget build(BuildContext context) {
    final Set<String> selected = items.map((PantryItem e) => e.name).toSet();
    String meal = tr('dinner');

    return AlertDialog(
      title: Text(tr('select_ingredients')),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext ctx, StateSetter setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AppSizes.spacingS,
                  children: items
                      .map<Widget>(
                        (PantryItem e) => FilterChip(
                          label: Text(e.name),
                          selected: selected.contains(e.name),
                          onSelected: (bool v) {
                            setState(() {
                              if (v) {
                                selected.add(e.name);
                              } else {
                                selected.remove(e.name);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: AppSizes.verticalSpacingM),
                Text(tr('meal')),
                DropdownButton<String>(
                  value: meal,
                  isExpanded: true,
                  items:
                      <String>[
                            tr('breakfast'),
                            tr('lunch'),
                            tr('dinner'),
                            tr('snack'),
                          ]
                          .map(
                            (String m) => DropdownMenuItem<String>(
                              value: m,
                              child: Text(m),
                            ),
                          )
                          .toList(),
                  onChanged: (String? v) {
                    setState(() {
                      meal = v ?? meal;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(tr('cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            onConfirm(<String, String>{
              'ingredients': selected.join(','),
              'meal': meal,
            });
          },
          child: Text(tr('confirm')),
        ),
      ],
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/recipes/presentation/viewmodel/recipes_view_model.dart';

/// Filter dialog widget for recipes
class FilterDialogWidget extends StatelessWidget {
  const FilterDialogWidget({
    required this.items,
    required this.currentFilters,
    required this.onApply,
    super.key,
  });

  final List<PantryItem> items;
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>> onApply;

  @override
  Widget build(BuildContext context) {
    final Set<String> inc = <String>{
      ...?((currentFilters['ingredients'] as List<dynamic>?)?.cast<String>()),
    };
    String? meal = currentFilters['meal'] as String?;
    int? maxCal = currentFilters['maxCalories'] as int?;
    int? minFiber = currentFilters['minFiber'] as int?;

    return AlertDialog(
      title: Text(tr('recipes_title')),
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tr('select_ingredients')),
              SizedBox(height: AppSizes.verticalSpacingS),
              Wrap(
                spacing: AppSizes.spacingS,
                children: items
                    .map<Widget>(
                      (PantryItem e) => FilterChip(
                        label: Text(e.name),
                        selected: inc.contains(e.name),
                        onSelected: (bool v) {
                          setState(() {
                            if (v) {
                              inc.add(e.name);
                            } else {
                              inc.remove(e.name);
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
                hint: Text(tr('meal')),
                isExpanded: true,
                value: meal,
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
                    meal = v;
                  });
                },
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              Text(tr('max_calories')),
              TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: maxCal?.toString() ?? '',
                ),
                onChanged: (String v) {
                  setState(() {
                    maxCal = int.tryParse(v);
                  });
                },
                decoration: InputDecoration(hintText: tr('max_calories_hint')),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              Text(tr('min_fiber')),
              TextField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: minFiber?.toString() ?? '',
                ),
                onChanged: (String v) {
                  setState(() {
                    minFiber = int.tryParse(v);
                  });
                },
                decoration: InputDecoration(hintText: tr('min_fiber_hint')),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(tr('cancel')),
        ),
        if (currentFilters.isNotEmpty)
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              context.read<RecipesViewModel>().resetFilters();
            },
            child: Text(tr('filter_reset')),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            onApply(<String, dynamic>{
              'ingredients': inc.isEmpty ? null : inc.toList(),
              'meal': meal,
              'maxCalories': maxCal,
              'minFiber': minFiber,
            });
          },
          child: Text(tr('confirm')),
        ),
      ],
    );
  }
}

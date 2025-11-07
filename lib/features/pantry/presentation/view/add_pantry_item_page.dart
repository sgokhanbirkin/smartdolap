// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs, use_build_context_synchronously, always_put_control_body_on_new_line
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';

class AddPantryItemPage extends StatefulWidget {
  const AddPantryItemPage({required this.userId, super.key});

  final String userId;

  @override
  State<AddPantryItemPage> createState() => _AddPantryItemPageState();
}

class _AddPantryItemPageState extends State<AddPantryItemPage> {
  static const List<String> _unitOptions = <String>[
    'adet', 'kg', 'g', 'lt', 'ml', 'paket', 'kutu', 'demet', 'tane'
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _qty = TextEditingController(text: '1');
  final TextEditingController _unit = TextEditingController();
  DateTime? _expiry;
  String? _category;
  bool _categoryLocked = false;
  bool _isCategorizing = false;
  String? _suggestedCategory;
  Timer? _categoryDebounce;

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _category = category;
      _categoryLocked = category != null;
    });
  }

  Widget _categoryStatusChip(BuildContext context) {
    if (_isCategorizing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: AppSizes.spacingXS),
          Text(
            tr('pantry_category_detecting'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    if (_suggestedCategory != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.auto_awesome,
            size: AppSizes.iconS,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: AppSizes.spacingXS),
          Text(
            tr(
              'pantry_category_suggested',
              namedArgs: <String, String>{'category': _suggestedCategory!},
            ),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _categoryDebounce?.cancel();
    _name.dispose();
    _qty.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _onNameChanged() async {
    _categoryDebounce?.cancel();
    final String name = _name.text.trim();
    if (name.length < 2) {
      setState(() {
        _suggestedCategory = null;
        _category = null;
        _isCategorizing = false;
        _categoryLocked = false;
      });
      return;
    }

    final String quickGuess = PantryCategoryHelper.guess(name);
    setState(() {
      _suggestedCategory = quickGuess;
      if (!_categoryLocked) {
        _category = quickGuess;
      }
    });

    _categoryDebounce = Timer(const Duration(milliseconds: 600), () async {
      setState(() => _isCategorizing = true);
      try {
        final String cat = await sl<IOpenAIService>().categorizeItem(name);
        if (!mounted || _name.text.trim() != name) {
          return;
        }
        setState(() {
          _isCategorizing = false;
          _suggestedCategory = cat;
          if (!_categoryLocked) {
            _category = cat;
          }
        });
      } catch (_) {
        if (mounted) {
          setState(() => _isCategorizing = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(tr('add_item')),
      elevation: 0,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Name field with category indicator
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tr('name'),
                        style: TextStyle(
                          fontSize: AppSizes.textS,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingXS),
                      TextFormField(
                        controller: _name,
                        style: TextStyle(fontSize: AppSizes.text),
                        decoration: InputDecoration(
                          hintText: tr('name'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radius),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        validator: (String? v) =>
                            (v == null || v.trim().isEmpty) ? tr('invalid_name') : null,
                      ),
                      if (_category != null) ...[
                        SizedBox(height: AppSizes.verticalSpacingS),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.spacingM,
                            vertical: AppSizes.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(AppSizes.radius),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.category,
                                size: AppSizes.iconS,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                              SizedBox(width: AppSizes.spacingS),
                              Text(
                                _category!,
                                style: TextStyle(
                                  fontSize: AppSizes.textS,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tr('pantry_category_title'),
                        style: TextStyle(
                          fontSize: AppSizes.textS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSizes.spacingXS),
                      Text(
                        tr('pantry_category_hint'),
                        style: TextStyle(
                          fontSize: AppSizes.textXS,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_isCategorizing || _suggestedCategory != null)
                        Padding(
                          padding: EdgeInsets.only(top: AppSizes.spacingS),
                          child: _categoryStatusChip(context),
                        ),
                      if (_category != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _onCategorySelected(null),
                            icon: const Icon(Icons.close, size: 16),
                            label: Text(tr('pantry_category_clear')),
                          ),
                        ),
                      SizedBox(height: AppSizes.spacingM),
                      Wrap(
                        spacing: AppSizes.spacingS,
                        runSpacing: AppSizes.spacingS,
                        children: PantryCategoryHelper.categories.map(
                          (String cat) {
                            final bool selected = _category == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              avatar: Icon(
                                PantryCategoryHelper.iconFor(cat),
                                size: 16,
                                color: selected
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              selected: selected,
                              onSelected: (bool value) =>
                                  _onCategorySelected(value ? cat : null),
                              selectedColor: Theme.of(context).colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                fontSize: AppSizes.textXS,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                color: selected
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              // Quantity and Unit
              Row(
                children: <Widget>[
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              tr('quantity'),
                              style: TextStyle(
                                fontSize: AppSizes.textS,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: AppSizes.spacingXS),
                            TextFormField(
                              controller: _qty,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: AppSizes.text),
                              decoration: InputDecoration(
                                hintText: '1',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radius),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              tr('unit'),
                              style: TextStyle(
                                fontSize: AppSizes.textS,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: AppSizes.spacingXS),
                            Autocomplete<String>(
                              initialValue: TextEditingValue(text: _unit.text),
                              optionsBuilder: (TextEditingValue v) {
                                final String q = v.text.toLowerCase();
                                return _unitOptions.where((String o) => o.contains(q));
                              },
                              onSelected: (String v) => _unit.text = v,
                              fieldViewBuilder: (
                                BuildContext context,
                                TextEditingController controller,
                                FocusNode node,
                                VoidCallback onFieldSubmitted,
                              ) {
                                controller.text = _unit.text;
                                controller.selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.text.length),
                                );
                                controller.addListener(() => _unit.text = controller.text);
                                return TextFormField(
                                  controller: controller,
                                  focusNode: node,
                                  style: TextStyle(fontSize: AppSizes.text),
                                  decoration: InputDecoration(
                                    hintText: tr('unit'),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.radius),
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              // Expiry date
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) setState(() => _expiry = picked);
                  },
                  borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.padding),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: AppSizes.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                tr('expiry_date'),
                                style: TextStyle(
                                  fontSize: AppSizes.textS,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: AppSizes.spacingXS),
                              Text(
                                _expiry == null
                                    ? tr('expiry_date')
                                    : '${_expiry!.day}.${_expiry!.month}.${_expiry!.year}',
                                style: TextStyle(
                                  fontSize: AppSizes.text,
                                  color: _expiry == null
                                      ? Theme.of(context).colorScheme.onSurfaceVariant
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingXL),
              // Save button
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final double qty =
                      double.tryParse(_qty.text.replaceAll(',', '.')) ?? 1.0;
                  final String? normalizedCategory =
                      _category == null ? null : PantryCategoryHelper.normalize(_category);
                  final PantryItem item = PantryItem(
                    id: '',
                    name: _name.text.trim(),
                    quantity: qty,
                    unit: _unit.text.trim(),
                    expiryDate: _expiry,
                    category: normalizedCategory,
                  );
                  await context.read<PantryCubit>().add(widget.userId, item);
                  if (mounted) Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius * 1.5),
                  ),
                ),
                child: Text(
                  tr('save'),
                  style: TextStyle(
                    fontSize: AppSizes.textM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

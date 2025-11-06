// ignore_for_file: lines_longer_than_80_chars, public_member_api_docs, use_build_context_synchronously, always_put_control_body_on_new_line
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';

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

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('add_item'))),
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: tr('name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                  ),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? tr('invalid_name') : null,
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _qty,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: tr('quantity'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radius),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: Autocomplete<String>(
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
                            // keep in sync with backing controller
                            controller.text = _unit.text;
                            controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: controller.text.length),
                            );
                            controller.addListener(() => _unit.text = controller.text);
                            return TextFormField(
                              controller: controller,
                              focusNode: node,
                              decoration: InputDecoration(
                                labelText: tr('unit'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radius),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              SizedBox(height: AppSizes.verticalSpacingM),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final DateTime now = DateTime.now();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now.subtract(const Duration(days: 1)),
                          lastDate: now.add(const Duration(days: 365 * 3)),
                        );
                        if (picked != null) setState(() => _expiry = picked);
                      },
                      child: Text(
                        _expiry == null
                            ? tr('expiry_date')
                            : '${_expiry!.day}.${_expiry!.month}.${_expiry!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.verticalSpacingL),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final double qty =
                      double.tryParse(_qty.text.replaceAll(',', '.')) ?? 1.0;
                  final PantryItem item = PantryItem(
                    id: '',
                    name: _name.text.trim(),
                    quantity: qty,
                    unit: _unit.text.trim(),
                    expiryDate: _expiry,
                  );
                  await context.read<PantryCubit>().add(widget.userId, item);
                  if (mounted) Navigator.of(context).pop(true);
                },
                child: Text(tr('save')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

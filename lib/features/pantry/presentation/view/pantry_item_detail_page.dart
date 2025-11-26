// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/quantity_formatter.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_view_model.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/unit_dropdown_widget.dart';

/// Pantry item detail page - Edit quantity and delete item
class PantryItemDetailPage extends StatefulWidget {
  const PantryItemDetailPage({
    required this.item,
    required this.userId,
    super.key,
  });

  final PantryItem item;
  final String userId;

  @override
  State<PantryItemDetailPage> createState() => _PantryItemDetailPageState();
}

class _PantryItemDetailPageState extends State<PantryItemDetailPage> {
  static const List<String> _unitOptions = <String>[
    'adet',
    'kg',
    'g',
    'lt',
    'ml',
    'paket',
    'kutu',
    'demet',
    'tane',
  ];
  late final TextEditingController _qtyController;
  late final TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: QuantityFormatter.formatQuantity(
        widget.item.quantity,
        widget.item.unit,
      ),
    );
    _unitController = TextEditingController(text: widget.item.unit);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BackgroundWrapper(
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding * 0.75),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        widget.item.name,
                        style: TextStyle(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSizes.verticalSpacingM),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _qtyController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: AppSizes.textM),
                              decoration: InputDecoration(
                                labelText: tr('quantity'),
                                labelStyle: TextStyle(fontSize: AppSizes.textM),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radius,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(
                                  AppSizes.padding * 0.75,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingM),
                          Expanded(
                            child: UnitDropdownWidget(
                              unitController: _unitController,
                              unitOptions: _unitOptions,
                              wrapInCard: false,
                            ),
                          ),
                        ],
                      ),
                      if (widget.item.expiryDate != null) ...<Widget>[
                        SizedBox(height: AppSizes.verticalSpacingM),
                        Row(
                          children: <Widget>[
                            Icon(Icons.calendar_today, size: AppSizes.iconS),
                            SizedBox(width: AppSizes.spacingS),
                            Text(
                              '${tr('expiry_date')}: '
                              '${_formatDate(widget.item.expiryDate!)}',
                              style: TextStyle(fontSize: AppSizes.textS),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingL),
              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: Text(tr('save')),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, AppSizes.buttonHeight),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.buttonPaddingH,
                    vertical: AppSizes.buttonPaddingV,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _saveChanges() async {
    final double? qty = double.tryParse(
      _qtyController.text.replaceAll(',', '.'),
    );
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('invalid_quantity'))));
      return;
    }

    // Floating-point precision sorununu önlemek için yuvarlama
    final double roundedQty = QuantityFormatter.roundQuantity(
      qty,
      _unitController.text,
    );

    final PantryItem updated = widget.item.copyWith(
      quantity: roundedQty,
      unit: _unitController.text.trim(),
    );
    await context.read<PantryViewModel>().update(
      widget.userId,
      updated,
    ); // userId is householdId here
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    if (!mounted) {
      return;
    }
    final BuildContext dialogContext = context;
    final PantryViewModel viewModel = context.read<PantryViewModel>();
    final NavigatorState navigator = Navigator.of(context);
    final bool? confirm = await showDialog<bool>(
      context: dialogContext,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(tr('delete_item')),
        content: Text(tr('delete_item_confirm')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await viewModel.remove(
        widget.userId,
        widget.item.id,
      ); // userId is householdId here
      if (mounted) {
        navigator.pop(true);
      }
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}

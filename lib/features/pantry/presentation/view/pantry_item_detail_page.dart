// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';

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
  late final TextEditingController _qtyController;
  late final TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.item.quantity.toString());
    _unitController = TextEditingController(text: widget.item.unit);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.item.name),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
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
                    padding: EdgeInsets.all(AppSizes.padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.item.name,
                          style: TextStyle(
                            fontSize: AppSizes.textXL,
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
                                decoration: InputDecoration(
                                  labelText: tr('quantity'),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppSizes.radius),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSizes.spacingM),
                            Expanded(
                              child: TextFormField(
                                controller: _unitController,
                                decoration: InputDecoration(
                                  labelText: tr('unit'),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppSizes.radius),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.item.expiryDate != null) ...[
                          SizedBox(height: AppSizes.verticalSpacingM),
                          Row(
                            children: <Widget>[
                              Icon(Icons.calendar_today, size: AppSizes.icon),
                              SizedBox(width: AppSizes.spacingS),
                              Text(
                                '${tr('expiry_date')}: ${_formatDate(widget.item.expiryDate!)}',
                                style: TextStyle(fontSize: AppSizes.text),
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
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _saveChanges() async {
    final double? qty = double.tryParse(_qtyController.text.replaceAll(',', '.'));
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('invalid_quantity'))),
      );
      return;
    }
    final PantryItem updated = widget.item.copyWith(
      quantity: qty,
      unit: _unitController.text.trim(),
    );
    await context.read<PantryCubit>().update(widget.userId, updated);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<PantryCubit>().remove(widget.userId, widget.item.id);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}


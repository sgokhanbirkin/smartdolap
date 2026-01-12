// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';

/// Editable product data for review
class EditableProduct {
  String name;
  String? category;
  String? unit;
  double? amount;
  final ScannedProduct original;

  EditableProduct({
    required this.name,
    this.category,
    this.unit,
    this.amount,
    required this.original,
  });

  factory EditableProduct.from(ScannedProduct product) {
    return EditableProduct(
      name: product.name,
      category: product.category,
      unit: product.unit,
      amount: product.amount,
      original: product,
    );
  }
}

/// Card widget for reviewing a scanned item with editable name and category
class ScannedItemReviewCard extends StatefulWidget {
  final EditableProduct product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final ValueChanged<EditableProduct> onProductChanged;

  const ScannedItemReviewCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onProductChanged,
  });

  @override
  State<ScannedItemReviewCard> createState() => _ScannedItemReviewCardState();
}

class _ScannedItemReviewCardState extends State<ScannedItemReviewCard> {
  late TextEditingController _nameController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    widget.product.name = value;
    widget.onProductChanged(widget.product);
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      widget.product.category = category;
    });
    widget.onProductChanged(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final original = product.original;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          // Main row
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: original.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            original.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shopping_bag),
                          ),
                        )
                      : const Icon(Icons.shopping_bag),
                ),
                SizedBox(width: 12.w),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Editable name
                      TextField(
                        controller: _nameController,
                        onChanged: _onNameChanged,
                        style: Theme.of(context).textTheme.titleMedium,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          suffixIcon: Icon(Icons.edit, size: 16.sp),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Barcode and quantity info
                      Row(
                        children: [
                          Text(
                            original.barcode,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          if (product.amount != null &&
                              product.unit != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '${product.amount}${product.unit}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Count controls
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: widget.quantity > 1
                              ? () => widget.onQuantityChanged(-1)
                              : null,
                          iconSize: 24.sp,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 32.w,
                            minHeight: 32.h,
                          ),
                        ),
                        SizedBox(
                          width: 40.w,
                          child: Text(
                            widget.quantity.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: widget.quantity < 999
                              ? () => widget.onQuantityChanged(1)
                              : null,
                          iconSize: 24.sp,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 32.w,
                            minHeight: 32.h,
                          ),
                        ),
                      ],
                    ),
                    // Expand/collapse button
                    TextButton(
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('details'.tr()),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded section with category and delete
          if (_isExpanded)
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
                  Text(
                    'category'.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 4.h),
                  DropdownButtonFormField<String>(
                    initialValue: PantryCategoryHelper.normalize(product.category),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    items: PantryCategoryHelper.categories.map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(
                          PantryCategoryHelper.getLocalizedCategoryName(cat),
                        ),
                      );
                    }).toList(),
                    onChanged: _onCategoryChanged,
                  ),
                  SizedBox(height: 12.h),

                  // Original name info
                  if (original.name != product.name)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        '${'original_name'.tr()}: ${original.name}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ),

                  // Delete button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: Text('remove_item'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

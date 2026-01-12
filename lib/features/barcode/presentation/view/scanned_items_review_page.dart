// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/services/feedback/feedback_service.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/core/utils/haptics.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/bulk_add_pantry_items.dart';
import 'package:smartdolap/features/barcode/domain/entities/scanned_product.dart';
import 'package:smartdolap/features/barcode/presentation/widgets/scanned_item_review_card.dart';

/// Review page for scanned items before bulk adding to pantry
class ScannedItemsReviewPage extends StatefulWidget {
  const ScannedItemsReviewPage({super.key, required this.scannedItems});
  final List<ScannedProduct> scannedItems;

  @override
  State<ScannedItemsReviewPage> createState() => _ScannedItemsReviewPageState();
}

class _ScannedItemsReviewPageState extends State<ScannedItemsReviewPage> {
  late List<EditableProduct> _items;
  late Map<String, int> _quantities; // barcode -> quantity

  @override
  void initState() {
    super.initState();
    _items = widget.scannedItems
        .map((ScannedProduct p) => EditableProduct.from(p))
        .toList();
    _quantities = <String, int>{
      for (final EditableProduct item in _items) item.original.barcode: 1,
    };
  }

  void _removeItem(int index) {
    setState(() {
      final EditableProduct item = _items[index];
      _quantities.remove(item.original.barcode);
      _items.removeAt(index);
    });
    Haptics.light();
  }

  void _updateQuantity(String barcode, int delta) {
    setState(() {
      final int current = _quantities[barcode] ?? 1;
      final int newQuantity = (current + delta).clamp(1, 999);
      _quantities[barcode] = newQuantity;
    });
    Haptics.light();
  }

  void _updateProduct(int index, EditableProduct updated) {
    setState(() {
      _items[index] = updated;
    });
  }

  /// Convert EditableProducts back to ScannedProducts for saving
  List<ScannedProduct> _getProductsForSave() =>
      _items.map((EditableProduct editable) {
      return editable.original.copyWith(
        name: editable.name,
        category: editable.category,
        amount: editable.amount,
        unit: editable.unit,
      );
    }).toList();

  void _onSubmit() async {
    if (_items.isEmpty) return;

    Haptics.medium();

    // Show loading
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get current user and household
      final AuthCubit authCubit = context.read<AuthCubit>();
      final String userId = authCubit.state.maybeMap(
        authenticated: (state) => state.user.id,
        orElse: () => '',
      );

      final String? householdId = authCubit.state.maybeMap(
        authenticated: (state) => state.user.householdId,
        orElse: () => null,
      );

      if (userId.isEmpty || householdId == null) {
        throw Exception('User not authenticated or no household');
      }

      // Convert to ScannedProducts with user edits
      final List<ScannedProduct> products = _getProductsForSave();

      // Call bulk add use case
      final BulkAddPantryItems bulkAddUseCase = sl<BulkAddPantryItems>();
      final int addedCount = await bulkAddUseCase(
        products: products,
        quantities: _quantities,
        userId: userId,
        householdId: householdId,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        sl<IFeedbackService>().showSuccess(
          context,
          'bulk_add_success',
          args: <String>[addedCount.toString()],
        );
      }

      // Return success to caller
      if (mounted) {
        Navigator.pop(context, <String, Object>{
          'success': true,
          'count': addedCount,
        });
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        sl<IFeedbackService>().showError(context, 'bulk_add_error');
      }

      Logger.error(
        '[ScannedItemsReviewPage] Failed to add items',
        e,
        StackTrace.current,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('review_scanned_items'.tr()),
      actions: <Widget>[
          if (_items.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Text(
                  'items_to_add'.tr(
                  namedArgs: <String, String>{
                    'count': _items.length.toString(),
                  },
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'no_items_to_review'.tr(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: _items.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (BuildContext context, int index) {
              final EditableProduct item = _items[index];
              final int quantity = _quantities[item.original.barcode] ?? 1;

                return ScannedItemReviewCard(
                  product: item,
                  quantity: quantity,
                onQuantityChanged: (int delta) =>
                      _updateQuantity(item.original.barcode, delta),
                  onRemove: () => _removeItem(index),
                onProductChanged: (EditableProduct updated) =>
                    _updateProduct(index, updated),
                );
              },
            ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  16.w,
                  16.w,
                  32.h,
                ), // Extra bottom padding
                child: Row(
                children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Haptics.light();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text('cancel'.tr()),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _onSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text('add_all_to_pantry'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
}

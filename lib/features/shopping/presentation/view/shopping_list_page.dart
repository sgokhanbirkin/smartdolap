// ignore_for_file: directives_ordering, prefer_const_constructors, lines_longer_than_80_chars

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/services/i_shopping_list_service.dart';
import 'package:smartdolap/features/shopping/presentation/viewmodel/shopping_list_cubit.dart';
import 'package:smartdolap/features/shopping/presentation/viewmodel/shopping_list_state.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/error_state.dart';

/// Shopping list page - Shows household shopping list items
/// Responsive: Adapts layout for tablet/desktop screens
class ShoppingListPage extends StatefulWidget {
  /// Shopping list page constructor
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('shopping_list.title')), elevation: 0),
    body: SafeArea(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState state) => state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => Center(
            child: CustomLoadingIndicator(type: LoadingType.wave, size: 50),
          ),
          error: (_) => EmptyState(messageKey: 'auth_error'),
          unauthenticated: () => EmptyState(messageKey: 'auth_error'),
          authenticated: (domain.User user) {
            if (user.householdId == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64.w,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        tr('join_household'),
                        style: TextStyle(
                          fontSize: AppSizes.textL,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return BlocProvider<ShoppingListCubit>(
              create: (BuildContext _) =>
                  sl<ShoppingListCubit>()..watch(user.householdId!),
              child: BlocBuilder<ShoppingListCubit, ShoppingListState>(
                builder: (BuildContext context, ShoppingListState s) {
                  if (s is ShoppingListLoading || s is ShoppingListInitial) {
                    return Center(
                      child: CustomLoadingIndicator(
                        type: LoadingType.wave,
                        size: 50,
                      ),
                    );
                  }
                  if (s is ShoppingListFailure) {
                    return ErrorState(
                      messageKey: 'shopping_list.empty_message',
                      onRetry: () => context.read<ShoppingListCubit>().watch(
                        user.householdId!,
                      ),
                    );
                  }
                  final ShoppingListLoaded loaded = s as ShoppingListLoaded;
                  if (loaded.items.isEmpty) {
                    return EmptyState(
                      messageKey: 'shopping_list.empty_message',
                      actionLabelKey: 'shopping_list.add_item',
                      onAction: () => _showAddItemDialog(
                        context,
                        user.householdId!,
                        user.id,
                        user.avatarId,
                      ),
                      lottieAsset: 'assets/animations/Food_Carousel.json',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<ShoppingListCubit>().refresh(
                        user.householdId!,
                      );
                    },
                    child: context.isTablet
                        ? _buildTabletLayout(
                            context,
                            loaded.items,
                            user.householdId!,
                            user.id,
                            user.avatarId,
                          )
                        : _buildPhoneLayout(
                            context,
                            loaded.items,
                            user.householdId!,
                            user.id,
                            user.avatarId,
                          ),
                  );
                },
              ),
            );
          },
        ),
      ),
    ),
    floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState state) => state.maybeWhen(
        authenticated: (domain.User user) {
          if (user.householdId == null) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () => _showAddItemDialog(
              context,
              user.householdId!,
              user.id,
              user.avatarId,
            ),
            child: const Icon(Icons.add),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    ),
  );

  Widget _buildShoppingListItem(
    BuildContext context,
    ShoppingListItem item,
    String householdId,
    String userId,
    String? avatarId,
  ) {
    final bool isTablet = context.isTablet;
    final IShoppingListService shoppingListService = sl<IShoppingListService>();

    return Card(
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (bool? value) async {
            if (value == true) {
              await context.read<ShoppingListCubit>().complete(
                householdId,
                item.id,
                userId,
              );
            } else {
              await context.read<ShoppingListCubit>().update(
                householdId,
                item.copyWith(
                  isCompleted: false,
                  completedAt: null,
                  completedByUserId: null,
                ),
              );
            }
          },
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            fontSize: isTablet ? AppSizes.textL : AppSizes.textM,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (item.quantity != null && item.unit != null)
              Text(
                '${item.quantity} ${item.unit}',
                style: TextStyle(
                  fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                ),
              ),
            if (item.addedByAvatarId != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  children: <Widget>[
                    AvatarWidget(avatarId: item.addedByAvatarId, size: 16.w),
                    SizedBox(width: 4.w),
                    Text(
                      tr('added_by'),
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) async {
            if (value == 'complete_and_add') {
              await shoppingListService.completeAndAddToPantry(
                householdId: householdId,
                itemId: item.id,
                userId: userId,
                avatarId: avatarId,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('shopping_list.item_added_to_pantry')),
                  ),
                );
              }
            } else if (value == 'delete') {
              await context.read<ShoppingListCubit>().delete(
                householdId,
                item.id,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tr('shopping_list.item_deleted'))),
                );
              }
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'complete_and_add',
              child: Text(tr('shopping_list.complete_and_add')),
            ),
            PopupMenuItem<String>(value: 'delete', child: Text(tr('delete'))),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    String householdId,
    String userId,
    String? avatarId,
  ) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    String? category;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('shopping_list.add_item')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: tr('shopping_list.item_name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radius),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: tr('shopping_list.quantity'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      decoration: InputDecoration(
                        labelText: tr('shopping_list.unit'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: Text(tr('save')),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final ShoppingListItem newItem = ShoppingListItem(
        id: '',
        householdId: householdId,
        name: nameController.text.trim(),
        quantity: quantityController.text.isNotEmpty
            ? double.tryParse(quantityController.text.replaceAll(',', '.'))
            : null,
        unit: unitController.text.trim().isNotEmpty
            ? unitController.text.trim()
            : null,
        category: category,
        addedByUserId: userId,
        addedByAvatarId: avatarId,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await context.read<ShoppingListCubit>().add(householdId, newItem);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr('shopping_list.item_added'))));
      }
    }

    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }

  Widget _buildPhoneLayout(
    BuildContext context,
    List<ShoppingListItem> items,
    String householdId,
    String userId,
    String? avatarId,
  ) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.padding),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.verticalSpacingS),
      itemBuilder: (BuildContext _, int index) {
        return _buildShoppingListItem(
          context,
          items[index],
          householdId,
          userId,
          avatarId,
        );
      },
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    List<ShoppingListItem> items,
    String householdId,
    String userId,
    String? avatarId,
  ) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSizes.padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isMediumScreen ? 2 : 3,
        crossAxisSpacing: AppSizes.spacingM,
        mainAxisSpacing: AppSizes.spacingM,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildShoppingListItem(
          context,
          items[index],
          householdId,
          userId,
          avatarId,
        );
      },
    );
  }
}

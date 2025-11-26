// ignore_for_file: directives_ordering, prefer_const_constructors, lines_longer_than_80_chars, use_build_context_synchronously

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/pantry_categories.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/presentation/widgets/unit_dropdown_widget.dart';
import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/services/i_shopping_list_service.dart';
import 'package:smartdolap/features/shopping/presentation/viewmodel/shopping_list_cubit.dart';
import 'package:smartdolap/features/shopping/presentation/viewmodel/shopping_list_state.dart';
import 'package:smartdolap/product/services/openai/i_openai_service.dart';
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
  Widget build(BuildContext context) => BackgroundWrapper(
    child: BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState state) => state.when(
        initial: () => Scaffold(
          appBar: AppBar(title: Text(tr('shopping_list.title')), elevation: 0),
          body: const SizedBox.shrink(),
        ),
        loading: () => Scaffold(
          appBar: AppBar(title: Text(tr('shopping_list.title')), elevation: 0),
          body: Center(
            child: CustomLoadingIndicator(type: LoadingType.wave, size: 50),
          ),
        ),
        error: (_) => Scaffold(
          appBar: AppBar(title: Text(tr('shopping_list.title')), elevation: 0),
          body: SafeArea(child: EmptyState(messageKey: 'auth_error')),
        ),
        unauthenticated: () => Scaffold(
          appBar: AppBar(title: Text(tr('shopping_list.title')), elevation: 0),
          body: SafeArea(child: EmptyState(messageKey: 'auth_error')),
        ),
        authenticated: (domain.User user) {
          if (user.householdId == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text(tr('shopping_list.title')),
                elevation: 0,
              ),
              body: SafeArea(
                child: Center(
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
                ),
              ),
            );
          }
          return BlocProvider<ShoppingListCubit>(
            create: (BuildContext _) =>
                sl<ShoppingListCubit>()..watch(user.householdId!),
            child: Scaffold(
              appBar: AppBar(
                title: Text(tr('shopping_list.title')),
                elevation: 0,
                actions: <Widget>[
                  BlocBuilder<ShoppingListCubit, ShoppingListState>(
                    builder: (BuildContext context, ShoppingListState s) {
                      if (s is! ShoppingListLoaded) {
                        return const SizedBox.shrink();
                      }
                      final ShoppingListLoaded loaded = s;
                      final int completedCount = loaded.items
                          .where((ShoppingListItem item) => item.isCompleted)
                          .length;
                      if (completedCount == 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(right: AppSizes.padding),
                        child: TextButton.icon(
                          onPressed: () => _handleShoppingDone(
                            context,
                            user.householdId!,
                            user.id,
                            user.avatarId,
                          ),
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: Text(tr('shopping_list.shopping_done')),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: SafeArea(
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
                          context.read<ShoppingListCubit>(),
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
              ),
              floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
                builder: (BuildContext authContext, AuthState authState) =>
                    authState.maybeWhen(
                      authenticated: (domain.User authUser) {
                        if (authUser.householdId == null) {
                          return const SizedBox.shrink();
                        }
                        return BlocBuilder<
                          ShoppingListCubit,
                          ShoppingListState
                        >(
                          builder:
                              (
                                BuildContext shoppingContext,
                                ShoppingListState s,
                              ) => FloatingActionButton(
                                onPressed: () => _showAddItemDialog(
                                  shoppingContext,
                                  authUser.householdId!,
                                  authUser.id,
                                  authUser.avatarId,
                                  shoppingContext.read<ShoppingListCubit>(),
                                ),
                                child: const Icon(Icons.add),
                              ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
              ),
            ),
          );
        },
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
                item.copyWith(isCompleted: false),
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

  Future<void> _handleShoppingDone(
    BuildContext context,
    String householdId,
    String userId,
    String? avatarId,
  ) async {
    final IShoppingListService shoppingListService = sl<IShoppingListService>();

    try {
      // Show loading indicator
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppSizes.spacingM),
              Text(tr('shopping_list.shopping_done')),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Complete all completed items and add to pantry
      final int addedCount = await shoppingListService
          .completeAllCompletedAndAddToPantry(
            householdId: householdId,
            userId: userId,
            avatarId: avatarId,
          );

      // Refresh the shopping list
      if (!mounted) {
        return;
      }
      await context.read<ShoppingListCubit>().refresh(householdId);

      // Show success message
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addedCount > 0
                ? tr(
                    'shopping_list.shopping_done_message',
                    args: <String>[addedCount.toString()],
                  )
                : tr('shopping_list.shopping_done_no_items'),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    String householdId,
    String userId,
    String? avatarId,
    ShoppingListCubit shoppingListCubit,
  ) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    String? category;
    Timer? categoryDebounce;

    const List<String> unitOptions = <String>[
      'adet',
      'kg',
      'g',
      'lt',
      'ml',
      'paket',
      'kutu',
      'şişe',
      'demet',
      'bağ',
      'tane',
    ];

    void onNameChanged(String value) {
      categoryDebounce?.cancel();
      final String name = value.trim();
      if (name.length < 2) {
        category = null;
        return;
      }

      // Quick guess
      final String quickGuess = PantryCategoryHelper.guess(name);
      category = PantryCategoryHelper.normalize(quickGuess);

      // AI category suggestion
      categoryDebounce = Timer(const Duration(milliseconds: 600), () async {
        try {
          final String cat = await sl<IOpenAIService>().categorizeItem(name);
          if (nameController.text.trim() != name) {
            return;
          }
          category = PantryCategoryHelper.normalize(cat);
        } on Exception catch (_) {
          // Ignore errors, keep quick guess
        }
      });
    }

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
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
                onChanged: onNameChanged,
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
                    child: UnitDropdownWidget(
                      unitController: unitController,
                      unitOptions: unitOptions,
                      wrapInCard: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              categoryDebounce?.cancel();
              Navigator.of(context).pop(false);
            },
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                return;
              }
              categoryDebounce?.cancel();
              Navigator.of(context).pop(true);
            },
            child: Text(tr('save')),
          ),
        ],
      ),
    );

    categoryDebounce?.cancel();

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

      await shoppingListCubit.add(householdId, newItem);
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
  ) => ListView.builder(
    padding: EdgeInsets.all(AppSizes.padding),
    itemCount: items.length * 2 - 1, // Items + separators
    // Optimize: Add itemExtent for fixed-height items (approximately 80px ListTile + 8px separator)
    itemExtent: 88,
    itemBuilder: (BuildContext _, int i) {
      // Even indices are items, odd indices are separators
      if (i.isOdd) {
        return SizedBox(height: AppSizes.verticalSpacingS);
      }
      final int index = i ~/ 2;
      return RepaintBoundary(
        child: _buildShoppingListItem(
          context,
          items[index],
          householdId,
          userId,
          avatarId,
        ),
      );
    },
  );

  Widget _buildTabletLayout(
    BuildContext context,
    List<ShoppingListItem> items,
    String householdId,
    String userId,
    String? avatarId,
  ) {
    // Use responsive grid helper for consistent column count
    final int crossAxisCount = context.responsiveInt(
      phone: 2, // Should not be used in tablet layout, but fallback
      tablet: 2, // Tablet: 2 columns
      desktop: 3, // Desktop: 3 columns
      largeDesktop: 4, // Large desktop: 4 columns
    );

    return GridView.builder(
      padding: EdgeInsets.all(AppSizes.padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSizes.spacingM,
        mainAxisSpacing: AppSizes.spacingM,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) => RepaintBoundary(
        child: _buildShoppingListItem(
          context,
          items[index],
          householdId,
          userId,
          avatarId,
        ),
      ),
    );
  }
}

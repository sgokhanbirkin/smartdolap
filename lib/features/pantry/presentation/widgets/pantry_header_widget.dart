import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Widget for pantry page header with title, subtitle, and search bar
class PantryHeaderWidget extends StatelessWidget {
  /// Creates a pantry header widget
  const PantryHeaderWidget({
    required this.searchController,
    required this.searchQuery,
    super.key,
  });

  /// Controller for search text field
  final TextEditingController searchController;

  /// ValueNotifier for search query (debounced)
  final ValueNotifier<String> searchQuery;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Text(
              tr('pantry_title'),
              style: TextStyle(
                fontSize: AppSizes.textHeading,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (BuildContext context, AuthState authState) {
              return authState.whenOrNull(
                authenticated: (domain.User user) {
                  if (user.householdId == null) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        tooltip: tr('shopping_list.title'),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.shoppingList,
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.pantryAdd,
                            arguments: <String, dynamic>{
                              'householdId': user.householdId!,
                              'userId': user.id,
                              'avatarId': user.avatarId,
                            },
                          );
                        },
                        icon: Icon(Icons.add, size: AppSizes.iconS),
                        label: Text(tr('add_item')),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizes.spacingS,
                            vertical: AppSizes.spacingXS,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ) ?? const SizedBox.shrink();
            },
          ),
        ],
      ),
      SizedBox(height: AppSizes.spacingXS),
      Text(
        tr('pantry_subtitle'),
        style: TextStyle(
          fontSize: AppSizes.textS,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingM),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizes.radius * 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: AppSizes.spacingS,
              offset: Offset(0, AppSizes.spacingS),
            ),
          ],
        ),
        child: ValueListenableBuilder<String>(
          valueListenable: searchQuery,
          builder: (BuildContext context, String query, Widget? child) =>
              TextField(
                controller: searchController,
                style: TextStyle(
                  fontSize: AppSizes.text,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: tr('search'),
                  hintStyle: TextStyle(
                    fontSize: AppSizes.text,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingM,
                    vertical: AppSizes.spacingM + 2,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
        ),
      ),
    ],
  );
}

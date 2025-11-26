import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Household management widget
/// Displays household setup or management options
/// Follows Single Responsibility Principle - only handles household UI
class HouseholdManagementWidget extends StatelessWidget {
  /// Household management widget constructor
  const HouseholdManagementWidget({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
      builder: (BuildContext context, AuthState authState) => authState.maybeWhen(
          authenticated: (domain.User user) => Container(
              padding: EdgeInsets.all(AppSizes.padding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.home_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          user.householdId == null
                              ? tr('household_setup_title')
                              : tr('household_management'),
                          style: TextStyle(
                            fontSize: AppSizes.textL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    user.householdId == null
                        ? tr('household_setup_description')
                        : tr('household_management_description'),
                    style: TextStyle(
                      fontSize: AppSizes.textM,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (user.householdId == null)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRouter.householdSetup,
                              );
                            },
                            icon: const Icon(Icons.add_home),
                            label: Text(tr('create_household')),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRouter.householdSetup,
                              );
                            },
                            icon: const Icon(Icons.group_add),
                            label: Text(tr('join_household')),
                          ),
                        ),
                      ],
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRouter.share);
                      },
                      icon: const Icon(Icons.home),
                      label: Text(tr('go_to_household')),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                ],
              ),
            ),
          orElse: () => const SizedBox.shrink(),
        ),
    );
}


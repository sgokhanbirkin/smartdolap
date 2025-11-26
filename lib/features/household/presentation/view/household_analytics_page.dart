import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/analytics/domain/entities/meal_consumption.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/household/domain/entities/household.dart';
import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';

/// Household analytics page - Shows statistics for all household members
class HouseholdAnalyticsPage extends StatelessWidget {
  /// Household analytics page constructor
  const HouseholdAnalyticsPage({
    required this.householdId,
    super.key,
  });

  final String householdId;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
        builder: (BuildContext context, AuthState authState) => authState.maybeWhen(
            authenticated: (domain.User user) => StreamBuilder<List<MealConsumption>>(
              stream: sl<IMealConsumptionRepository>().watchConsumptions(
                householdId: householdId,
                startDate: DateTime.now().subtract(const Duration(days: 30)),
              ),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<MealConsumption>> snapshot,
              ) => StreamBuilder<Household?>(
                  stream: sl<IHouseholdRepository>().watchHousehold(householdId),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<Household?> householdSnapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        householdSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(
                        child: CustomLoadingIndicator(
                          type: LoadingType.wave,
                          size: 50,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(tr('error_loading_statistics')),
                      );
                    }

                    final List<MealConsumption> consumptions =
                        snapshot.data ?? <MealConsumption>[];
                    final Household? household = householdSnapshot.data;
                    final Map<String, HouseholdMember> membersMap =
                        <String, HouseholdMember>{};
                    if (household != null) {
                      for (final HouseholdMember member in household.members) {
                        membersMap[member.userId] = member;
                      }
                    }

                    if (consumptions.isEmpty) {
                      return const EmptyState(
                        messageKey: 'household_analytics_no_data',
                        icon: Icons.analytics_outlined,
                      );
                    }

                    // Group by user
                    final Map<String, List<MealConsumption>> byUser =
                        <String, List<MealConsumption>>{};
                    for (final MealConsumption consumption in consumptions) {
                      byUser.putIfAbsent(
                        consumption.userId,
                        () => <MealConsumption>[],
                      );
                      byUser[consumption.userId]!.add(consumption);
                    }

                    // Calculate statistics
                    final Map<String, Map<String, int>> userMealStats =
                        <String, Map<String, int>>{};
                    final Map<String, int> userRecipeCount = <String, int>{};

                    for (final MapEntry<String, List<MealConsumption>> entry
                        in byUser.entries) {
                      final Map<String, int> mealStats = <String, int>{};
                      final Set<String> uniqueRecipes = <String>{};

                      for (final MealConsumption consumption in entry.value) {
                        mealStats[consumption.meal] =
                            (mealStats[consumption.meal] ?? 0) + 1;
                        uniqueRecipes.add(consumption.recipeId);
                      }

                      userMealStats[entry.key] = mealStats;
                      userRecipeCount[entry.key] = uniqueRecipes.length;
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.all(AppSizes.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            tr('household_statistics'),
                            style: TextStyle(
                              fontSize: AppSizes.textHeading,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            tr('household_statistics_description'),
                            style: TextStyle(
                              fontSize: AppSizes.textM,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Statistics cards for each user
                          ...byUser.entries.map((
                            MapEntry<String, List<MealConsumption>> entry,
                          ) {
                            final List<MealConsumption> userConsumptions =
                                entry.value;
                            final String userId = entry.key;
                            final HouseholdMember? member = membersMap[userId];
                            final String userName = member?.userName ??
                                (userConsumptions.isNotEmpty
                                    ? userConsumptions.first.recipeTitle
                                    : null) ??
                                userId;
                            final Map<String, int> mealStats =
                                userMealStats[userId] ?? <String, int>{};
                            final int recipeCount =
                                userRecipeCount[userId] ?? 0;
                            final int totalMeals = userConsumptions.length;

                            return Card(
                              margin: EdgeInsets.only(bottom: 16.h),
                              child: Padding(
                                padding: EdgeInsets.all(AppSizes.padding),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        AvatarWidget(
                                          avatarId: member?.avatarId,
                                          size: 40.w,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                userName,
                                                style: TextStyle(
                                                  fontSize: AppSizes.textL,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                tr(
                                                  'household_member_stats',
                                                  args: <String>[
                                                    totalMeals.toString(),
                                                    recipeCount.toString(),
                                                  ],
                                                ),
                                                style: TextStyle(
                                                  fontSize: AppSizes.textS,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    // Meal type breakdown
                                    if (mealStats.isNotEmpty) ...<Widget>[
                                      Text(
                                        tr('meal_distribution'),
                                        style: TextStyle(
                                          fontSize: AppSizes.textM,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Wrap(
                                        spacing: 8.w,
                                        runSpacing: 8.h,
                                        children: mealStats.entries.map((
                                          MapEntry<String, int> mealEntry,
                                        ) => Chip(
                                            label: Text(
                                              '${tr(mealEntry.key)}: ${mealEntry.value}',
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                          )).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
            ),
          orElse: () => const SizedBox.shrink(),
        ),
      );
}


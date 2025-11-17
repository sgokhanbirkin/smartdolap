// ignore_for_file: directives_ordering, prefer_const_constructors, lines_longer_than_80_chars

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/analytics/domain/entities/ingredient_usage.dart';
import 'package:smartdolap/features/analytics/domain/entities/user_analytics.dart';
import 'package:smartdolap/features/analytics/presentation/viewmodel/analytics_cubit.dart';
import 'package:smartdolap/features/analytics/presentation/viewmodel/analytics_state.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/error_state.dart';

/// Analytics page - Shows user analytics with charts
/// Responsive: Adapts layout for tablet/desktop screens
class AnalyticsPage extends StatelessWidget {
  /// Analytics page constructor
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr('analytics.title')), elevation: 0),
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
                        Icons.analytics_outlined,
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
            return BlocProvider<AnalyticsCubit>(
              create: (BuildContext _) => sl<AnalyticsCubit>()
                ..loadAnalytics(
                  userId: user.id,
                  householdId: user.householdId!,
                ),
              child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
                builder: (BuildContext context, AnalyticsState s) {
                  if (s is AnalyticsLoading || s is AnalyticsInitial) {
                    return Center(
                      child: CustomLoadingIndicator(
                        type: LoadingType.wave,
                        size: 50,
                      ),
                    );
                  }
                  if (s is AnalyticsFailure) {
                    return ErrorState(
                      messageKey: 'analytics.no_data',
                      onRetry: () => context.read<AnalyticsCubit>().refresh(
                        userId: user.id,
                        householdId: user.householdId!,
                      ),
                    );
                  }
                  final AnalyticsLoaded loaded = s as AnalyticsLoaded;
                  final UserAnalytics analytics = loaded.analytics;

                  // Check if there's any data
                  final bool hasData =
                      analytics.mealTypeDistribution.isNotEmpty ||
                      analytics.ingredientUsage.isNotEmpty ||
                      analytics.categoryUsage.isNotEmpty;

                  if (!hasData) {
                    return EmptyState(
                      messageKey: 'analytics.no_consumptions',
                      lottieAsset: 'assets/animations/Recipe_Book.json',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<AnalyticsCubit>().refresh(
                        userId: user.id,
                        householdId: user.householdId!,
                      );
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSizes.padding),
                      child: context.isTablet
                          ? _buildTabletLayout(context, analytics)
                          : _buildPhoneLayout(context, analytics),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _buildMealTypeChart(BuildContext context, UserAnalytics analytics) {
    final bool isTablet = context.isTablet;
    final List<PieChartSectionData> sections = analytics
        .mealTypeDistribution
        .entries
        .map((MapEntry<String, int> entry) {
          final double percentage =
              entry.value /
              analytics.mealTypeDistribution.values.reduce((a, b) => a + b) *
              100;
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${percentage.toStringAsFixed(0)}%',
            color: _getMealColor(entry.key),
            radius: isTablet ? 60 : 50,
            titleStyle: TextStyle(
              fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        })
        .toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('analytics.meal_type_distribution'),
              style: TextStyle(
                fontSize: isTablet ? AppSizes.textXL : AppSizes.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            SizedBox(
              height: isTablet ? 300.h : 250.h,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: isTablet ? 60 : 50,
                ),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            ...analytics.mealTypeDistribution.entries.map(
              (MapEntry<String, int> entry) => Padding(
                padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingS),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: _getMealColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSizes.spacingS),
                    Expanded(
                      child: Text(
                        _getMealLabel(entry.key),
                        style: TextStyle(
                          fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIngredientsChart(
    BuildContext context,
    UserAnalytics analytics,
  ) {
    final bool isTablet = context.isTablet;
    final List<MapEntry<String, IngredientUsage>> topIngredients =
        analytics.ingredientUsage.entries.toList()
          ..sort((a, b) => b.value.totalUsed.compareTo(a.value.totalUsed));
    final List<MapEntry<String, IngredientUsage>> top5 = topIngredients
        .take(5)
        .toList();

    if (top5.isEmpty) {
      return const SizedBox.shrink();
    }

    final double maxValue = top5.first.value.totalUsed.toDouble();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('analytics.top_ingredients'),
              style: TextStyle(
                fontSize: isTablet ? AppSizes.textXL : AppSizes.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            SizedBox(
              height: isTablet ? 300.h : 250.h,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= top5.length) {
                            return const Text('');
                          }
                          final String ingredient = top5[value.toInt()].key;
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              ingredient.length > 10
                                  ? '${ingredient.substring(0, 10)}...'
                                  : ingredient,
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppSizes.textS
                                    : AppSizes.textXS,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: isTablet
                                ? AppSizes.textS
                                : AppSizes.textXS,
                          ),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: top5.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final IngredientUsage usage = entry.value.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: usage.totalUsed.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: isTablet ? 40.w : 30.w,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryUsageChart(
    BuildContext context,
    UserAnalytics analytics,
  ) {
    final bool isTablet = context.isTablet;
    final List<MapEntry<String, int>> sortedCategories =
        analytics.categoryUsage.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    final double maxValue = sortedCategories.first.value.toDouble();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('analytics.category_usage'),
              style: TextStyle(
                fontSize: isTablet ? AppSizes.textXL : AppSizes.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            SizedBox(
              height: sortedCategories.length * (isTablet ? 60.h : 50.h),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: isTablet
                                ? AppSizes.textS
                                : AppSizes.textXS,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= sortedCategories.length) {
                            return const Text('');
                          }
                          final String category =
                              sortedCategories[value.toInt()].key;
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              category.length > 8
                                  ? '${category.substring(0, 8)}...'
                                  : category,
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppSizes.textS
                                    : AppSizes.textXS,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: sortedCategories.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final int usage = entry.value.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: usage.toDouble(),
                          color: Theme.of(context).colorScheme.secondary,
                          width: isTablet ? 40.w : 30.w,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryPattern(BuildContext context, UserAnalytics analytics) {
    final bool isTablet = context.isTablet;
    final Map<String, double> pattern = analytics.dietaryPattern;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr('analytics.dietary_pattern'),
              style: TextStyle(
                fontSize: isTablet ? AppSizes.textXL : AppSizes.textL,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            if (pattern.containsKey('vegetable_heavy'))
              _buildPatternIndicator(
                context,
                tr('analytics.vegetable_heavy'),
                pattern['vegetable_heavy']!,
                Colors.green,
                isTablet,
              ),
            if (pattern.containsKey('protein_heavy'))
              _buildPatternIndicator(
                context,
                tr('analytics.protein_heavy'),
                pattern['protein_heavy']!,
                Colors.orange,
                isTablet,
              ),
            if (pattern.containsKey('balanced'))
              _buildPatternIndicator(
                context,
                tr('analytics.balanced'),
                pattern['balanced']!,
                Colors.blue,
                isTablet,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternIndicator(
    BuildContext context,
    String label,
    double value,
    Color color,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.verticalSpacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.verticalSpacingS),
          LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: isTablet ? 12.h : 8.h,
          ),
        ],
      ),
    );
  }

  Color _getMealColor(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.blue;
      case 'dinner':
        return Colors.purple;
      case 'snack':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getMealLabel(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return tr('breakfast');
      case 'lunch':
        return tr('lunch');
      case 'dinner':
        return tr('dinner');
      case 'snack':
        return tr('snack');
      default:
        return meal;
    }
  }

  Widget _buildPhoneLayout(BuildContext context, UserAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (analytics.mealTypeDistribution.isNotEmpty)
          _buildMealTypeChart(context, analytics),
        SizedBox(height: AppSizes.verticalSpacingL),
        if (analytics.ingredientUsage.isNotEmpty)
          _buildTopIngredientsChart(context, analytics),
        SizedBox(height: AppSizes.verticalSpacingL),
        if (analytics.categoryUsage.isNotEmpty)
          _buildCategoryUsageChart(context, analytics),
        SizedBox(height: AppSizes.verticalSpacingL),
        if (analytics.dietaryPattern.isNotEmpty)
          _buildDietaryPattern(context, analytics),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, UserAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (analytics.mealTypeDistribution.isNotEmpty)
              Expanded(child: _buildMealTypeChart(context, analytics)),
            if (analytics.mealTypeDistribution.isNotEmpty &&
                analytics.ingredientUsage.isNotEmpty)
              SizedBox(width: AppSizes.spacingL),
            if (analytics.ingredientUsage.isNotEmpty)
              Expanded(child: _buildTopIngredientsChart(context, analytics)),
          ],
        ),
        if (analytics.categoryUsage.isNotEmpty ||
            analytics.dietaryPattern.isNotEmpty)
          SizedBox(height: AppSizes.verticalSpacingL),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (analytics.categoryUsage.isNotEmpty)
              Expanded(child: _buildCategoryUsageChart(context, analytics)),
            if (analytics.categoryUsage.isNotEmpty &&
                analytics.dietaryPattern.isNotEmpty)
              SizedBox(width: AppSizes.spacingL),
            if (analytics.dietaryPattern.isNotEmpty)
              Expanded(child: _buildDietaryPattern(context, analytics)),
          ],
        ),
      ],
    );
  }
}

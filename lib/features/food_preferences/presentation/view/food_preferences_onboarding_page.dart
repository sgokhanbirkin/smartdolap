import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/utils/responsive_extensions.dart';
import 'package:smartdolap/core/widgets/background_wrapper.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/food_preferences/domain/entities/food_preference.dart';
import 'package:smartdolap/features/food_preferences/presentation/viewmodel/food_preferences_cubit.dart';
import 'package:smartdolap/features/food_preferences/presentation/viewmodel/food_preferences_state.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Food preferences onboarding page
/// Allows users to select favorite foods and meal type products
class FoodPreferencesOnboardingPage extends StatefulWidget {
  /// Food preferences onboarding page constructor
  const FoodPreferencesOnboardingPage({super.key});

  @override
  State<FoodPreferencesOnboardingPage> createState() =>
      _FoodPreferencesOnboardingPageState();
}

class _FoodPreferencesOnboardingPageState
    extends State<FoodPreferencesOnboardingPage> {
  final Map<String, List<String>> _mealTypeProducts = <String, List<String>>{
    'breakfast': <String>[],
    'lunch': <String>[],
    'dinner': <String>[],
    'snack': <String>[],
  };

  final Map<String, TextEditingController> _productControllers =
      <String, TextEditingController>{
        'breakfast': TextEditingController(),
        'lunch': TextEditingController(),
        'dinner': TextEditingController(),
        'snack': TextEditingController(),
      };

  final Map<String, FocusNode> _productFocusNodes = <String, FocusNode>{
    'breakfast': FocusNode(),
    'lunch': FocusNode(),
    'dinner': FocusNode(),
    'snack': FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    // Delay loading to next frame to ensure all providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFoodPreferences();
      }
    });
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _productControllers.values) {
      controller.dispose();
    }
    for (final FocusNode focusNode in _productFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _loadFoodPreferences() {
    final AuthState authState = context.read<AuthCubit>().state;
    debugPrint(
      '[FoodPreferencesPage] Loading food preferences, authState: $authState',
    );

    bool userFound = false;
    authState.whenOrNull(
      authenticated: (User user) {
        debugPrint('[FoodPreferencesPage] User authenticated: ${user.id}');
        userFound = true;
        context.read<FoodPreferencesCubit>().loadFoodPreferences(user.id);
      },
    );

    // If not authenticated, still load preferences with empty user ID
    // This will show all available foods but won't load user-specific preferences
    if (!userFound) {
      debugPrint(
        '[FoodPreferencesPage] WARNING: User not authenticated! Loading with empty userId',
      );
      context.read<FoodPreferencesCubit>().loadFoodPreferences('');
    }
  }

  void _addProduct(String mealType) {
    final String product = _productControllers[mealType]!.text.trim();
    if (product.isEmpty) {
      return;
    }

    // Unfocus before clearing to prevent keyboard issues
    _productFocusNodes[mealType]?.unfocus();

    setState(() {
      if (!_mealTypeProducts[mealType]!.contains(product)) {
        _mealTypeProducts[mealType]!.add(product);
      }
      _productControllers[mealType]!.clear();
    });

    // Update cubit
    context.read<FoodPreferencesCubit>().updateMealTypePreferences(
      breakfast: mealType == 'breakfast'
          ? _mealTypeProducts['breakfast']
          : null,
      lunch: mealType == 'lunch' ? _mealTypeProducts['lunch'] : null,
      dinner: mealType == 'dinner' ? _mealTypeProducts['dinner'] : null,
      snack: mealType == 'snack' ? _mealTypeProducts['snack'] : null,
    );
  }

  void _removeProduct(String mealType, String product) {
    setState(() {
      _mealTypeProducts[mealType]!.remove(product);
    });

    // Update cubit
    context.read<FoodPreferencesCubit>().updateMealTypePreferences(
      breakfast: mealType == 'breakfast'
          ? _mealTypeProducts['breakfast']
          : null,
      lunch: mealType == 'lunch' ? _mealTypeProducts['lunch'] : null,
      dinner: mealType == 'dinner' ? _mealTypeProducts['dinner'] : null,
      snack: mealType == 'snack' ? _mealTypeProducts['snack'] : null,
    );
  }

  Future<void> _saveAndContinue() async {
    final AuthState authState = context.read<AuthCubit>().state;
    final FoodPreferencesCubit cubit = context.read<FoodPreferencesCubit>();

    await authState.whenOrNull(
      authenticated: (User user) async {
        if (user.householdId == null) {
          return;
        }

        // Update meal type preferences
        cubit.updateMealTypePreferences(
          breakfast: _mealTypeProducts['breakfast'],
          lunch: _mealTypeProducts['lunch'],
          dinner: _mealTypeProducts['dinner'],
          snack: _mealTypeProducts['snack'],
        );

        await cubit.saveFoodPreferences(
          userId: user.id,
          householdId: user.householdId!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = context.isTablet;

    return BlocListener<FoodPreferencesCubit, FoodPreferencesState>(
      listener: (BuildContext context, FoodPreferencesState state) {
        state.whenOrNull(
          saved: () {
            // If navigated from SharePage, pop back instead of replacing
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed(AppRouter.home);
            }
          },
          error: (String message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(tr('food_preferences_save_error')),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
            );
          },
        );
      },
      child: BackgroundWrapper(
        child: Scaffold(
          appBar: AppBar(title: Text(tr('food_preferences_onboarding_title'))),
          resizeToAvoidBottomInset: true,
          body: BlocBuilder<FoodPreferencesCubit, FoodPreferencesState>(
            builder: (BuildContext context, FoodPreferencesState state) =>
                state.when(
                  initial: () =>
                      const Center(child: CircularProgressIndicator()),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  loaded:
                      (
                        List<FoodPreference> allFoodPreferences,
                        List<String> selectedFoodIds,
                        _,
                      ) => SingleChildScrollView(
                        padding: EdgeInsets.all(AppSizes.padding),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Description
                            Text(
                              tr('food_preferences_onboarding_description'),
                              style: TextStyle(
                                fontSize: isTablet
                                    ? AppSizes.textL
                                    : AppSizes.textM,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppSizes.verticalSpacingXL),
                            // Food chips section
                            _buildFoodChipsSection(
                              context,
                              allFoodPreferences,
                              selectedFoodIds,
                              isTablet,
                            ),
                            SizedBox(height: AppSizes.verticalSpacingXL),
                            // Meal type products section
                            _buildMealTypeProductsSection(context, isTablet),
                            SizedBox(height: AppSizes.verticalSpacingXL),
                            // Continue button
                            _buildContinueButton(
                              context,
                              selectedFoodIds.length,
                            ),
                          ],
                        ),
                      ),
                  saving: () =>
                      const Center(child: CircularProgressIndicator()),
                  saved: () => const SizedBox.shrink(),
                  error: (String message) => Center(child: Text(message)),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodChipsSection(
    BuildContext context,
    List<FoodPreference> allFoodPreferences,
    List<String> selectedFoodIds,
    bool isTablet,
  ) {
    // Debug: Print the data being displayed
    debugPrint(
      '[FoodPreferencesPage] Building chips with ${allFoodPreferences.length} foods',
    );
    debugPrint('[FoodPreferencesPage] Selected IDs: $selectedFoodIds');

    // Group by category
    final Map<String, List<FoodPreference>> groupedByCategory =
        <String, List<FoodPreference>>{};
    for (final FoodPreference food in allFoodPreferences) {
      groupedByCategory.putIfAbsent(food.category, () => <FoodPreference>[]);
      groupedByCategory[food.category]!.add(food);
    }

    debugPrint(
      '[FoodPreferencesPage] Categories: ${groupedByCategory.keys.toList()}',
    );
    for (final entry in groupedByCategory.entries) {
      debugPrint(
        '[FoodPreferencesPage] Category ${entry.key}: ${entry.value.length} items',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Selection count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              tr(
                'food_preferences_selected',
                namedArgs: <String, String>{
                  'count': '${selectedFoodIds.length}',
                },
              ),
              style: TextStyle(
                fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.verticalSpacingM),
        // Food chips by category
        ...groupedByCategory.entries.map(
          (MapEntry<String, List<FoodPreference>> entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _getCategoryName(entry.key),
                style: TextStyle(
                  fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSizes.verticalSpacingS),
              Wrap(
                spacing: AppSizes.spacingS,
                runSpacing: AppSizes.verticalSpacingS,
                children: entry.value
                    .map(
                      (FoodPreference food) => FilterChip(
                        label: Text(food.name),
                        selected: selectedFoodIds.contains(food.id),
                        onSelected: (_) {
                          context
                              .read<FoodPreferencesCubit>()
                              .toggleFoodSelection(food.id);
                        },
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppSizes.verticalSpacingM),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeProductsSection(BuildContext context, bool isTablet) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            tr('meal_type_products_hint'),
            style: TextStyle(
              fontSize: isTablet ? AppSizes.textM : AppSizes.textS,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          // Breakfast
          _buildMealTypeProductInput(
            context,
            'breakfast',
            tr('meal_type_breakfast'),
            isTablet,
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          // Lunch
          _buildMealTypeProductInput(
            context,
            'lunch',
            tr('meal_type_lunch'),
            isTablet,
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          // Dinner
          _buildMealTypeProductInput(
            context,
            'dinner',
            tr('meal_type_dinner'),
            isTablet,
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          // Snack
          _buildMealTypeProductInput(
            context,
            'snack',
            tr('meal_type_snack'),
            isTablet,
          ),
        ],
      );

  Widget _buildMealTypeProductInput(
    BuildContext context,
    String mealType,
    String mealTypeLabel,
    bool isTablet,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        mealTypeLabel,
        style: TextStyle(
          fontSize: isTablet ? AppSizes.textS : AppSizes.textXS,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: AppSizes.verticalSpacingS / 2),
      Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _productControllers[mealType],
              focusNode: _productFocusNodes[mealType],
              enabled: true,
              enableInteractiveSelection: true,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: tr('meal_type_product_placeholder'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingM,
                  vertical: AppSizes.spacingS,
                ),
              ),
              onSubmitted: (_) => _addProduct(mealType),
            ),
          ),
          SizedBox(width: AppSizes.spacingS),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addProduct(mealType),
            tooltip: tr('meal_type_add_product'),
          ),
        ],
      ),
      if (_mealTypeProducts[mealType]!.isNotEmpty) ...<Widget>[
        SizedBox(height: AppSizes.verticalSpacingS / 2),
        Wrap(
          spacing: AppSizes.spacingS,
          runSpacing: AppSizes.verticalSpacingS / 2,
          children: _mealTypeProducts[mealType]!
              .map(
                (String product) => InputChip(
                  label: Text(product),
                  onDeleted: () => _removeProduct(mealType, product),
                ),
              )
              .toList(),
        ),
      ],
    ],
  );

  Widget _buildContinueButton(BuildContext context, int selectedCount) {
    // Always allow continuing - food selection is optional
    const bool canContinue = true;

    return BlocBuilder<FoodPreferencesCubit, FoodPreferencesState>(
      builder: (BuildContext context, FoodPreferencesState state) {
        final bool isSaving = state.maybeWhen(
          saving: () => true,
          orElse: () => false,
        );

        return ElevatedButton(
          onPressed: canContinue && !isSaving ? _saveAndContinue : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
          ),
          child: isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  tr('food_preferences_continue'),
                  style: const TextStyle(fontSize: 16),
                ),
        );
      },
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'turkish':
        return tr('food_category_turkish');
      case 'italian':
        return tr('food_category_italian');
      case 'asian':
        return tr('food_category_asian');
      case 'mediterranean':
        return tr('food_category_mediterranean');
      case 'breakfast':
        return tr('food_category_breakfast');
      case 'dessert':
        return tr('food_category_dessert');
      case 'vegetarian':
        return tr('food_category_vegetarian');
      default:
        return category;
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_cubit.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart'
    as profile_domain;
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/presentation/mixins/profile_actions_mixin.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_cubit.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_state.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_view_model.dart';
import 'package:smartdolap/features/profile/presentation/widgets/household_management_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/profile_display_section.dart';
import 'package:smartdolap/features/profile/presentation/widgets/profile_settings_section.dart';
import 'package:smartdolap/features/profile/presentation/widgets/settings_menu_widget.dart';

/// Profile page - User profile and settings
/// Refactored following SOLID principles:
/// - Single Responsibility: Only handles widget composition
/// - State management delegated to ProfileCubit
/// - UI sections extracted to separate widgets
/// - Actions extracted to ProfileActionsMixin
class ProfilePage extends StatefulWidget {
  /// Profile page constructor
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with
        TickerProviderStateMixin<ProfilePage>,
        ProfileActionsMixin<ProfilePage> {
  late AnimationController _pulseController;
  ProfileCubit? _profileCubit;
  ProfileViewModel? _profileViewModel;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.9,
      upperBound: 1.04,
    )..repeat(reverse: true);
    _profileCubit = sl<ProfileCubit>();
    _profileViewModel = sl<ProfileViewModel>(param1: _profileCubit!);
    unawaited(_profileViewModel?.initialize());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    unawaited(_profileViewModel?.dispose());
    _profileCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profileCubit == null || _profileViewModel == null) {
      return const SizedBox.shrink();
    }
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<HouseholdCubit>(create: (_) => sl<HouseholdCubit>()),
        BlocProvider<ProfileCubit>.value(value: _profileCubit!),
      ],
      child: RepositoryProvider<ProfileViewModel>.value(
        value: _profileViewModel!,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (BuildContext context, ProfileState state) {
              final ProfileViewModel profileViewModel = context
                  .read<ProfileViewModel>();
              return state.when(
                initial: () => const Center(
                  child: CustomLoadingIndicator(
                    type: LoadingType.pulsingGrid,
                    size: 50,
                  ),
                ).animate().fadeIn(duration: 300.ms),
                loading: () => const Center(
                  child: CustomLoadingIndicator(
                    type: LoadingType.pulsingGrid,
                    size: 50,
                  ),
                ).animate().fadeIn(duration: 300.ms),
                loaded:
                    (
                      PromptPreferences preferences,
                      ProfileStats stats,
                      List<profile_domain.Badge> badges,
                      List<UserRecipe> userRecipes,
                      int favoritesCount,
                    ) => CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: AppSizes.padding * 2,
                              left: AppSizes.padding,
                              right: AppSizes.padding,
                              bottom: AppSizes.padding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                // Household management section
                                const HouseholdManagementWidget(),
                                SizedBox(height: AppSizes.verticalSpacingXL),
                                // Display section (Hero, Stats, Badges)
                                ProfileDisplaySection(
                                  preferences: preferences,
                                  stats: stats,
                                  badges: badges,
                                  userRecipes: userRecipes,
                                  favoritesCount: favoritesCount,
                                  pulseController: _pulseController,
                                  onEditNickname: () => editNickname(
                                    currentPrefs: preferences,
                                    onPrefsSaved:
                                        profileViewModel.savePreferences,
                                  ),
                                  onSettingsTap: () =>
                                      SettingsMenuWidget.show(context),
                                  onSimulateAiRecipe: () => simulateAiRecipe(
                                    viewModel: profileViewModel,
                                  ),
                                  onCreateManualRecipe: () =>
                                      createManualRecipe(
                                        viewModel: profileViewModel,
                                      ),
                                  onUploadDishPhoto: () => uploadDishPhoto(
                                    viewModel: profileViewModel,
                                  ),
                                ),
                                SizedBox(height: AppSizes.verticalSpacingXL),
                                // Settings section (Preferences, Settings)
                                ProfileSettingsSection(
                                  preferences: preferences,
                                  onPrefsChanged:
                                      profileViewModel.savePreferences,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                error: (String message) => Center(child: Text(message)),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_cubit.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart'
    as domain;
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/presentation/mixins/profile_actions_mixin.dart';
import 'package:smartdolap/features/profile/presentation/utils/badge_progress_helper.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_cubit.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_state.dart';
import 'package:smartdolap/features/profile/presentation/viewmodel/profile_view_model.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_grid_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_preview_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/hero_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/household_management_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/preference_controls_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/prompt_preview_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/settings_menu_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/stats_tables_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

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
                      List<domain.Badge> badges,
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
                                // Hero card (Profile photo, name, level, stats)
                                HeroCardWidget(
                                      prefs: preferences,
                                      stats: stats,
                                      favoritesCount: favoritesCount,
                                      pulseController: _pulseController,
                                      onEditNickname: () => editNickname(
                                        currentPrefs: preferences,
                                        onPrefsSaved:
                                            (PromptPreferences prefs) async {
                                              await profileViewModel
                                                  .savePreferences(prefs);
                                            },
                                      ),
                                      onSettingsTap: () =>
                                          SettingsMenuWidget.show(context),
                                    )
                                    .animate()
                                    .fadeIn(
                                      duration: 500.ms,
                                      delay: 100.ms,
                                      curve: Curves.easeOut,
                                    )
                                    .slideY(
                                      begin: 0.1,
                                      end: 0,
                                      duration: 500.ms,
                                      delay: 100.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                SizedBox(height: AppSizes.verticalSpacingXL),
                                // Household management section
                                const HouseholdManagementWidget(),
                                SizedBox(height: AppSizes.verticalSpacingXL),
                                // Preference summary (Tercih Özeti)
                                PromptPreviewCardWidget(prefs: preferences)
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: 200.ms,
                                      curve: Curves.easeOut,
                                    )
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      duration: 400.ms,
                                      delay: 200.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                SizedBox(height: AppSizes.verticalSpacingXL),
                                // Stats and badges section
                                StatsTablesWidget(prefs: preferences)
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: 300.ms,
                                      curve: Curves.easeOut,
                                    )
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      duration: 400.ms,
                                      delay: 300.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                SizedBox(height: AppSizes.verticalSpacingXL),
                                BadgePreviewWidget(
                                      badges:
                                          BadgeProgressHelper.getPreviewBadges(
                                            badges,
                                            stats,
                                          ),
                                      onViewAll: () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(AppRouter.badges);
                                      },
                                      onBadgeTap: (domain.Badge badge) {
                                        showDialog<void>(
                                          context: context,
                                          builder: (_) =>
                                              BadgeDetailDialogWidget(
                                                badge: badge,
                                              ),
                                        );
                                      },
                                    )
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: 500.ms,
                                      curve: Curves.easeOut,
                                    )
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      duration: 400.ms,
                                      delay: 500.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                SizedBox(height: AppSizes.verticalSpacingXL),
                                // Preference controls
                                PreferenceControlsWidget(
                                      prefs: preferences,
                                      onPrefsChanged:
                                          (PromptPreferences prefs) async {
                                            await profileViewModel
                                                .savePreferences(prefs);
                                          },
                                    )
                                    .animate()
                                    .fadeIn(
                                      duration: 400.ms,
                                      delay: 400.ms,
                                      curve: Curves.easeOut,
                                    )
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      duration: 400.ms,
                                      delay: 400.ms,
                                      curve: Curves.easeOutCubic,
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

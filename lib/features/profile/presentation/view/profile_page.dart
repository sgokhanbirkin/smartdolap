import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/constants/mvp_flags.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_cubit.dart';
import 'package:smartdolap/features/household/presentation/widgets/qr_code_generator_widget.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart'
    as domain;
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_prompt_preference_service.dart';
import 'package:smartdolap/features/profile/presentation/utils/badge_progress_helper.dart';
import 'package:smartdolap/features/profile/presentation/view/user_recipe_form_page.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_grid_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_preview_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/collection_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/hero_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/preference_controls_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/prompt_preview_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/settings_menu_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/stats_tables_widget.dart';
import 'package:smartdolap/product/router/app_router.dart';

/// Profile page - User profile and settings
/// TODO(SOLID-SRP): Too many responsibilities - consider splitting into:
/// - ProfileDisplayPage (display only)
/// - ProfileSettingsPage (settings)
/// - ProfileStatsPage (stats)
/// TODO(RESPONSIVE): Add tablet/desktop layouts
/// TODO(LOCALIZATION): Ensure all badge names/descriptions are localization-ready
class ProfilePage extends StatefulWidget {
  /// Profile page constructor
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final IPromptPreferenceService _prefService = sl<IPromptPreferenceService>();
  final IProfileStatsService _statsService = sl<IProfileStatsService>();
  final UserRecipeService _userRecipeService = sl<UserRecipeService>();

  late PromptPreferences _prefs;
  ProfileStats _stats = const ProfileStats();
  List<UserRecipe> _userRecipes = <UserRecipe>[];
  List<domain.Badge> _badges = <domain.Badge>[];

  bool _isLoading = true;
  late AnimationController _pulseController;
  int _favoritesCount = 0;
  StreamSubscription<ProfileStats>? _statsSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.9,
      upperBound: 1.04,
    )..repeat(reverse: true);
    _loadInitialData();

    // Listen to stats changes
    _statsSubscription = _statsService.watch().listen((ProfileStats stats) {
      if (mounted) {
        setState(() => _stats = stats);
      }
    });
  }

  Future<void> _loadInitialData() async {
    try {
      _prefs = _prefService.getPreferences();
      _stats = _statsService.load();
      _userRecipes = _userRecipeService.fetch();
      final Box<dynamic> favBox = Hive.isBoxOpen('favorite_recipes')
          ? Hive.box<dynamic>('favorite_recipes')
          : await Hive.openBox<dynamic>('favorite_recipes');
      _favoritesCount = favBox.length;

      // Load badges - context'i async gap'ten önce al
      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      final BuildContext authContext = context;
      final AuthCubit authCubit = authContext.read<AuthCubit>();
      final AuthState authState = authCubit.state;

      await authState.whenOrNull(
        authenticated: (domain.User user) async {
          if (!mounted) {
            return;
          }
          try {
            final BadgeService badgeService = BadgeService(
              statsService: _statsService,
              badgeRepository: sl<IBadgeRepository>(),
              userId: user.id,
            );
            _badges = await badgeService.getAllBadgesWithStatus();
          } on Exception catch (e) {
            debugPrint('[ProfilePage] Badge yükleme hatası: $e');
            // Hata olsa bile devam et, boş liste ile
            _badges = <domain.Badge>[];
          }
        },
      );
    } on Exception catch (e, stackTrace) {
      debugPrint('[ProfilePage] _loadInitialData hatası: $e');
      debugPrint('[ProfilePage] Stack trace: $stackTrace');
      // Hata durumunda da loading'i kapat
    } finally {
      // Her durumda loading'i kapat
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _savePrefs(PromptPreferences prefs) async {
    setState(() => _prefs = prefs);
    await _prefService.savePreferences(prefs);
  }

  @override
  Widget build(BuildContext context) => BlocProvider<HouseholdCubit>(
    create: (_) => sl<HouseholdCubit>(),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CustomLoadingIndicator(
                type: LoadingType.pulsingGrid,
                size: 50,
              ),
            ).animate().fadeIn(duration: 300.ms)
          : CustomScrollView(
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
                        HeroCardWidget(
                              prefs: _prefs,
                              stats: _stats,
                              favoritesCount: _favoritesCount,
                              pulseController: _pulseController,
                              onEditNickname: _editNickname,
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
                        // Household management section - Always shown
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (BuildContext context, AuthState authState) {
                            return authState.maybeWhen(
                              authenticated: (domain.User user) {
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(AppSizes.padding),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radius,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.home_outlined,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Text(
                                                  user.householdId == null
                                                      ? tr(
                                                          'household_setup_title',
                                                        )
                                                      : tr(
                                                          'household_management',
                                                        ),
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
                                                ? tr(
                                                    'household_setup_description',
                                                  )
                                                : tr(
                                                    'household_management_description',
                                                  ),
                                            style: TextStyle(
                                              fontSize: AppSizes.textM,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          SizedBox(height: 16.h),
                                          if (user.householdId == null)
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pushNamed(
                                                        AppRouter
                                                            .householdSetup,
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.add_home,
                                                    ),
                                                    label: Text(
                                                      tr('create_household'),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pushNamed(
                                                        AppRouter
                                                            .householdSetup,
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.group_add,
                                                    ),
                                                    label: Text(
                                                      tr('join_household'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).pushNamed(AppRouter.share);
                                              },
                                              icon: const Icon(Icons.home),
                                              label: Text(
                                                tr('go_to_household'),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 16.h,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppSizes.verticalSpacingXL,
                                    ),
                                  ],
                                );
                              },
                              orElse: () => const SizedBox.shrink(),
                            );
                          },
                        ),
                        PromptPreviewCardWidget(prefs: _prefs)
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
                        StatsTablesWidget(prefs: _prefs)
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
                        PreferenceControlsWidget(
                              prefs: _prefs,
                              onPrefsChanged: _savePrefs,
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
                        SizedBox(height: AppSizes.verticalSpacingXL),
                        // Analytics section
                        ListTile(
                          leading: Icon(
                            Icons.analytics_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(tr('analytics.title')),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.analytics);
                          },
                        ),
                        SizedBox(height: AppSizes.verticalSpacingM),
                        // Badges preview section
                        BadgePreviewWidget(
                              badges: BadgeProgressHelper.getPreviewBadges(
                                _badges,
                                _stats,
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
                                      BadgeDetailDialogWidget(badge: badge),
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
                        // Advanced sections (optional - can be hidden)
                        if (kEnableAdvancedProfileSections) ...[
                          SizedBox(height: AppSizes.verticalSpacingL),
                          CollectionCardWidget(
                            stats: _stats,
                            userRecipes: _userRecipes,
                            onSimulateAiRecipe: _simulateAiRecipe,
                            onCreateManualRecipe: _createManualRecipe,
                            onUploadDishPhoto: _uploadDishPhoto,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    ),
  );

  Future<void> _showInviteDialog(
    BuildContext context,
    String householdId,
  ) async {
    final HouseholdCubit householdCubit = context.read<HouseholdCubit>();

    // Generate invite code
    final String? inviteCode = await householdCubit.generateInviteCode(
      householdId,
    );

    if (!context.mounted || inviteCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('error_generating_invite_code'))),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(tr('invite_member')),
        contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                tr('invite_code_description'),
                style: TextStyle(fontSize: AppSizes.textM),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  inviteCode,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16.h),
              QrCodeGeneratorWidget(inviteCode: inviteCode, size: 200.w),
              SizedBox(height: 16.h),
              Text(
                tr('invite_code_instructions'),
                style: TextStyle(
                  fontSize: AppSizes.textS,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('cancel')),
          ),
        ],
      ),
    );
  }

  Future<void> _editNickname() async {
    final TextEditingController controller = TextEditingController(
      text: _prefs.nickname,
    );
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(tr('profile_edit_nickname')),
        content: TextField(
          controller: controller,
          style: TextStyle(fontSize: AppSizes.textM),
          decoration: InputDecoration(hintText: tr('profile_nickname_hint')),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('confirm')),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _savePrefs(_prefs.copyWith(nickname: controller.text.trim()));
    }
  }

  Future<void> _simulateAiRecipe() async {
    final ProfileStats stats = await _statsService.incrementAiRecipes();
    await _statsService.addXp(40);
    if (!mounted) {
      return;
    }
    setState(() => _stats = stats);

    // Check for badges
    final AuthState authState = context.read<AuthCubit>().state;
    await authState.whenOrNull(
      authenticated: (domain.User user) async {
        final BadgeService badgeService = BadgeService(
          statsService: _statsService,
          badgeRepository: sl<IBadgeRepository>(),
          userId: user.id,
        );
        final List<domain.Badge> newlyUnlocked = await badgeService
            .checkAndAwardBadges();
        if (newlyUnlocked.isNotEmpty && mounted) {
          _badges = await badgeService.getAllBadgesWithStatus();
          setState(() {});
        }
      },
    );

    if (!mounted) {
      return;
    }
    final BuildContext snackbarContext = context;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(snackbarContext).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: AppSizes.iconS,
            ),
            SizedBox(width: AppSizes.spacingS),
            Expanded(
              child: Text(
                tr('profile_ai_recipe_recorded'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: AppSizes.padding,
          right: AppSizes.padding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _createManualRecipe() async {
    final bool? created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => UserRecipeFormPage(
          onSubmit:
              ({
                required String title,
                required List<String> ingredients,
                required List<String> steps,
                String description = '',
                List<String>? tags,
                String? imagePath,
                String? videoPath,
              }) async {
                await _userRecipeService.createManual(
                  title: title,
                  description: description,
                  ingredients: ingredients,
                  steps: steps,
                  tags: tags ?? <String>[],
                  imagePath: imagePath,
                  videoPath: videoPath,
                );
              },
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    if (created == true) {
      final ProfileStats stats = await _statsService.incrementUserRecipes();
      if (!mounted) {
        return;
      }
      setState(() {
        _userRecipes = _userRecipeService.fetch();
        _stats = stats;
      });

      // Check for badges
      if (!mounted) {
        return;
      }
      final BuildContext badgeContext = context;
      final AuthState authState = badgeContext.read<AuthCubit>().state;
      await authState.whenOrNull(
        authenticated: (domain.User user) async {
          final BadgeService badgeService = BadgeService(
            statsService: _statsService,
            badgeRepository: sl<IBadgeRepository>(),
            userId: user.id,
          );
          final List<domain.Badge> newlyUnlocked = await badgeService
              .checkAndAwardBadges();
          if (newlyUnlocked.isNotEmpty && mounted) {
            _badges = await badgeService.getAllBadgesWithStatus();
            setState(() {});
          }
        },
      );
    }
  }

  Future<void> _uploadDishPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final ProfileStats stats = await _statsService.incrementUserRecipes(
        withPhoto: true,
      );
      if (!mounted) {
        return;
      }
      setState(() => _stats = stats);

      // Check for badges
      if (!mounted) {
        return;
      }
      final BuildContext badgeContext = context;
      final AuthState authState = badgeContext.read<AuthCubit>().state;
      await authState.whenOrNull(
        authenticated: (domain.User user) async {
          final BadgeService badgeService = BadgeService(
            statsService: _statsService,
            badgeRepository: sl<IBadgeRepository>(),
            userId: user.id,
          );
          final List<domain.Badge> newlyUnlocked = await badgeService
              .checkAndAwardBadges();
          if (newlyUnlocked.isNotEmpty && mounted) {
            _badges = await badgeService.getAllBadgesWithStatus();
            setState(() {});
          }
        },
      );

      if (!mounted) {
        return;
      }
      final BuildContext snackbarContext = context;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(snackbarContext).showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Text(
                  tr('profile_photo_upload_placeholder'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: AppSizes.padding,
            right: AppSizes.padding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

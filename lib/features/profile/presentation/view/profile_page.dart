import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/constants/mvp_flags.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/core/widgets/custom_loading_indicator.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/profile/data/badge_service.dart';
import 'package:smartdolap/features/profile/data/profile_stats_service.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart'
    as domain;
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/presentation/view/user_recipe_form_page.dart';
import 'package:smartdolap/features/profile/presentation/widgets/badge_grid_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/collection_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/hero_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/preference_controls_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/prompt_preview_card_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/settings_menu_widget.dart';
import 'package:smartdolap/features/profile/presentation/widgets/stats_tables_widget.dart';

/// Profile page - User profile and settings
class ProfilePage extends StatefulWidget {
  /// Profile page constructor
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final PromptPreferenceService _prefService = sl<PromptPreferenceService>();
  final ProfileStatsService _statsService = sl<ProfileStatsService>();
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
    _prefs = _prefService.getPreferences();
    _stats = _statsService.load();
    _userRecipes = _userRecipeService.fetch();
    final Box<dynamic> favBox = Hive.isBoxOpen('favorite_recipes')
        ? Hive.box<dynamic>('favorite_recipes')
        : await Hive.openBox<dynamic>('favorite_recipes');
    _favoritesCount = favBox.length;

    // Load badges
    if (!mounted) {
      return;
    }
    final BuildContext authContext = context;
    final AuthState authState = authContext.read<AuthCubit>().state;
    await authState.whenOrNull(
      authenticated: (domain.User user) async {
        final BadgeService badgeService = BadgeService(
          statsService: _statsService,
          badgeRepository: sl<IBadgeRepository>(),
          userId: user.id,
        );
        _badges = await badgeService.getAllBadgesWithStatus();
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
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
  Widget build(BuildContext context) => Scaffold(
    body: _isLoading
        ? const Center(
            child: CustomLoadingIndicator(
              type: LoadingType.pulsingGrid,
              size: 50,
            ),
          )
        : Stack(
            children: <Widget>[
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      HeroCardWidget(
                        prefs: _prefs,
                        stats: _stats,
                        favoritesCount: _favoritesCount,
                        pulseController: _pulseController,
                        onEditNickname: _editNickname,
                      ),
                      SizedBox(height: AppSizes.verticalSpacingL),
                      PromptPreviewCardWidget(prefs: _prefs),
                      SizedBox(height: AppSizes.verticalSpacingL),
                      StatsTablesWidget(prefs: _prefs),
                      SizedBox(height: AppSizes.verticalSpacingL),
                      PreferenceControlsWidget(
                        prefs: _prefs,
                        onPrefsChanged: _savePrefs,
                      ),
                      SizedBox(height: AppSizes.verticalSpacingL),
                      // Badges section
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.emoji_events,
                                    size: AppSizes.icon,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  SizedBox(width: AppSizes.spacingS),
                                  Text(
                                    tr('badges_title'),
                                    style: TextStyle(
                                      fontSize: AppSizes.textL,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSizes.verticalSpacingM),
                              SizedBox(
                                height: AppSizes.verticalSpacingXXL * 8,
                                child: BadgeGridWidget(
                                  badges: _badges,
                                  onBadgeTap: (domain.Badge badge) {
                                    showDialog<void>(
                                      context: context,
                                      builder: (_) =>
                                          BadgeDetailDialogWidget(badge: badge),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
              // Sağ üstte ayarlar butonu
              Positioned(
                top: MediaQuery.of(context).padding.top + AppSizes.spacingS,
                right: AppSizes.spacingM,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: tr('settings'),
                  onPressed: () => SettingsMenuWidget.show(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
  );

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
    ScaffoldMessenger.of(
      snackbarContext,
    ).showSnackBar(SnackBar(content: Text(tr('profile_ai_recipe_recorded'))));
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
      ScaffoldMessenger.of(snackbarContext).showSnackBar(
        SnackBar(content: Text(tr('profile_photo_upload_placeholder'))),
      );
    }
  }
}

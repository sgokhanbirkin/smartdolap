/// Represents contextual metrics that can unlock an achievement.
class AchievementContext {
  AchievementContext({
    required this.metrics,
    required this.totalSessions,
    this.userId = 'anonymous',
    this.displayName = 'Anonymous',
    this.scoreDelta = 0,
  });

  /// Arbitrary numeric metrics (e.g., {"pantryAdds": 10})
  final Map<String, num> metrics;

  /// Number of gameplay/app sessions.
  final int totalSessions;

  /// Optional identifier for leaderboard updates.
  final String userId;

  /// Optional display name for leaderboard updates.
  final String displayName;

  /// The score delta that should be applied to the leaderboard.
  final int scoreDelta;

  num metric(String key) => metrics[key] ?? 0;
}

/// Definition of an achievement including its unlock rule.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.localizationKey,
    required this.points,
    required this.predicate,
  });

  final String id;
  final String localizationKey;
  final int points;
  final bool Function(AchievementContext context) predicate;
}

/// Represents an unlocked achievement instance.
class Achievement {
  const Achievement({
    required this.id,
    required this.localizationKey,
    required this.points,
    required this.unlockedAt,
  });

  final String id;
  final String localizationKey;
  final int points;
  final DateTime unlockedAt;
}

/// Handles evaluation and unlocking of achievements.
class AchievementService {
  AchievementService({
    List<AchievementDefinition>? definitions,
  }) : _definitions = definitions ?? _defaultDefinitions;

  final List<AchievementDefinition> _definitions;
  final Set<String> _unlockedAchievementIds = <String>{};

  /// Evaluates the provided [context] and returns newly unlocked achievements.
  List<Achievement> evaluate(AchievementContext context) {
    final List<Achievement> unlocked = _definitions
        .where((AchievementDefinition def) {
          if (_unlockedAchievementIds.contains(def.id)) {
            return false;
          }
          return def.predicate(context);
        })
        .map(
          (AchievementDefinition def) => Achievement(
            id: def.id,
            localizationKey: def.localizationKey,
            points: def.points,
            unlockedAt: DateTime.now(),
          ),
        )
        .toList();

    _unlockedAchievementIds.addAll(unlocked.map((Achievement e) => e.id));
    return unlocked;
  }

  /// Returns unlocked achievement ids (useful for persistence).
  List<String> get unlockedIds => _unlockedAchievementIds.toList();

  static List<AchievementDefinition> get _defaultDefinitions =>
      <AchievementDefinition>[
        AchievementDefinition(
          id: 'onboarding_complete',
          localizationKey: 'gamification_achievement_onboarding_complete',
          points: 50,
          predicate: (AchievementContext context) =>
              context.metric('onboardingSteps') >= 3,
        ),
        AchievementDefinition(
          id: 'pantry_master',
          localizationKey: 'gamification_achievement_pantry_master',
          points: 80,
          predicate: (AchievementContext context) =>
              context.metric('pantryItemsAdded') >= 20,
        ),
        AchievementDefinition(
          id: 'recipe_creator',
          localizationKey: 'gamification_achievement_recipe_creator',
          points: 120,
          predicate: (AchievementContext context) =>
              context.metric('manualRecipesCreated') >= 5,
        ),
        AchievementDefinition(
          id: 'consistency_star',
          localizationKey: 'gamification_achievement_consistency_star',
          points: 100,
          predicate: (AchievementContext context) =>
              context.totalSessions >= 14 &&
              context.metric('dailyActions') >= 10,
        ),
      ];
}



import 'package:smartdolap/features/gamification/services/achievement_service.dart';
import 'package:smartdolap/features/gamification/services/badge_service.dart';
import 'package:smartdolap/features/gamification/services/leaderboard_service.dart';
import 'package:smartdolap/features/gamification/services/reward_service.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart';

/// Wiring point for all gamification services.
class GamificationEngine {
  const GamificationEngine({
    required this.badgeService,
    required this.achievementService,
    required this.leaderboardService,
    required this.rewardService,
  });

  factory GamificationEngine.basic({
    required BadgeService badgeService,
    GamificationLocalizer? localize,
  }) =>
      GamificationEngine(
        badgeService: badgeService,
        achievementService: AchievementService(),
        leaderboardService: LeaderboardService(),
        rewardService: RewardService(
          localize: localize ?? (String key) => key,
        ),
      );

  final BadgeService badgeService;
  final AchievementService achievementService;
  final LeaderboardService leaderboardService;
  final RewardService rewardService;

  /// Evaluates the gamification state based on [context] and returns a snapshot.
  Future<GamificationSnapshot> evaluate(AchievementContext context) async {
    final List<Badge> newlyUnlockedBadges =
        await badgeService.checkAndAwardBadges();
    final List<Badge> allBadges = await badgeService.getAllBadgesWithStatus();
    final List<Achievement> unlockedAchievements =
        achievementService.evaluate(context);

    if (context.scoreDelta != 0) {
      leaderboardService.updateScore(
        userId: context.userId,
        displayName: context.displayName,
        delta: context.scoreDelta,
      );
    }
    final List<LeaderboardEntry> standings = leaderboardService.top();

    RewardPayload? reward;
    if (unlockedAchievements.isNotEmpty) {
      final int totalPoints = unlockedAchievements.fold(
        0,
        (int sum, Achievement achievement) => sum + achievement.points,
      );
      reward = rewardService.createReward(
        localizationKey: 'gamification.reward.achievement',
        points: totalPoints,
      );
    } else if (newlyUnlockedBadges.isNotEmpty) {
      reward = rewardService.createReward(
        localizationKey: 'gamification.reward.badge',
        points: newlyUnlockedBadges.length * 25,
      );
    }

    return GamificationSnapshot(
      badges: allBadges,
      newlyUnlockedBadges: newlyUnlockedBadges,
      achievements: unlockedAchievements,
      leaderboard: standings,
      reward: reward,
    );
  }
}

/// Aggregated gamification data.
class GamificationSnapshot {
  const GamificationSnapshot({
    required this.badges,
    required this.newlyUnlockedBadges,
    required this.achievements,
    required this.leaderboard,
    required this.reward,
  });

  final List<Badge> badges;
  final List<Badge> newlyUnlockedBadges;
  final List<Achievement> achievements;
  final List<LeaderboardEntry> leaderboard;
  final RewardPayload? reward;
}



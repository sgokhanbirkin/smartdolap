import 'package:smartdolap/features/profile/data/badge_definitions.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_profile_stats_service.dart';
import 'package:smartdolap/features/profile/data/repositories/badge_repository_impl.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';

/// Service for managing badge awards and unlocks
class BadgeService {
  /// Creates a badge service
  BadgeService({
    required this.statsService,
    required this.badgeRepository,
    required this.userId,
  });

  /// Profile stats service for checking badge conditions
  final IProfileStatsService statsService;

  /// Badge repository for saving/loading badges
  final IBadgeRepository badgeRepository;

  /// User ID for badge operations
  final String userId;

  /// Checks and awards badges based on current stats
  Future<List<Badge>> checkAndAwardBadges() async {
    final ProfileStats currentStats = statsService.load();
    final List<Badge> allBadges = BadgeDefinitions.getAllBadges();
    final List<Badge> newlyUnlocked = <Badge>[];

    // Load existing unlocked badges from Firestore
    final List<Badge> unlockedBadges = await badgeRepository.loadBadges(userId);
    final Set<String> unlockedIds = unlockedBadges
        .map((Badge badge) => badge.id)
        .toSet();

    for (final Badge badge in allBadges) {
      // Skip if already unlocked
      if (unlockedIds.contains(badge.id)) {
        continue;
      }

      // Check if condition is met
      if (badge.unlockCondition(currentStats)) {
        final Badge unlockedBadge = badge.copyWith(unlockedAt: DateTime.now());
        newlyUnlocked.add(unlockedBadge);

        // Save to Firestore
        await badgeRepository.saveBadge(userId, unlockedBadge);

        // Update local stats
        final List<String> updatedBadges = <String>[
          ...currentStats.badges,
          badge.id,
        ];
        await statsService.save(currentStats.copyWith(badges: updatedBadges));
      }
    }

    return newlyUnlocked;
  }

  /// Gets all badges with their unlock status
  Future<List<Badge>> getAllBadgesWithStatus() async {
    final List<Badge> allBadges = BadgeDefinitions.getAllBadges();
    final List<Badge> unlockedBadges = await badgeRepository.loadBadges(userId);
    final Map<String, Badge> unlockedMap = <String, Badge>{
      for (final Badge badge in unlockedBadges) badge.id: badge,
    };

    return allBadges.map((Badge badge) {
      final Badge? unlocked = unlockedMap[badge.id];
      return unlocked ?? badge;
    }).toList();
  }
}

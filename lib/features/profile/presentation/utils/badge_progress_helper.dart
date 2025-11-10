import 'package:smartdolap/features/profile/domain/entities/badge.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';

/// Helper class for badge progress calculations
class BadgeProgressHelper {
  /// Calculates progress percentage (0.0 to 1.0) for a badge
  static double calculateProgress(Badge badge, ProfileStats stats) {
    switch (badge.id) {
      case 'first_recipe':
        return (stats.aiRecipes + stats.userRecipes) / 1.0;
      case 'ten_recipes':
        return (stats.aiRecipes + stats.userRecipes) / 10.0;
      case 'photographer':
        return stats.photoUploads / 5.0;
      case 'level_five':
        return stats.level / 5.0;
      case 'level_ten':
        return stats.level / 10.0;
      case 'chef':
        return stats.userRecipes / 3.0;
      case 'ai_master':
        return stats.aiRecipes / 20.0;
      case 'social_chef':
        return stats.photoUploads / 10.0;
      default:
        return 0.0;
    }
  }

  /// Gets the most important badges for preview (3 badges)
  /// Priority: 1. Latest unlocked, 2. Closest to unlock (80%+), 3. Most important milestone
  static List<Badge> getPreviewBadges(
    List<Badge> allBadges,
    ProfileStats stats,
  ) {
    // Separate unlocked and locked badges
    final List<Badge> unlocked = allBadges
        .where((Badge b) => b.isUnlocked)
        .toList()
      ..sort((Badge a, Badge b) {
        // Sort by unlock date (most recent first)
        if (a.unlockedAt == null && b.unlockedAt == null) {
          return 0;
        }
        if (a.unlockedAt == null) {
          return 1;
        }
        if (b.unlockedAt == null) {
          return -1;
        }
        return b.unlockedAt!.compareTo(a.unlockedAt!);
      });

    final List<Badge> locked = allBadges
        .where((Badge b) => !b.isUnlocked)
        .toList();

    // Calculate progress for locked badges
    final List<MapEntry<Badge, double>> lockedWithProgress = locked
        .map((Badge b) => MapEntry<Badge, double>(
              b,
              calculateProgress(b, stats),
            ))
        .toList()
      ..sort((MapEntry<Badge, double> a, MapEntry<Badge, double> b) =>
          b.value.compareTo(a.value));

    final List<Badge> result = <Badge>[];

    // 1. Latest unlocked badge (if exists)
    if (unlocked.isNotEmpty) {
      result.add(unlocked.first);
    }

    // 2. Closest to unlock (80%+ progress)
    final List<Badge> closeToUnlock = lockedWithProgress
        .where((MapEntry<Badge, double> entry) => entry.value >= 0.8)
        .map((MapEntry<Badge, double> entry) => entry.key)
        .toList();
    if (closeToUnlock.isNotEmpty && result.length < 3) {
      result.add(closeToUnlock.first);
    }

    // 3. Most important milestone (first_recipe, ten_recipes, level_five, etc.)
    final List<String> importantIds = <String>[
      'first_recipe',
      'ten_recipes',
      'level_five',
      'chef',
      'ai_master',
    ];
    for (final String id in importantIds) {
      if (result.length >= 3) {
        break;
      }
      final Badge? badge = allBadges.firstWhere(
        (Badge b) => b.id == id,
        orElse: () => allBadges.first,
      );
      if (badge != null && !result.contains(badge)) {
        result.add(badge);
      }
    }

    // Fill remaining slots with highest progress badges
    if (result.length < 3) {
      for (final MapEntry<Badge, double> entry in lockedWithProgress) {
        if (result.length >= 3) {
          break;
        }
        if (!result.contains(entry.key)) {
          result.add(entry.key);
        }
      }
    }

    return result.take(3).toList();
  }
}


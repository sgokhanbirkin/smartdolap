import 'package:smartdolap/features/profile/domain/entities/badge.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';

/// Badge definitions with unlock conditions
class BadgeDefinitions {
  /// Returns all available badge definitions
  static List<Badge> getAllBadges() => <Badge>[
        Badge(
          id: 'first_recipe',
          nameKey: 'badge_first_recipe_name',
          descriptionKey: 'badge_first_recipe_description',
          icon: 'restaurant_menu',
          unlockCondition: (ProfileStats stats) =>
              stats.aiRecipes + stats.userRecipes >= 1,
        ),
        Badge(
          id: 'ten_recipes',
          nameKey: 'badge_ten_recipes_name',
          descriptionKey: 'badge_ten_recipes_description',
          icon: 'restaurant',
          unlockCondition: (ProfileStats stats) =>
              stats.aiRecipes + stats.userRecipes >= 10,
        ),
        Badge(
          id: 'photographer',
          nameKey: 'badge_photographer_name',
          descriptionKey: 'badge_photographer_description',
          icon: 'camera_alt',
          unlockCondition: (ProfileStats stats) => stats.photoUploads >= 5,
        ),
        Badge(
          id: 'level_five',
          nameKey: 'badge_level_five_name',
          descriptionKey: 'badge_level_five_description',
          icon: 'star',
          unlockCondition: (ProfileStats stats) => stats.level >= 5,
        ),
        Badge(
          id: 'level_ten',
          nameKey: 'badge_level_ten_name',
          descriptionKey: 'badge_level_ten_description',
          icon: 'stars',
          unlockCondition: (ProfileStats stats) => stats.level >= 10,
        ),
        Badge(
          id: 'chef',
          nameKey: 'badge_chef_name',
          descriptionKey: 'badge_chef_description',
          icon: 'local_dining',
          unlockCondition: (ProfileStats stats) =>
              stats.userRecipes >= 3,
        ),
        Badge(
          id: 'ai_master',
          nameKey: 'badge_ai_master_name',
          descriptionKey: 'badge_ai_master_description',
          icon: 'auto_awesome',
          unlockCondition: (ProfileStats stats) => stats.aiRecipes >= 20,
        ),
        Badge(
          id: 'social_chef',
          nameKey: 'badge_social_chef_name',
          descriptionKey: 'badge_social_chef_description',
          icon: 'share',
          unlockCondition: (ProfileStats stats) =>
              stats.photoUploads >= 10,
        ),
      ];

  /// Gets a badge by ID
  static Badge? getBadgeById(String id) {
    try {
      return getAllBadges().firstWhere((Badge badge) => badge.id == id);
    } catch (_) {
      return null;
    }
  }
}


/// Signature for localization lookups.
typedef GamificationLocalizer = String Function(String key);

/// Represents a user-facing reward payload.
class RewardPayload {
  const RewardPayload({
    required this.title,
    required this.description,
    required this.points,
  });

  final String title;
  final String description;
  final int points;
}

/// Handles reward calculation and localization.
class RewardService {
  RewardService({
    required GamificationLocalizer localize,
  }) : _localize = localize;

  final GamificationLocalizer _localize;

  /// Creates a reward payload from a localization key & score delta.
  RewardPayload createReward({
    required String localizationKey,
    required int points,
  }) {
    final String title = _localize('$localizationKey.title');
    final String description = _localize('$localizationKey.description');
    return RewardPayload(
      title: title,
      description: description,
      points: points,
    );
  }
}



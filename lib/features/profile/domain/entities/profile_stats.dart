/// Stores gamification stats for profile screen.
class ProfileStats {
  /// Creates a stats model with optional overrides.
  const ProfileStats({
    this.level = 1,
    this.xp = 0,
    this.nextLevelXp = 200,
    this.aiRecipes = 0,
    this.userRecipes = 0,
    this.photoUploads = 0,
    this.badges = const <String>[],
  });

  /// Restores stats from a stored map.
  factory ProfileStats.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const ProfileStats();
    }
    return ProfileStats(
      level: (map['level'] as num?)?.toInt() ?? 1,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      nextLevelXp: (map['nextLevelXp'] as num?)?.toInt() ?? 200,
      aiRecipes: (map['aiRecipes'] as num?)?.toInt() ?? 0,
      userRecipes: (map['userRecipes'] as num?)?.toInt() ?? 0,
      photoUploads: (map['photoUploads'] as num?)?.toInt() ?? 0,
      badges:
          (map['badges'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    );
  }

  /// Current gamification level.
  final int level;
  /// Experience points accumulated within the current level.
  final int xp;
  /// Threshold required to reach the next level.
  final int nextLevelXp;
  /// Number of AI generated recipes.
  final int aiRecipes;
  /// Number of user submitted recipes.
  final int userRecipes;
  /// Total uploaded photos tied to recipes.
  final int photoUploads;
  /// Earned badge identifiers.
  final List<String> badges;

  /// Creates a modified copy.
  ProfileStats copyWith({
    int? level,
    int? xp,
    int? nextLevelXp,
    int? aiRecipes,
    int? userRecipes,
    int? photoUploads,
    List<String>? badges,
  }) => ProfileStats(
    level: level ?? this.level,
    xp: xp ?? this.xp,
    nextLevelXp: nextLevelXp ?? this.nextLevelXp,
    aiRecipes: aiRecipes ?? this.aiRecipes,
    userRecipes: userRecipes ?? this.userRecipes,
    photoUploads: photoUploads ?? this.photoUploads,
    badges: badges ?? this.badges,
  );

  /// Serializes the stats for Hive/JSON storage.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'level': level,
    'xp': xp,
    'nextLevelXp': nextLevelXp,
    'aiRecipes': aiRecipes,
    'userRecipes': userRecipes,
    'photoUploads': photoUploads,
    'badges': badges,
  };

}

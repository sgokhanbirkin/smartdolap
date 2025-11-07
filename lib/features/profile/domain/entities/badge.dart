import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';

/// Badge entity for gamification system
class Badge {
  /// Creates a badge with required fields
  const Badge({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.icon,
    required this.unlockCondition,
    this.unlockedAt,
  });

  /// Badge unique identifier
  final String id;

  /// Localization key for badge name
  final String nameKey;

  /// Localization key for badge description
  final String descriptionKey;

  /// Icon identifier (Material Icons name)
  final String icon;

  /// Condition function to check if badge should be unlocked
  final bool Function(ProfileStats stats) unlockCondition;

  /// Timestamp when badge was unlocked (null if locked)
  final DateTime? unlockedAt;

  /// Creates a badge from map (for Firestore/Hive)
  factory Badge.fromMap(Map<dynamic, dynamic> map) {
    return Badge(
      id: map['id'] as String,
      nameKey: map['nameKey'] as String,
      descriptionKey: map['descriptionKey'] as String,
      icon: map['icon'] as String,
      unlockCondition: (_) => false, // Not serializable, use definitions
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'] as String)
          : null,
    );
  }

  /// Converts badge to map (for Firestore/Hive)
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'nameKey': nameKey,
        'descriptionKey': descriptionKey,
        'icon': icon,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  /// Creates a copy with updated unlockedAt
  Badge copyWith({DateTime? unlockedAt}) => Badge(
        id: id,
        nameKey: nameKey,
        descriptionKey: descriptionKey,
        icon: icon,
        unlockCondition: unlockCondition,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  /// Checks if badge is unlocked
  bool get isUnlocked => unlockedAt != null;
}


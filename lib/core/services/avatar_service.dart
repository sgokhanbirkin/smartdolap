/// Avatar service - Manages avatar selection
class AvatarService {
  /// List of available avatar IDs
  static const List<String> availableAvatars = <String>[
    'avatar_1',
    'avatar_2',
    'avatar_3',
    'avatar_4',
    'avatar_5',
    'avatar_6',
    'avatar_7',
    'avatar_8',
    'avatar_9',
    'avatar_10',
    'avatar_11',
    'avatar_12',
  ];

  /// Get avatar emoji/icon based on ID
  static String getAvatarIcon(String avatarId) {
    const Map<String, String> avatarIcons = <String, String>{
      'avatar_1': '👤',
      'avatar_2': '👨',
      'avatar_3': '👩',
      'avatar_4': '🧑',
      'avatar_5': '👨‍🦱',
      'avatar_6': '👩‍🦱',
      'avatar_7': '👨‍🦰',
      'avatar_8': '👩‍🦰',
      'avatar_9': '👨‍🦳',
      'avatar_10': '👩‍🦳',
      'avatar_11': '🧓',
      'avatar_12': '👶',
    };
    return avatarIcons[avatarId] ?? '👤';
  }

  /// Get default avatar ID
  static String getDefaultAvatar() => availableAvatars.first;

  /// Check if avatar ID is valid
  static bool isValidAvatar(String avatarId) =>
      availableAvatars.contains(avatarId);
}


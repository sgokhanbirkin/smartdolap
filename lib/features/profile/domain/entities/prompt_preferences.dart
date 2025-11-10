import 'package:flutter/material.dart';

  /// Stores personalization knobs used across profile and AI prompts.
class PromptPreferences {
  /// Creates preference bundle with helpful defaults.
  const PromptPreferences({
    this.nickname = '',
    this.dietStyle = 'dengeli',
    this.cuisineFocus = 'Akdeniz',
    this.tone = 'enerjik',
    this.goal = 'pratik',
    this.spiceLevel = 0.5,
    this.sweetTooth = 0.4,
    this.customNote = '',
    this.servings = 2,
    this.recipesGenerated = 0,
    this.customDiets = const <String>[],
    this.customCuisines = const <String>[],
    this.customTones = const <String>[],
    this.customGoals = const <String>[],
    // Advanced settings
    this.cookingTime = 'orta', // 'hızlı', 'orta', 'uzun'
    this.difficulty = 'orta', // 'kolay', 'orta', 'zor'
    this.calorieRangeMin = 0, // 0 = no limit
    this.calorieRangeMax = 0, // 0 = no limit
    this.proteinMin = 0, // grams, 0 = no limit
    this.fiberMin = 0, // grams, 0 = no limit
    this.specialDiets = const <String>[], // gluten-free, laktoz-free, vb.
    this.seasonalPreference = '', // 'kış', 'yaz', 'ilkbahar', 'sonbahar', ''
    this.preferredMealTypes = const <String>[], // breakfast, lunch, dinner, snack
  });

  /// Restores preferences from a stored map.
  factory PromptPreferences.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const PromptPreferences();
    }
    return PromptPreferences(
      nickname: (map['nickname'] as String?) ?? '',
      dietStyle: (map['dietStyle'] as String?) ?? 'dengeli',
      cuisineFocus: (map['cuisineFocus'] as String?) ?? 'Akdeniz',
      tone: (map['tone'] as String?) ?? 'enerjik',
      goal: (map['goal'] as String?) ?? 'pratik',
      spiceLevel: (map['spiceLevel'] as num?)?.toDouble() ?? 0.5,
      sweetTooth: (map['sweetTooth'] as num?)?.toDouble() ?? 0.4,
      customNote: (map['customNote'] as String?) ?? '',
      servings: (map['servings'] as num?)?.toInt() ?? 2,
      recipesGenerated: (map['recipesGenerated'] as num?)?.toInt() ?? 0,
      customDiets:
          (map['customDiets'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      customCuisines:
          (map['customCuisines'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      customTones:
          (map['customTones'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      customGoals:
          (map['customGoals'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      // Advanced settings
      cookingTime: (map['cookingTime'] as String?) ?? 'orta',
      difficulty: (map['difficulty'] as String?) ?? 'orta',
      calorieRangeMin: (map['calorieRangeMin'] as num?)?.toInt() ?? 0,
      calorieRangeMax: (map['calorieRangeMax'] as num?)?.toInt() ?? 0,
      proteinMin: (map['proteinMin'] as num?)?.toInt() ?? 0,
      fiberMin: (map['fiberMin'] as num?)?.toInt() ?? 0,
      specialDiets:
          (map['specialDiets'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
      seasonalPreference: (map['seasonalPreference'] as String?) ?? '',
      preferredMealTypes:
          (map['preferredMealTypes'] as List<dynamic>?)?.cast<String>() ??
          const <String>[],
    );
  }

  /// Friendly nickname shown on the hero card.
  final String nickname;
  /// Preferred diet style (vegan, keto, etc.).
  final String dietStyle;
  /// Highlighted cuisine focus.
  final String cuisineFocus;
  /// Desired tone/mood for copy.
  final String tone;
  /// High-level wellness/goal focus.
  final String goal;
  /// Heat intensity slider 0-1.
  final double spiceLevel;
  /// Sweet tooth intensity slider 0-1.
  final double sweetTooth;
  /// Free-form preference note.
  final String customNote;
  /// Number of servings to suggest.
  final int servings;
  /// Count of generated recipes for analytics.
  final int recipesGenerated;
  /// Custom diet chips added by the user.
  final List<String> customDiets;
  /// Custom cuisine chips added by the user.
  final List<String> customCuisines;
  /// Custom tone chips added by the user.
  final List<String> customTones;
  /// Custom goals chips added by the user.
  final List<String> customGoals;
  
  // Advanced settings
  /// Preferred cooking time: 'hızlı', 'orta', 'uzun'
  final String cookingTime;
  /// Preferred difficulty level: 'kolay', 'orta', 'zor'
  final String difficulty;
  /// Minimum calorie range (0 = no limit)
  final int calorieRangeMin;
  /// Maximum calorie range (0 = no limit)
  final int calorieRangeMax;
  /// Minimum protein content in grams (0 = no limit)
  final int proteinMin;
  /// Minimum fiber content in grams (0 = no limit)
  final int fiberMin;
  /// Special diet restrictions (gluten-free, laktoz-free, etc.)
  final List<String> specialDiets;
  /// Seasonal preference: 'kış', 'yaz', 'ilkbahar', 'sonbahar', or ''
  final String seasonalPreference;
  /// Preferred meal types: 'breakfast', 'lunch', 'dinner', 'snack'
  final List<String> preferredMealTypes;

  /// Creates a modified copy with new values.
  PromptPreferences copyWith({
    String? nickname,
    String? dietStyle,
    String? cuisineFocus,
    String? tone,
    String? goal,
    double? spiceLevel,
    double? sweetTooth,
    String? customNote,
    int? servings,
    int? recipesGenerated,
    List<String>? customDiets,
    List<String>? customCuisines,
    List<String>? customTones,
    List<String>? customGoals,
    String? cookingTime,
    String? difficulty,
    int? calorieRangeMin,
    int? calorieRangeMax,
    int? proteinMin,
    int? fiberMin,
    List<String>? specialDiets,
    String? seasonalPreference,
    List<String>? preferredMealTypes,
  }) => PromptPreferences(
    nickname: nickname ?? this.nickname,
    dietStyle: dietStyle ?? this.dietStyle,
    cuisineFocus: cuisineFocus ?? this.cuisineFocus,
    tone: tone ?? this.tone,
    goal: goal ?? this.goal,
    spiceLevel: spiceLevel ?? this.spiceLevel,
    sweetTooth: sweetTooth ?? this.sweetTooth,
    customNote: customNote ?? this.customNote,
    servings: servings ?? this.servings,
    recipesGenerated: recipesGenerated ?? this.recipesGenerated,
    customDiets: customDiets ?? this.customDiets,
    customCuisines: customCuisines ?? this.customCuisines,
    customTones: customTones ?? this.customTones,
    customGoals: customGoals ?? this.customGoals,
    cookingTime: cookingTime ?? this.cookingTime,
    difficulty: difficulty ?? this.difficulty,
    calorieRangeMin: calorieRangeMin ?? this.calorieRangeMin,
    calorieRangeMax: calorieRangeMax ?? this.calorieRangeMax,
    proteinMin: proteinMin ?? this.proteinMin,
    fiberMin: fiberMin ?? this.fiberMin,
    specialDiets: specialDiets ?? this.specialDiets,
    seasonalPreference: seasonalPreference ?? this.seasonalPreference,
    preferredMealTypes: preferredMealTypes ?? this.preferredMealTypes,
  );

  /// Serializes the preferences for Hive/JSON storage.
  Map<String, dynamic> toMap() => <String, dynamic>{
    'nickname': nickname,
    'dietStyle': dietStyle,
    'cuisineFocus': cuisineFocus,
    'tone': tone,
    'goal': goal,
    'spiceLevel': spiceLevel,
    'sweetTooth': sweetTooth,
    'customNote': customNote,
    'servings': servings,
    'recipesGenerated': recipesGenerated,
    'customDiets': customDiets,
    'customCuisines': customCuisines,
    'customTones': customTones,
    'customGoals': customGoals,
    'cookingTime': cookingTime,
    'difficulty': difficulty,
    'calorieRangeMin': calorieRangeMin,
    'calorieRangeMax': calorieRangeMax,
    'proteinMin': proteinMin,
    'fiberMin': fiberMin,
    'specialDiets': specialDiets,
    'seasonalPreference': seasonalPreference,
    'preferredMealTypes': preferredMealTypes,
  };

  /// Short text used inside OpenAI prompts.
  String composePrompt([String? base]) {
    final List<String> lines = <String>[
      if (base != null && base.isNotEmpty) base,
      'Kullanıcı diyeti: $dietStyle. Mutfağı: $cuisineFocus.',
      if (customDiets.isNotEmpty)
        'Ekstra diyet tercihleri: ${customDiets.join(', ')}.',
      if (customCuisines.isNotEmpty)
        'Ekstra mutfaklar: ${customCuisines.join(', ')}.',
      'Yemek tonu $tone, hedefi $goal.',
      if (customTones.isNotEmpty)
        'Alternatif tonlar: ${customTones.join(', ')}.',
      if (customGoals.isNotEmpty)
        'Ekstra hedefler: ${customGoals.join(', ')}.',
      'Baharat isteği ${(spiceLevel * 10).round()}/10, tatlı isteği ${(sweetTooth * 10).round()}/10.',
      'Porsiyon: $servings kişi.',
      // Advanced settings
      if (cookingTime != 'orta')
        'Pişirme süresi tercihi: $cookingTime.',
      if (difficulty != 'orta')
        'Zorluk seviyesi tercihi: $difficulty.',
      if (calorieRangeMin > 0 || calorieRangeMax > 0)
        'Kalori aralığı: ${calorieRangeMin > 0 ? '$calorieRangeMin-' : ''}${calorieRangeMax > 0 ? '$calorieRangeMax' : ''} kcal.',
      if (proteinMin > 0)
        'Minimum protein içeriği: $proteinMin gram.',
      if (fiberMin > 0)
        'Minimum lif içeriği: $fiberMin gram.',
      if (specialDiets.isNotEmpty)
        'Özel diyet kısıtlamaları: ${specialDiets.join(', ')}.',
      if (seasonalPreference.isNotEmpty)
        'Mevsimsel tercih: $seasonalPreference.',
      if (preferredMealTypes.isNotEmpty)
        'Tercih edilen öğün tipleri: ${preferredMealTypes.join(', ')}.',
    ];
    if (customNote.trim().isNotEmpty) {
      lines.add('Ek not: $customNote');
    }
    return lines.join(' ');
  }

  /// Rows for summary table.
  List<MapEntry<String, String>> summaryRows(BuildContext context) {
    final String dietSummary = customDiets.isEmpty
        ? dietStyle
        : '$dietStyle · ${customDiets.join(', ')}';
    final String cuisineSummary = customCuisines.isEmpty
        ? cuisineFocus
        : '$cuisineFocus · ${customCuisines.join(', ')}';
    final String toneSummary = customTones.isEmpty
        ? tone
        : '$tone · ${customTones.join(', ')}';
    final String goalSummary = customGoals.isEmpty
        ? goal
        : '$goal · ${customGoals.join(', ')}';
    return <MapEntry<String, String>>[
      MapEntry<String, String>('diet', dietSummary),
      MapEntry<String, String>('cuisine', cuisineSummary),
      MapEntry<String, String>('tone', toneSummary),
      MapEntry<String, String>('goal', goalSummary),
      MapEntry<String, String>('spice', '${(spiceLevel * 10).round()}/10'),
      MapEntry<String, String>('sweet', '${(sweetTooth * 10).round()}/10'),
      MapEntry<String, String>('servings', '$servings'),
    ];
  }
}

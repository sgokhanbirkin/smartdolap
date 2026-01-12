import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Centralizes pantry category metadata and keyword heuristics.
/// Categories are stored as internal keys and displayed using localization.
class PantryCategoryHelper {
  PantryCategoryHelper._();

  /// Internal category keys (used for storage and internal logic).
  /// These keys are language-independent and mapped to localized names via getLocalizedCategoryName().
  static const List<String> categories = <String>[
    'dairy',
    'vegetables',
    'fruits',
    'meat',
    'legumes',
    'grains',
    'nuts',
    'spices',
    'snacks',
    'drinks',
    'frozen',
    'breakfast',
    'other',
  ];

  /// Mapping from old Turkish category names to new internal keys (for backward compatibility).
  static const Map<String, String> _legacyCategoryMap = <String, String>{
    'Süt Ürünleri': 'dairy',
    'Sebze': 'vegetables',
    'Meyve': 'fruits',
    'Et / Tavuk / Balık': 'meat',
    'Bakliyat': 'legumes',
    'Tahıl & Fırın': 'grains',
    'Baklagil & Tohum': 'nuts',
    'Baharat & Sos': 'spices',
    'Atıştırmalık': 'snacks',
    'İçecek': 'drinks',
    'Dondurulmuş': 'frozen',
    'Diğer': 'other',
  };

  /// Get localized category name for display.
  /// Accepts both internal keys (e.g., 'dairy') and legacy Turkish names (e.g., 'Süt Ürünleri').
  static String getLocalizedCategoryName(String category) {
    // Normalize to internal key first
    final String normalized = normalize(category);

    // Map internal keys to localization keys
    switch (normalized) {
      case 'dairy':
        return tr('categories.dairy');
      case 'vegetables':
        return tr('categories.vegetables');
      case 'fruits':
        return tr('categories.fruits');
      case 'meat':
        return tr('categories.meat');
      case 'legumes':
        return tr('categories.legumes');
      case 'grains':
        return tr('categories.grains');
      case 'nuts':
        return tr('categories.nuts');
      case 'spices':
        return tr('categories.spices');
      case 'snacks':
        return tr('categories.snacks');
      case 'drinks':
        return tr('categories.drinks');
      case 'frozen':
        return tr('categories.frozen');
      case 'breakfast':
        return tr('categories.breakfast');
      case 'other':
      default:
        return tr('categories.other');
    }
  }

  /// Keywords for category guessing (mapped to internal keys).
  static const Map<String, List<String>> _keywords = <String, List<String>>{
    'dairy': <String>[
      'süt',
      'yoğurt',
      'peynir',
      'kaymak',
      'tereyağ',
      'krema',
      'kefir',
    ],
    'vegetables': <String>[
      'domates',
      'biber',
      'salatalık',
      'patlıcan',
      'kabak',
      'marul',
      'ıspanak',
      'roka',
      'havuç',
      'brokoli',
    ],
    'fruits': <String>[
      'elma',
      'muz',
      'portakal',
      'armut',
      'çilek',
      'kavun',
      'karpuz',
      'kiraz',
      'nar',
      'üzüm',
    ],
    'meat': <String>[
      'et',
      'tavuk',
      'balık',
      'kıyma',
      'hindi',
      'sucuk',
      'pastırma',
      'somon',
      'ton',
    ],
    'legumes': <String>[
      'mercimek',
      'nohut',
      'fasulye',
      'barbunya',
      'bakla',
      'bezelye',
    ],
    'grains': <String>[
      'ekmek',
      'makarna',
      'pirinç',
      'bulgur',
      'yulaf',
      'mısır',
      'un',
      'lavaş',
    ],
    'nuts': <String>['ceviz', 'fındık', 'badem', 'chia', 'keten', 'susam'],
    'spices': <String>[
      'tuz',
      'karabiber',
      'kimyon',
      'pul biber',
      'ketçap',
      'mayonez',
      'hardal',
      'sos',
      'baharat',
    ],
    'snacks': <String>['bisküvi', 'kraker', 'çikolata', 'cips', 'gofret'],
    'drinks': <String>[
      'su',
      'çay',
      'kahve',
      'meyve suyu',
      'içecek',
      'gazoz',
      'soda',
    ],
    'frozen': <String>[
      'dondurulmuş',
      'dondurma',
      'mısır',
      'pizza',
      'sebze',
      'mısır',
      'pizza',
      'sebze',
      'patates',
    ],
    'breakfast': <String>[
      'tahin',
      'pekmez',
      'reçel',
      'bal',
      'zeytin',
      'helva',
      'fındık ezmesi',
      'fıstık ezmesi',
      'krem peynir',
      'müsli',
      'gevrek',
      'granola',
    ],
  };

  /// Returns a normalized internal category key.
  /// Supports both new internal keys and legacy Turkish category names for backward compatibility.
  static String normalize(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'other';
    }
    final String value = raw.trim();

    // Check if it's already an internal key
    final String direct = categories.firstWhere(
      (String c) => c.toLowerCase() == value.toLowerCase(),
      orElse: () => '',
    );
    if (direct.isNotEmpty) {
      return direct;
    }

    // Check if it's a legacy Turkish category name
    final String? legacyKey = _legacyCategoryMap[value];
    if (legacyKey != null) {
      return legacyKey;
    }

    // Try case-insensitive legacy mapping
    for (final MapEntry<String, String> entry in _legacyCategoryMap.entries) {
      if (entry.key.toLowerCase() == value.toLowerCase()) {
        return entry.value;
      }
    }

    // Fall back to guessing
    return guess(value);
  }

  /// Quick keyword based guess for given product name.
  /// Returns an internal category key.
  static String guess(String name) {
    final String lower = name.toLowerCase();
    for (final MapEntry<String, List<String>> entry in _keywords.entries) {
      final bool hit = entry.value.any(lower.contains);
      if (hit) {
        return entry.key;
      }
    }
    return 'other';
  }

  /// Icon helper for quick visual hints.
  /// Accepts both internal keys and legacy category names.
  static IconData iconFor(String category) {
    final String normalized = normalize(category);
    switch (normalized) {
      case 'dairy':
        return Icons.icecream;
      case 'vegetables':
        return Icons.grass;
      case 'fruits':
        return Icons.eco;
      case 'meat':
        return Icons.set_meal;
      case 'legumes':
      case 'nuts':
        return Icons.spa;
      case 'grains':
        return Icons.bakery_dining;
      case 'spices':
        return Icons.auto_awesome;
      case 'snacks':
        return Icons.cookie;
      case 'drinks':
        return Icons.local_cafe;
      case 'frozen':
        return Icons.ac_unit;
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'other':
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

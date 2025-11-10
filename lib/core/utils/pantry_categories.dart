import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Centralizes pantry category metadata and keyword heuristics.
/// TODO(LOCALIZATION): Category names are now localization-ready via tr() calls
class PantryCategoryHelper {
  PantryCategoryHelper._();

  /// Canonical category list shown in selectors.
  /// TODO(LOCALIZATION): These keys should be mapped to localization keys
  static const List<String> categories = <String>[
    'Süt Ürünleri',
    'Sebze',
    'Meyve',
    'Et / Tavuk / Balık',
    'Bakliyat',
    'Tahıl & Fırın',
    'Baklagil & Tohum',
    'Baharat & Sos',
    'Atıştırmalık',
    'İçecek',
    'Dondurulmuş',
    'Diğer',
  ];

  /// Get localized category name
  /// TODO(LOCALIZATION): Implement full localization mapping
  static String getLocalizedCategoryName(String category) {
    // Map internal category names to localization keys
    switch (category) {
      case 'Süt Ürünleri':
        return tr('categories.dairy');
      case 'Sebze':
        return tr('categories.vegetables');
      case 'Meyve':
        return tr('categories.fruits');
      case 'Et / Tavuk / Balık':
        return tr('categories.meat');
      case 'Bakliyat':
        return tr('categories.legumes');
      case 'Tahıl & Fırın':
        return tr('categories.grains');
      case 'Baklagil & Tohum':
        return tr('categories.nuts');
      case 'Baharat & Sos':
        return tr('categories.spices');
      case 'Atıştırmalık':
        return tr('categories.snacks');
      case 'İçecek':
        return tr('categories.drinks');
      case 'Dondurulmuş':
        return tr('categories.frozen');
      case 'Diğer':
      default:
        return tr('categories.other');
    }
  }

  static const Map<String, List<String>> _keywords = <String, List<String>>{
    'Süt Ürünleri': <String>[
      'süt',
      'yoğurt',
      'peynir',
      'kaymak',
      'tereyağ',
      'krema',
      'kefir',
    ],
    'Sebze': <String>[
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
    'Meyve': <String>[
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
    'Et / Tavuk / Balık': <String>[
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
    'Bakliyat': <String>[
      'mercimek',
      'nohut',
      'fasulye',
      'barbunya',
      'bakla',
      'bezelye',
    ],
    'Tahıl & Fırın': <String>[
      'ekmek',
      'makarna',
      'pirinç',
      'bulgur',
      'yulaf',
      'mısır',
      'un',
      'lavaş',
    ],
    'Baklagil & Tohum': <String>[
      'ceviz',
      'fındık',
      'badem',
      'chia',
      'keten',
      'susam',
    ],
    'Baharat & Sos': <String>[
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
    'Atıştırmalık': <String>['bisküvi', 'kraker', 'çikolata', 'cips', 'gofret'],
    'İçecek': <String>[
      'su',
      'çay',
      'kahve',
      'meyve suyu',
      'içecek',
      'gazoz',
      'soda',
    ],
    'Dondurulmuş': <String>[
      'dondurulmuş',
      'dondurma',
      'mısır',
      'pizza',
      'sebze',
      'patates',
    ],
  };

  /// Returns a normalized, display friendly category.
  static String normalize(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Diğer';
    }
    final String value = raw.trim();
    final String direct = categories.firstWhere(
      (String c) => c.toLowerCase() == value.toLowerCase(),
      orElse: () => '',
    );
    if (direct.isNotEmpty) {
      return direct;
    }
    return guess(value);
  }

  /// Quick keyword based guess for given product name.
  static String guess(String name) {
    final String lower = name.toLowerCase();
    for (final MapEntry<String, List<String>> entry in _keywords.entries) {
      final bool hit = entry.value.any(lower.contains);
      if (hit) {
        return entry.key;
      }
    }
    return 'Diğer';
  }

  /// Icon helper for quick visual hints.
  static IconData iconFor(String category) {
    final String normalized = normalize(category);
    switch (normalized) {
      case 'Süt Ürünleri':
        return Icons.icecream;
      case 'Sebze':
        return Icons.grass;
      case 'Meyve':
        return Icons.eco;
      case 'Et / Tavuk / Balık':
        return Icons.set_meal;
      case 'Bakliyat':
      case 'Baklagil & Tohum':
        return Icons.spa;
      case 'Tahıl & Fırın':
        return Icons.bakery_dining;
      case 'Baharat & Sos':
        return Icons.auto_awesome;
      case 'Atıştırmalık':
        return Icons.cookie;
      case 'İçecek':
        return Icons.local_cafe;
      case 'Dondurulmuş':
        return Icons.ac_unit;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

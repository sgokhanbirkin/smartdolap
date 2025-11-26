import 'dart:math';

/// Ingredient message generator with Turkish humor and cultural references
/// Uses decision tree logic to generate contextual, funny messages
class IngredientMessageGenerator {
  IngredientMessageGenerator._();

  static final Random _random = Random();

  /// Generate a funny combination message based on ingredients
  static String generateCombinationMessage(
    String ingredient1,
    String ingredient2,
  ) {
    final String lower1 = ingredient1.toLowerCase();
    final String lower2 = ingredient2.toLowerCase();

    // Decision tree: Check ingredient properties and generate appropriate message
    final List<String> messages = <String>[];

    // 1. Turkish cuisine classics
    if (_isTurkishClassic(lower1, lower2)) {
      messages.addAll(_getTurkishClassicMessages(ingredient1, ingredient2));
    }

    // 2. Spicy combinations
    if (_isSpicy(lower1) || _isSpicy(lower2)) {
      messages.addAll(_getSpicyMessages(ingredient1, ingredient2));
    }

    // 3. Dairy combinations (yoğurt, peynir)
    if (_isDairy(lower1) || _isDairy(lower2)) {
      messages.addAll(_getDairyMessages(ingredient1, ingredient2));
    }

    // 4. Protein + Vegetable combinations
    if ((_isProtein(lower1) && _isVegetable(lower2)) ||
        (_isProtein(lower2) && _isVegetable(lower1))) {
      messages.addAll(_getProteinVegetableMessages(ingredient1, ingredient2));
    }

    // 5. Sweet combinations
    if (_isSweet(lower1) || _isSweet(lower2)) {
      messages.addAll(_getSweetMessages(ingredient1, ingredient2));
    }

    // 6. Legume combinations
    if (_isLegume(lower1) || _isLegume(lower2)) {
      messages.addAll(_getLegumeMessages(ingredient1, ingredient2));
    }

    // 7. Breakfast combinations
    if (_isBreakfastItem(lower1) || _isBreakfastItem(lower2)) {
      messages.addAll(_getBreakfastMessages(ingredient1, ingredient2));
    }

    // 8. Italian cuisine hints
    if (_isItalian(lower1, lower2)) {
      messages.addAll(_getItalianMessages(ingredient1, ingredient2));
    }

    // 9. Diet-friendly combinations
    if (_isDietFriendly(lower1, lower2)) {
      messages.addAll(_getDietMessages(ingredient1, ingredient2));
    }

    // 10. Unexpected combinations
    if (_isUnexpected(lower1, lower2)) {
      messages.addAll(_getUnexpectedMessages(ingredient1, ingredient2));
    }

    // 11. Classic pairs
    if (_isClassicPair(lower1, lower2)) {
      messages.addAll(_getClassicPairMessages(ingredient1, ingredient2));
    }

    // Fallback: Generic funny messages
    if (messages.isEmpty) {
      messages.addAll(_getGenericMessages(ingredient1, ingredient2));
    }

    // Return random message from collected options
    return messages[_random.nextInt(messages.length)];
  }

  // Ingredient property checkers
  static bool _isTurkishClassic(String ing1, String ing2) {
    final List<String> turkishClassics = <String>[
      'domates',
      'soğan',
      'biber',
      'patlıcan',
      'kabak',
      'fasulye',
      'mercimek',
      'nohut',
      'bulgur',
      'pirinç',
      'yoğurt',
      'peynir',
      'tavuk',
      'kıyma',
    ];
    return turkishClassics.any((String classic) =>
            ing1.contains(classic) || ing2.contains(classic)) &&
        turkishClassics.any((String classic) =>
            ing1.contains(classic) || ing2.contains(classic));
  }

  static bool _isSpicy(String ing) => ing.contains('biber') ||
        ing.contains('acı') ||
        ing.contains('pul biber') ||
        ing.contains('kırmızı biber') ||
        ing.contains('karabiber');

  static bool _isDairy(String ing) => ing.contains('yoğurt') ||
        ing.contains('peynir') ||
        ing.contains('süt') ||
        ing.contains('kaşar') ||
        ing.contains('beyaz peynir') ||
        ing.contains('lor');

  static bool _isProtein(String ing) => ing.contains('tavuk') ||
        ing.contains('et') ||
        ing.contains('balık') ||
        ing.contains('kıyma') ||
        ing.contains('köfte') ||
        ing.contains('yumurta');

  static bool _isVegetable(String ing) => ing.contains('domates') ||
        ing.contains('biber') ||
        ing.contains('patlıcan') ||
        ing.contains('kabak') ||
        ing.contains('soğan') ||
        ing.contains('salatalık') ||
        ing.contains('havuç') ||
        ing.contains('brokoli');

  static bool _isSweet(String ing) => ing.contains('elma') ||
        ing.contains('muz') ||
        ing.contains('çilek') ||
        ing.contains('şeker') ||
        ing.contains('bal') ||
        ing.contains('pekmez');

  static bool _isLegume(String ing) => ing.contains('fasulye') ||
        ing.contains('mercimek') ||
        ing.contains('nohut') ||
        ing.contains('barbunya');

  static bool _isBreakfastItem(String ing) => ing.contains('yumurta') ||
        ing.contains('peynir') ||
        ing.contains('zeytin') ||
        ing.contains('domates') ||
        ing.contains('salatalık') ||
        ing.contains('bal');

  static bool _isItalian(String ing1, String ing2) {
    final List<String> italian = <String>[
      'domates',
      'mozzarella',
      'fesleğen',
      'makarna',
      'zeytinyağı',
    ];
    return italian.any((String item) =>
            ing1.contains(item) || ing2.contains(item)) &&
        (ing1.contains('domates') || ing2.contains('domates'));
  }

  static bool _isDietFriendly(String ing1, String ing2) => (_isVegetable(ing1) && _isVegetable(ing2)) ||
        (_isLegume(ing1) && _isVegetable(ing2)) ||
        (_isLegume(ing2) && _isVegetable(ing1));

  static bool _isUnexpected(String ing1, String ing2) => (_isSweet(ing1) && _isProtein(ing2)) ||
        (_isSweet(ing2) && _isProtein(ing1)) ||
        (_isBreakfastItem(ing1) && _isLegume(ing2)) ||
        (_isBreakfastItem(ing2) && _isLegume(ing1));

  static bool _isClassicPair(String ing1, String ing2) {
    final List<List<String>> classicPairs = <List<String>>[
      <String>['domates', 'soğan'],
      <String>['tavuk', 'pirinç'],
      <String>['yumurta', 'peynir'],
      <String>['fasulye', 'pirinç'],
      <String>['mercimek', 'soğan'],
    ];
    return classicPairs.any((List<String> pair) =>
        (ing1.contains(pair[0]) && ing2.contains(pair[1])) ||
        (ing1.contains(pair[1]) && ing2.contains(pair[0])));
  }

  // Message generators
  static List<String> _getTurkishClassicMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Türk mutfağının vazgeçilmezi! 🇹🇷',
      "$ing1 ve $ing2 birlikte... Anadolu'nun lezzeti! 🏔️",
      '$ing1 ile $ing2... Dedemizin tarifi! 👴',
      '$ing1 ve $ing2... Geleneksel lezzet! 🍲',
      '$ing1 ile $ing2... Türk mutfağı klasikleri! 🥘',
      '$ing1 ve $ing2... Annemizin yaptığı gibi! 👩‍🍳',
      '$ing1 ile $ing2... Sofralarımızın baş tacı! 🍽️',
    ];

  static List<String> _getSpicyMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Acı sever misin? 🔥',
      '$ing1 ve $ing2... Biraz baharat katıyoruz! 🌶️',
      '$ing1 ile $ing2... Ateşli bir kombinasyon! 🔥',
      '$ing1 ve $ing2... Acılı sevenler için! 💥',
      '$ing1 ile $ing2... Biber sevenler buraya! 🌶️',
      '$ing1 ve $ing2... Hafif acı mı, çok acı mı? 😅',
    ];

  static List<String> _getDairyMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Yoğurt mu? Türk mutfağının vazgeçilmezi! 🥛',
      '$ing1 ve $ing2... Peynir olmadan olmaz! 🧀',
      '$ing1 ile $ing2... Süt ürünleri gücü! 💪',
      '$ing1 ve $ing2... Kaşar mı, beyaz peynir mi? 🤔',
      '$ing1 ile $ing2... Yoğurtlu mu olsun? 🍶',
      '$ing1 ve $ing2... Peynirli kombinasyon! 🧀',
    ];

  static List<String> _getProteinVegetableMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Protein + sebze = dengeli öğün! ⚖️',
      '$ing1 ve $ing2... Sağlıklı bir kombinasyon! 💚',
      '$ing1 ile $ing2... Et ve sebze uyumu! 🥩🥬',
      '$ing1 ve $ing2... Doyurucu ve besleyici! 🍽️',
      '$ing1 ile $ing2... Klasik ana yemek! 🍛',
      '$ing1 ve $ing2... Protein kaynağı + vitamin! 💊',
    ];

  static List<String> _getSweetMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Tatlı bir kombinasyon! 🍯',
      '$ing1 ve $ing2... Şeker sevenler için! 🍬',
      '$ing1 ile $ing2... Doğal tatlılık! 🍎',
      '$ing1 ve $ing2... Bal gibi olacak! 🍯',
    ];

  static List<String> _getLegumeMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Bakliyat gücü! 💪',
      '$ing1 ve $ing2... Doyurucu ve ekonomik! 💰',
      '$ing1 ile $ing2... Protein kaynağı! 🥜',
      '$ing1 ve $ing2... Vejetaryen dostu! 🌱',
      '$ing1 ile $ing2... Baklagil zenginliği! 🌿',
    ];

  static List<String> _getBreakfastMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Kahvaltılık bir ikili! 🍳',
      '$ing1 ve $ing2... Sabah enerjisi! ☀️',
      '$ing1 ile $ing2... Kahvaltı sofrası hazır! 🥐',
      '$ing1 ve $ing2... Günaydın kombinasyonu! 🌅',
    ];

  static List<String> _getItalianMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... İtalyan mısınız? 🇮🇹',
      '$ing1 ve $ing2... Akdeniz lezzeti! 🍝',
      '$ing1 ile $ing2... İtalyan mutfağına selam! 👋',
      '$ing1 ve $ing2... Pasta mı, pizza mı? 🍕',
    ];

  static List<String> _getDietMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Diyet dostu! 🥗',
      '$ing1 ve $ing2... Kalori düşük, lezzet yüksek! 📉',
      '$ing1 ile $ing2... Sağlıklı seçim! 💚',
      '$ing1 ve $ing2... Fit yaşam! 💪',
      '$ing1 ile $ing2... Light versiyon! ✨',
    ];

  static List<String> _getUnexpectedMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Hmm, nasıl olur acaba? 🤔',
      '$ing1 ve $ing2... İlginç bir kombinasyon! 🎯',
      '$ing1 ile $ing2... Beklenmedik ama denemeye değer! 🎲',
      '$ing1 ve $ing2... Yaratıcı bir fikir! 💡',
      '$ing1 ile $ing2... Sürpriz bir lezzet! 🎁',
      '$ing1 ve $ing2... Dene bakalım ne olacak! 🧪',
    ];

  static List<String> _getClassicPairMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Klasik bir ikili! 👌',
      '$ing1 ve $ing2... Zamanın testinden geçmiş! ⏰',
      '$ing1 ile $ing2... Her zaman uyumlu! 💑',
      '$ing1 ve $ing2... Efsanevi kombinasyon! ⭐',
      '$ing1 ile $ing2... Kanıtlanmış lezzet! ✅',
    ];

  static List<String> _getGenericMessages(String ing1, String ing2) => <String>[
      '$ing1 ile $ing2... Lezzetli bir kombinasyon! 🍽️',
      '$ing1 ve $ing2... Güzel bir fikir! 💭',
      '$ing1 ile $ing2... Denemeye değer! 🎯',
      '$ing1 ve $ing2... Yaratıcı kombinasyon! 🎨',
      '$ing1 ile $ing2... Farklı bir tat! 👅',
      '$ing1 ve $ing2... Merak uyandırıcı! 🔍',
      '$ing1 ile $ing2... İlginç bir seçim! 🎲',
      '$ing1 ve $ing2... Beklenmedik ama güzel! ✨',
    ];
}


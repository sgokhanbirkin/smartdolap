import 'package:smartdolap/features/food_preferences/domain/entities/food_preference.dart';

/// Static food preferences data
/// This can be moved to Firestore later for easier updates
class FoodPreferencesData {
  /// Get all available food preferences
  static List<FoodPreference> getAllFoodPreferences() {
    return <FoodPreference>[
      // Turkish Cuisine
      const FoodPreference(
        id: 'manti',
        name: 'Mantı',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'kebap',
        name: 'Kebap',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'lahmacun',
        name: 'Lahmacun',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'borek',
        name: 'Börek',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'kofte',
        name: 'Köfte',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'corba',
        name: 'Çorba',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'pilav',
        name: 'Pilav',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'baklava',
        name: 'Baklava',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'dolma',
        name: 'Dolma',
        category: 'turkish',
      ),
      const FoodPreference(
        id: 'karniyarik',
        name: 'Karnıyarık',
        category: 'turkish',
      ),

      // Italian Cuisine
      const FoodPreference(
        id: 'pizza',
        name: 'Pizza',
        category: 'italian',
      ),
      const FoodPreference(
        id: 'pasta',
        name: 'Makarna',
        category: 'italian',
      ),
      const FoodPreference(
        id: 'risotto',
        name: 'Risotto',
        category: 'italian',
      ),
      const FoodPreference(
        id: 'lasagna',
        name: 'Lazanya',
        category: 'italian',
      ),
      const FoodPreference(
        id: 'tiramisu',
        name: 'Tiramisu',
        category: 'italian',
      ),

      // Asian Cuisine
      const FoodPreference(
        id: 'sushi',
        name: 'Suşi',
        category: 'asian',
      ),
      const FoodPreference(
        id: 'ramen',
        name: 'Ramen',
        category: 'asian',
      ),
      const FoodPreference(
        id: 'pad_thai',
        name: 'Pad Thai',
        category: 'asian',
      ),
      const FoodPreference(
        id: 'curry',
        name: 'Köri',
        category: 'asian',
      ),
      const FoodPreference(
        id: 'dumpling',
        name: 'Mantı (Asya)',
        category: 'asian',
      ),

      // Mediterranean Cuisine
      const FoodPreference(
        id: 'hummus',
        name: 'Humus',
        category: 'mediterranean',
      ),
      const FoodPreference(
        id: 'falafel',
        name: 'Falafel',
        category: 'mediterranean',
      ),
      const FoodPreference(
        id: 'tzatziki',
        name: 'Cacık',
        category: 'mediterranean',
      ),

      // Breakfast
      const FoodPreference(
        id: 'menemen',
        name: 'Menemen',
        category: 'breakfast',
      ),
      const FoodPreference(
        id: 'omlet',
        name: 'Omlet',
        category: 'breakfast',
      ),
      const FoodPreference(
        id: 'waffle',
        name: 'Waffle',
        category: 'breakfast',
      ),
      const FoodPreference(
        id: 'french_toast',
        name: 'Fransız Tostu',
        category: 'breakfast',
      ),
      const FoodPreference(
        id: 'pancake',
        name: 'Pankek',
        category: 'breakfast',
      ),

      // Desserts
      const FoodPreference(
        id: 'cheesecake',
        name: 'Cheesecake',
        category: 'dessert',
      ),
      const FoodPreference(
        id: 'brownie',
        name: 'Brownie',
        category: 'dessert',
      ),
      const FoodPreference(
        id: 'ice_cream',
        name: 'Dondurma',
        category: 'dessert',
      ),
      const FoodPreference(
        id: 'kunefe',
        name: 'Künefe',
        category: 'dessert',
      ),

      // Vegetarian/Vegan
      const FoodPreference(
        id: 'salata',
        name: 'Salata',
        category: 'vegetarian',
      ),
      const FoodPreference(
        id: 'smoothie_bowl',
        name: 'Smoothie Bowl',
        category: 'vegetarian',
      ),
      const FoodPreference(
        id: 'veggie_burger',
        name: 'Vejetaryen Burger',
        category: 'vegetarian',
      ),
    ];
  }

  /// Get food preferences by category
  static List<FoodPreference> getFoodPreferencesByCategory(String category) {
    return getAllFoodPreferences()
        .where((FoodPreference food) => food.category == category)
        .toList();
  }

  /// Get all categories
  static List<String> getAllCategories() {
    return getAllFoodPreferences()
        .map((FoodPreference food) => food.category)
        .toSet()
        .toList();
  }
}


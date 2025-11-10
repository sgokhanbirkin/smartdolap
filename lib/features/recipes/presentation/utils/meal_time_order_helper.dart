import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Helper class for meal time ordering based on current time
/// TODO(LOCALIZATION): Meal names are now localization-ready via tr() calls
class MealTimeOrderHelper {
  /// Get ordered meal list based on current time
  /// Returns list of meals in order: [first, second, third, fourth]
  static List<String> getOrderedMeals() {
    final int hour = DateTime.now().hour;

    // Sabah 7-11 arası: kahvaltı - ara öğün - öğle - akşam
    if (hour >= 7 && hour < 11) {
      return <String>['breakfast', 'snack', 'lunch', 'dinner'];
    }
    // Öğle 11-15 arası: öğle - ara öğün - akşam - kahvaltı
    if (hour >= 11 && hour < 15) {
      return <String>['lunch', 'snack', 'dinner', 'breakfast'];
    }
    // Akşam 15-20 arası: akşam - ara öğün - kahvaltı - öğle
    if (hour >= 15 && hour < 20) {
      return <String>['dinner', 'snack', 'breakfast', 'lunch'];
    }
    // Gece/Yemek sonrası 20-7 arası: ara öğün - kahvaltı - öğle - akşam
    return <String>['snack', 'breakfast', 'lunch', 'dinner'];
  }

  /// Get meal display name - now localization-ready
  static String getMealName(String meal) {
    switch (meal) {
      case 'breakfast':
        return tr('meals.breakfast');
      case 'lunch':
        return tr('meals.lunch');
      case 'dinner':
        return tr('meals.dinner');
      case 'snack':
        return tr('meals.snack');
      default:
        return meal;
    }
  }

  /// Get meal color
  static Color getMealColor(String meal) {
    switch (meal) {
      case 'breakfast':
        return const Color(0xFFFFF4E6); // Açık turuncu/sarı
      case 'lunch':
        return const Color(0xFFE8F5E9); // Açık yeşil
      case 'dinner':
        return const Color(0xFFE3F2FD); // Açık mavi
      case 'snack':
        return const Color(0xFFF3E5F5); // Açık mor
      default:
        return Colors.grey.shade100;
    }
  }

  /// Get meal AppBar color (darker, more vibrant colors for AppBar)
  static Color getMealAppBarColor(String meal) {
    switch (meal) {
      case 'breakfast':
        return const Color(0xFFFF9800); // Turuncu
      case 'lunch':
        return const Color(0xFF4CAF50); // Açık yeşilimsi
      case 'dinner':
        return const Color(0xFF00BCD4); // Turkuaz
      case 'snack':
        return const Color(0xFF9C27B0); // Mor
      default:
        return Colors.grey.shade600;
    }
  }

  /// Get meal icon
  static IconData getMealIcon(String meal) {
    switch (meal) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.restaurant_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_menu;
    }
  }
}

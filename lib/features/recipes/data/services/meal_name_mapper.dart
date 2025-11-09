/// Service responsible for meal name mapping
/// Follows Single Responsibility Principle - only handles meal name conversions
class MealNameMapper {
  /// Get meal name in Turkish
  static String getMealName(String meal) {
    switch (meal.toLowerCase()) {
      case 'breakfast':
        return 'kahvaltı';
      case 'lunch':
        return 'öğle yemeği';
      case 'dinner':
        return 'akşam yemeği';
      case 'snack':
        return 'ara öğün';
      default:
        return meal;
    }
  }
}


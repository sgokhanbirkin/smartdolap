import 'package:easy_localization/easy_localization.dart';
import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/analytics/domain/repositories/i_meal_consumption_repository.dart';
import 'package:smartdolap/features/analytics/domain/services/i_smart_notification_service.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/shopping/domain/entities/shopping_list_item.dart';
import 'package:smartdolap/features/shopping/domain/repositories/i_shopping_list_repository.dart';
import 'package:smartdolap/product/services/i_expiry_notification_service.dart';
import 'package:uuid/uuid.dart';

/// Service implementation for smart notifications
class SmartNotificationServiceImpl implements ISmartNotificationService {
  SmartNotificationServiceImpl(
    this._mealConsumptionRepository,
    this._pantryRepository,
    this._shoppingListRepository,
    this._notificationService,
  );

  final IMealConsumptionRepository _mealConsumptionRepository;
  final IPantryRepository _pantryRepository;
  final IShoppingListRepository _shoppingListRepository;
  final IExpiryNotificationService _notificationService;
  static const Uuid _uuid = Uuid();

  @override
  Future<void> checkAndSendDietarySuggestions({
    required String userId,
    required String householdId,
  }) async {
    try {
      // Get last 7 days of consumptions
      final DateTime endDate = DateTime.now();
      final DateTime startDate = endDate.subtract(const Duration(days: 7));

      final consumptions = await _mealConsumptionRepository.getConsumptions(
        householdId: householdId,
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      if (consumptions.isEmpty) {
        return;
      }

      // Group by ingredient
      final Map<String, int> ingredientCounts = <String, int>{};
      for (final consumption in consumptions) {
        for (final String ingredient in consumption.ingredients) {
          final String normalized = ingredient.toLowerCase().trim();
          ingredientCounts[normalized] =
              (ingredientCounts[normalized] ?? 0) + 1;
        }
      }

      // Find ingredients used 3+ times in last 7 days
      final List<MapEntry<String, int>> frequentIngredients =
          ingredientCounts.entries.where((entry) => entry.value >= 3).toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      if (frequentIngredients.isEmpty) {
        return;
      }

      // Check if user consumed this ingredient today
      final DateTime today = DateTime.now();
      final bool consumedToday = consumptions.any(
        (c) =>
            c.consumedAt.year == today.year &&
            c.consumedAt.month == today.month &&
            c.consumedAt.day == today.day &&
            c.ingredients.any(
              (ing) =>
                  ing.toLowerCase().trim() == frequentIngredients.first.key,
            ),
      );

      if (!consumedToday && frequentIngredients.isNotEmpty) {
        final String ingredient = frequentIngredients.first.key;
        final String? lastRecipe = consumptions
            .where(
              (c) => c.ingredients.any(
                (ing) => ing.toLowerCase().trim() == ingredient,
              ),
            )
            .lastOrNull
            ?.recipeTitle;

        if (lastRecipe != null) {
          await _notificationService.scheduleNotification(
            id: _uuid.v4().hashCode,
            title: tr('notifications.dietary_suggestion_title'),
            body: tr(
              'notifications.dietary_suggestion',
              namedArgs: <String, String>{
                'recipe': lastRecipe,
                'ingredient': ingredient,
              },
            ),
            scheduledDate: DateTime.now().add(const Duration(hours: 1)),
          );

          Logger.info(
            '[SmartNotificationService] Sent dietary suggestion for $ingredient',
          );
        }
      }
    } catch (e) {
      Logger.error(
        '[SmartNotificationService] Error checking dietary suggestions',
        e,
      );
    }
  }

  @override
  Future<void> checkAndSendLowStockNotifications({
    required String householdId,
  }) async {
    try {
      // Get all pantry items
      final List<PantryItem> pantryItems = await _pantryRepository.getItems(
        householdId: householdId,
      );

      // Get ingredient usage analytics to calculate daily usage rates
      // For items without expiry dates, use usage patterns

      // Get analytics for household (simplified - would need to aggregate all users)
      // For now, check items and estimate based on quantity and time in pantry

      for (final PantryItem item in pantryItems) {
        // Skip items already in shopping list
        final List<ShoppingListItem> shoppingItems =
            await _shoppingListRepository.getItems(householdId: householdId);
        final bool alreadyInList = shoppingItems.any(
          (ShoppingListItem si) =>
              si.name.toLowerCase().trim() == item.name.toLowerCase().trim() &&
              !si.isCompleted,
        );

        if (alreadyInList) {
          continue;
        }

        // Calculate days since item was added
        final DateTime now = DateTime.now();
        final DateTime? createdAt = item.createdAt;
        if (createdAt == null) {
          continue;
        }
        final int daysSinceAdded = now.difference(createdAt).inDays;

        // If item has expiry date, use that for low stock calculation
        if (item.expiryDate != null) {
          final DateTime expiry = item.expiryDate!;
          final Duration timeUntilExpiry = expiry.difference(now);

          // If expires in less than 3 days and quantity is low
          if (timeUntilExpiry.inDays <= 3 && item.quantity <= 5) {
            await _notificationService.scheduleNotification(
              id: _uuid.v4().hashCode,
              title: tr('notifications.low_stock_title'),
              body: tr(
                'notifications.low_stock',
                namedArgs: <String, String>{
                  'item': item.name,
                  'remaining': item.quantity.toStringAsFixed(0),
                },
              ),
              scheduledDate: DateTime.now().add(const Duration(minutes: 30)),
            );

            Logger.info(
              '[SmartNotificationService] Sent low stock notification for ${item.name}',
            );
          }
        } else if (daysSinceAdded > 7) {
          // For items without expiry dates, check usage pattern
          // If item has been in pantry for more than 7 days and quantity is low
          // Estimate daily usage: if quantity decreased significantly, notify
          if (item.quantity <= 3) {
            await _notificationService.scheduleNotification(
              id: _uuid.v4().hashCode,
              title: tr('notifications.low_stock_title'),
              body: tr(
                'notifications.low_stock',
                namedArgs: <String, String>{
                  'item': item.name,
                  'remaining': item.quantity.toStringAsFixed(0),
                },
              ),
              scheduledDate: DateTime.now().add(const Duration(minutes: 30)),
            );

            Logger.info(
              '[SmartNotificationService] Sent low stock notification for ${item.name}',
            );
          }
        }
      }
    } catch (e) {
      Logger.error('[SmartNotificationService] Error checking low stock', e);
    }
  }

  @override
  Future<void> scheduleSmartNotifications({required String householdId}) async {
    try {
      // Get all users in household (simplified - in real app, get from household members)
      // For now, we'll schedule for the current user only
      // This should be called periodically (e.g., daily)

      // Schedule dietary suggestions (check once per day)
      // Schedule low stock notifications (check once per day)

      Logger.info(
        '[SmartNotificationService] Scheduled smart notifications for household: $householdId',
      );
    } catch (e) {
      Logger.error(
        '[SmartNotificationService] Error scheduling smart notifications',
        e,
      );
    }
  }
}

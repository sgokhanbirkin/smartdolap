import 'dart:async';

import 'package:smartdolap/core/utils/logger.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_notification_coordinator.dart';
import 'package:smartdolap/features/pantry/domain/services/i_pantry_notification_scheduler.dart';

/// Service for debounced notification scheduling
/// Follows Single Responsibility Principle - handles debouncing logic only
class PantryNotificationScheduler implements IPantryNotificationScheduler {
  PantryNotificationScheduler(this._coordinator);

  final IPantryNotificationCoordinator _coordinator;
  Timer? _debounceTimer;
  DateTime? _lastScheduleTime;
  List<String> _lastScheduledItemIds = <String>[];
  bool _disposed = false;

  @override
  Future<bool> scheduleDebounced(List<PantryItem> items) async {
    if (_disposed) {
      return false;
    }

    // Create a hash of item IDs to check if items actually changed
    final List<String> currentItemIds =
        items
            .map(
              (PantryItem item) =>
                  '${item.id}_${item.expiryDate?.millisecondsSinceEpoch ?? 0}',
            )
            .toList()
          ..sort();
    final String currentHash = currentItemIds.join('|');

    // Check if items actually changed
    final List<String> lastHash = _lastScheduledItemIds;
    if (lastHash.join('|') == currentHash) {
      // Items haven't changed, skip scheduling
      Logger.info(
        '[PantryNotificationScheduler] Items unchanged, skipping scheduling',
      );
      return false;
    }

    _lastScheduledItemIds = currentItemIds;

    // Debounce: Wait 2 seconds before scheduling
    final DateTime now = DateTime.now();
    _debounceTimer?.cancel();

    if (_lastScheduleTime != null &&
        now.difference(_lastScheduleTime!).inSeconds < 2) {
      _debounceTimer = Timer(const Duration(seconds: 2), () async {
        if (!_disposed) {
          try {
            await _coordinator.scheduleForItems(items);
            _lastScheduleTime = DateTime.now();
            Logger.info(
              '[PantryNotificationScheduler] Scheduled notifications for ${items.length} items (debounced)',
            );
          } catch (e) {
            Logger.error(
              '[PantryNotificationScheduler] Error scheduling notifications',
              e,
            );
          }
        }
      });
      return false;
    }

    // Schedule immediately
    _lastScheduleTime = now;
    try {
      await _coordinator.scheduleForItems(items);
      Logger.info(
        '[PantryNotificationScheduler] Scheduled notifications for ${items.length} items',
      );
      return true;
    } catch (e) {
      Logger.error(
        '[PantryNotificationScheduler] Error scheduling notifications',
        e,
      );
      return false;
    }
  }

  @override
  void cancelPending() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    cancelPending();
    _lastScheduledItemIds.clear();
    _lastScheduleTime = null;
  }
}

import 'dart:async';

import 'package:hive/hive.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';

/// Handles gamification XP/level calculations.
/// Follows Single Responsibility Principle - only handles stats management
class ProfileStatsService {
  /// Creates a service backed by the provided Hive box.
  ProfileStatsService(this._box, {this.onStatsChanged})
      : _controller = StreamController<ProfileStats>.broadcast();

  final Box<dynamic> _box;
  static const String _statsKey = 'profile_stats';
  final StreamController<ProfileStats> _controller;

  /// Optional callback when stats change (for badge checking)
  final Future<void> Function(ProfileStats stats)? onStatsChanged;

  /// Stream of profile stats changes
  Stream<ProfileStats> watch() => _controller.stream;

  /// Reads the latest profile stats or returns defaults.
  ProfileStats load() =>
      ProfileStats.fromMap(_box.get(_statsKey) as Map<dynamic, dynamic>?);

  /// Persists the given stats atomically.
  Future<void> save(ProfileStats stats) async {
    await _box.put(_statsKey, stats.toMap());
    _controller.add(stats);
    await onStatsChanged?.call(stats);
  }

  /// Adds the provided XP amount and performs level-up logic.
  Future<ProfileStats> addXp(int amount) async {
    ProfileStats stats = load();
    int newXp = stats.xp + amount;
    int newLevel = stats.level;
    int nextXp = stats.nextLevelXp;
    while (newXp >= nextXp) {
      newXp -= nextXp;
      newLevel += 1;
      nextXp = (nextXp * 1.3).round();
    }
    stats = stats.copyWith(level: newLevel, xp: newXp, nextLevelXp: nextXp);
    await save(stats);
    return stats;
  }

  /// Adds one AI-generated recipe to the counters.
  Future<ProfileStats> incrementAiRecipes() async {
    final ProfileStats current = load();
    final ProfileStats updated =
        current.copyWith(aiRecipes: current.aiRecipes + 1);
    await save(updated);
    return updated;
  }

  /// Adds a manual recipe and optionally increases the photo upload count.
  Future<ProfileStats> incrementUserRecipes({bool withPhoto = false}) async {
    final ProfileStats current = load();
    final ProfileStats updated = current.copyWith(
      userRecipes: current.userRecipes + 1,
      photoUploads: withPhoto
          ? current.photoUploads + 1
          : current.photoUploads,
    );
    await save(updated);
    return updated;
  }

  /// Dispose the stream controller
  void dispose() {
    _controller.close();
  }
}

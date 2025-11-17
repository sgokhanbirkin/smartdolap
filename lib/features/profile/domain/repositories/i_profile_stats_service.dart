import 'dart:async';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';

/// Interface for managing profile statistics
/// Follows Dependency Inversion Principle (DIP)
abstract class IProfileStatsService {
  /// Stream of profile stats changes
  Stream<ProfileStats> watch();

  /// Reads the latest profile stats or returns defaults.
  ProfileStats load();

  /// Persists the given stats atomically.
  Future<void> save(ProfileStats stats);

  /// Adds the provided XP amount and performs level-up logic.
  Future<ProfileStats> addXp(int amount);

  /// Adds one AI-generated recipe to the counters.
  Future<ProfileStats> incrementAiRecipes();

  /// Adds a manual recipe and optionally increases the photo upload count.
  Future<ProfileStats> incrementUserRecipes({bool withPhoto = false});

  /// Dispose the stream controller
  void dispose();
}

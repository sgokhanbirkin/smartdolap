import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/profile/data/profile_stats_service.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';

void main() {
  group('ProfileStatsService', () {
    late Box<dynamic> testBox;
    late ProfileStatsService service;

    setUpAll(() async {
      Hive.init('test/hive_test');
    });

    setUp(() async {
      // Clean up any existing boxes
      if (Hive.isBoxOpen('profile_stats_box')) {
        await Hive.box<dynamic>('profile_stats_box').close();
      }
      testBox = await Hive.openBox<dynamic>('profile_stats_box');
      service = ProfileStatsService(testBox);
    });

    tearDown(() async {
      // Clean up box after each test
      if (Hive.isBoxOpen('profile_stats_box')) {
        await testBox.deleteFromDisk();
      }
    });

    test('should load default stats when box is empty', () {
      // Act
      final ProfileStats stats = service.load();

      // Assert
      expect(stats.level, equals(1));
      expect(stats.xp, equals(0));
      expect(stats.nextLevelXp, equals(200));
      expect(stats.aiRecipes, equals(0));
      expect(stats.userRecipes, equals(0));
      expect(stats.photoUploads, equals(0));
      expect(stats.badges, isEmpty);
    });

    test('should save and load stats correctly', () async {
      // Arrange
      const ProfileStats testStats = ProfileStats(
        level: 5,
        xp: 150,
        nextLevelXp: 300,
        aiRecipes: 10,
        userRecipes: 5,
        photoUploads: 3,
        badges: <String>['badge1', 'badge2'],
      );

      // Act
      await service.save(testStats);
      final ProfileStats loaded = service.load();

      // Assert
      expect(loaded.level, equals(5));
      expect(loaded.xp, equals(150));
      expect(loaded.nextLevelXp, equals(300));
      expect(loaded.aiRecipes, equals(10));
      expect(loaded.userRecipes, equals(5));
      expect(loaded.photoUploads, equals(3));
      expect(loaded.badges.length, equals(2));
      expect(loaded.badges, contains('badge1'));
      expect(loaded.badges, contains('badge2'));
    });

    test('should add XP correctly without leveling up', () async {
      // Arrange
      const ProfileStats initialStats = ProfileStats(xp: 50);
      await service.save(initialStats);

      // Act
      final ProfileStats updated = await service.addXp(100);

      // Assert
      expect(updated.level, equals(1));
      expect(updated.xp, equals(150));
      expect(updated.nextLevelXp, equals(200));
    });

    test('should level up when XP threshold is reached', () async {
      // Arrange
      const ProfileStats initialStats = ProfileStats(xp: 150);
      await service.save(initialStats);

      // Act
      final ProfileStats updated = await service.addXp(100);

      // Assert
      expect(updated.level, equals(2));
      expect(updated.xp, equals(50)); // 150 + 100 - 200 = 50
      expect(updated.nextLevelXp, greaterThan(200)); // nextLevelXp * 1.3
    });

    test('should handle multiple level ups', () async {
      // Arrange
      const ProfileStats initialStats = ProfileStats();
      await service.save(initialStats);

      // Act - Add enough XP for 2 level ups
      final ProfileStats updated = await service.addXp(500);

      // Assert
      expect(updated.level, greaterThan(2));
      expect(updated.xp, lessThan(500));
    });

    test('should increment AI recipes correctly', () async {
      // Arrange
      const ProfileStats initialStats = ProfileStats(aiRecipes: 5);
      await service.save(initialStats);

      // Act
      final ProfileStats updated = await service.incrementAiRecipes();

      // Assert
      expect(updated.aiRecipes, equals(6));
    });

    test('should increment user recipes without photo', () async {
      // Arrange
      const ProfileStats initialStats = ProfileStats(
        userRecipes: 3,
        photoUploads: 2,
      );
      await service.save(initialStats);

      // Act
      final ProfileStats updated = await service.incrementUserRecipes();

      // Assert
      expect(updated.userRecipes, equals(4));
      expect(updated.photoUploads, equals(2)); // Unchanged
    });

    test('should increment user recipes with photo', () async {
      // Arrange
      const ProfileStats initialStats = ProfileStats(
        userRecipes: 3,
        photoUploads: 2,
      );
      await service.save(initialStats);

      // Act
      final ProfileStats updated = await service.incrementUserRecipes(
        withPhoto: true,
      );

      // Assert
      expect(updated.userRecipes, equals(4));
      expect(updated.photoUploads, equals(3)); // Incremented
    });
  });
}

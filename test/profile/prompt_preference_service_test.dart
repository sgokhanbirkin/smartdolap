import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';

void main() {
  group('PromptPreferenceService', () {
    late Box<dynamic> testBox;
    late PromptPreferenceService service;

    setUpAll(() async {
      Hive.init('test/hive_test');
    });

    setUp(() async {
      // Clean up any existing boxes
      if (Hive.isBoxOpen('profile_box')) {
        await Hive.box<dynamic>('profile_box').close();
      }
      testBox = await Hive.openBox<dynamic>('profile_box');
      service = PromptPreferenceService(testBox);
    });

    tearDown(() async {
      // Clean up box after each test
      if (Hive.isBoxOpen('profile_box')) {
        await testBox.deleteFromDisk();
      }
    });

    test('should load default preferences when box is empty', () {
      // Act
      final PromptPreferences prefs = service.getPreferences();

      // Assert
      expect(prefs.servings, equals(2));
      expect(prefs.dietStyle, equals('dengeli'));
      expect(prefs.cuisineFocus, equals('Akdeniz'));
      expect(prefs.tone, equals('enerjik'));
      expect(prefs.goal, equals('pratik'));
      expect(prefs.recipesGenerated, equals(0));
    });

    test('should save and load preferences correctly', () async {
      // Arrange
      const PromptPreferences testPrefs = PromptPreferences(
        servings: 4,
        dietStyle: 'vegan',
        cuisineFocus: 'Asya',
        tone: 'sakin',
        goal: 'sağlıklı',
        recipesGenerated: 10,
      );

      // Act
      await service.savePreferences(testPrefs);
      final PromptPreferences loaded = service.getPreferences();

      // Assert
      expect(loaded.servings, equals(4));
      expect(loaded.dietStyle, equals('vegan'));
      expect(loaded.cuisineFocus, equals('Asya'));
      expect(loaded.tone, equals('sakin'));
      expect(loaded.goal, equals('sağlıklı'));
      expect(loaded.recipesGenerated, equals(10));
    });

    test('should increment generated recipes count', () async {
      // Arrange
      const PromptPreferences initialPrefs = PromptPreferences(
        recipesGenerated: 5,
      );
      await service.savePreferences(initialPrefs);

      // Act
      await service.incrementGenerated(3);
      final PromptPreferences updated = service.getPreferences();

      // Assert
      expect(updated.recipesGenerated, equals(8));
    });

    test('should increment generated recipes from zero', () async {
      // Arrange - Start with defaults
      final PromptPreferences initialPrefs = service.getPreferences();
      expect(initialPrefs.recipesGenerated, equals(0));

      // Act
      await service.incrementGenerated(6);
      final PromptPreferences updated = service.getPreferences();

      // Assert
      expect(updated.recipesGenerated, equals(6));
    });

    test('should preserve other preferences when incrementing', () async {
      // Arrange
      const PromptPreferences initialPrefs = PromptPreferences(
        servings: 3,
        dietStyle: 'keto',
        recipesGenerated: 2,
      );
      await service.savePreferences(initialPrefs);

      // Act
      await service.incrementGenerated(5);
      final PromptPreferences updated = service.getPreferences();

      // Assert
      expect(updated.recipesGenerated, equals(7));
      expect(updated.servings, equals(3)); // Preserved
      expect(updated.dietStyle, equals('keto')); // Preserved
    });
  });
}

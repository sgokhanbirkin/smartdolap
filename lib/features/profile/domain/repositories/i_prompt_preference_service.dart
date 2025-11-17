import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';

/// Interface for managing prompt preferences
/// Follows Dependency Inversion Principle (DIP)
abstract class IPromptPreferenceService {
  /// Returns the cached preferences or a default instance.
  PromptPreferences getPreferences();

  /// Persists personalization preferences.
  Future<void> savePreferences(PromptPreferences prefs);

  /// Increments the generated recipe counter.
  Future<void> incrementGenerated(int added);
}

import 'package:hive/hive.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/repositories/i_prompt_preference_service.dart';

/// Persists and reads personalization preferences.
class PromptPreferenceService implements IPromptPreferenceService {
  /// Creates a service backed by the provided Hive box.
  PromptPreferenceService(this._box);

  final Box<dynamic> _box;
  static const String _prefKey = 'prompt_preferences';

  /// Returns the cached preferences or a default instance.
  @override
  PromptPreferences getPreferences() {
    final Map<dynamic, dynamic>? raw =
        _box.get(_prefKey) as Map<dynamic, dynamic>?;
    return PromptPreferences.fromMap(raw);
  }

  /// Persists personalization preferences.
  @override
  Future<void> savePreferences(PromptPreferences prefs) async {
    await _box.put(_prefKey, prefs.toMap());
  }

  /// Increments the generated recipe counter.
  @override
  Future<void> incrementGenerated(int added) async {
    final PromptPreferences prefs = getPreferences();
    await savePreferences(
      prefs.copyWith(recipesGenerated: prefs.recipesGenerated + added),
    );
  }
}

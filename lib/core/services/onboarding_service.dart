import 'package:hive/hive.dart';

/// Service to manage onboarding state
class OnboardingService {
  /// Creates an onboarding service
  OnboardingService(this._box);

  final Box<dynamic> _box;
  static const String _onboardingKey = 'onboarding_completed';

  /// Checks if onboarding has been completed
  bool isOnboardingCompleted() =>
      _box.get(_onboardingKey, defaultValue: false) as bool;

  /// Marks onboarding as completed
  Future<void> completeOnboarding() async {
    await _box.put(_onboardingKey, true);
  }

  /// Resets onboarding (for testing purposes)
  Future<void> resetOnboarding() async {
    await _box.put(_onboardingKey, false);
  }
}

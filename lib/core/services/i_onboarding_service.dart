/// Interface for managing onboarding state
/// Follows Dependency Inversion Principle (DIP)
abstract class IOnboardingService {
  /// Checks if onboarding has been completed
  bool isOnboardingCompleted();

  /// Marks onboarding as completed
  Future<void> completeOnboarding();

  /// Resets onboarding (for testing purposes)
  Future<void> resetOnboarding();
}

/// Interface for managing household setup skip state
/// Follows Dependency Inversion Principle (DIP)
abstract class IHouseholdSetupService {
  /// Checks if household setup has been skipped
  bool isHouseholdSetupSkipped();

  /// Marks household setup as skipped
  Future<void> skipHouseholdSetup();

  /// Resets household setup skip (for testing purposes)
  Future<void> resetHouseholdSetupSkip();
}


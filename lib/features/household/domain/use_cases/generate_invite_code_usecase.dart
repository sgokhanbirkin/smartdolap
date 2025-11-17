import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';

/// Generate invite code use case - Business logic for generating invite code
class GenerateInviteCodeUseCase {
  /// Generate invite code use case constructor
  const GenerateInviteCodeUseCase(this.repository);

  /// Household repository
  final IHouseholdRepository repository;

  /// Execute generating invite code
  Future<String> call(String householdId) =>
      repository.generateInviteCode(householdId);
}


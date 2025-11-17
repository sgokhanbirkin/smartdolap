import 'package:smartdolap/features/household/domain/entities/household.dart';
import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';

/// Get household use case - Business logic for getting a household
class GetHouseholdUseCase {
  /// Get household use case constructor
  const GetHouseholdUseCase(this.repository);

  /// Household repository
  final IHouseholdRepository repository;

  /// Execute getting household
  Future<Household?> call(String householdId) =>
      repository.getHousehold(householdId);
}


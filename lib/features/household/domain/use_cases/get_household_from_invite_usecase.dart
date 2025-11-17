import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';

/// Get household from invite code use case
class GetHouseholdFromInviteUseCase {
  /// Get household from invite code use case constructor
  const GetHouseholdFromInviteUseCase(this.repository);

  /// Household repository
  final IHouseholdRepository repository;

  /// Execute getting household ID from invite code
  Future<String?> call(String inviteCode) =>
      repository.getHouseholdIdFromInviteCode(inviteCode);
}


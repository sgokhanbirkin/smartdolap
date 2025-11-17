import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';

/// Join household use case - Business logic for joining a household
class JoinHouseholdUseCase {
  /// Join household use case constructor
  const JoinHouseholdUseCase(this.repository);

  /// Household repository
  final IHouseholdRepository repository;

  /// Execute joining household
  Future<void> call({
    required String householdId,
    required String userId,
    required String userName,
    String? avatarId,
  }) =>
      repository.joinHousehold(
        householdId: householdId,
        userId: userId,
        userName: userName,
        avatarId: avatarId,
      );
}


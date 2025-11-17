import 'package:smartdolap/features/household/domain/entities/household.dart';
import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';

/// Create household use case - Business logic for creating a household
class CreateHouseholdUseCase {
  /// Create household use case constructor
  const CreateHouseholdUseCase(this.repository);

  /// Household repository
  final IHouseholdRepository repository;

  /// Execute household creation
  Future<Household> call({
    required String name,
    required String ownerId,
    required String ownerName,
    String? ownerAvatarId,
  }) =>
      repository.createHousehold(
        name: name,
        ownerId: ownerId,
        ownerName: ownerName,
        ownerAvatarId: ownerAvatarId,
      );
}


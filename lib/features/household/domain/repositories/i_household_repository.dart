import 'package:smartdolap/features/household/domain/entities/household.dart';

/// Household repository contract
abstract class IHouseholdRepository {
  /// Create a new household
  Future<Household> createHousehold({
    required String name,
    required String ownerId,
    required String ownerName,
    String? ownerAvatarId,
  });

  /// Get household by ID
  Future<Household?> getHousehold(String householdId);

  /// Watch household changes
  Stream<Household?> watchHousehold(String householdId);

  /// Join household with invite code
  Future<void> joinHousehold({
    required String householdId,
    required String userId,
    required String userName,
    String? avatarId,
  });

  /// Leave household
  Future<void> leaveHousehold({
    required String householdId,
    required String userId,
  });

  /// Update user's household ID in users collection
  Future<void> updateUserHouseholdId({
    required String userId,
    String? householdId,
  });

  /// Generate invite code for household
  Future<String> generateInviteCode(String householdId);

  /// Get household ID from invite code
  Future<String?> getHouseholdIdFromInviteCode(String inviteCode);
}


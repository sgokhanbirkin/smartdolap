import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/household/domain/entities/household.dart';
import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';
import 'package:uuid/uuid.dart';

/// Household repository implementation
class HouseholdRepositoryImpl implements IHouseholdRepository {
  /// Household repository constructor
  HouseholdRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _households = 'households';
  static const String _users = 'users';
  static const String _inviteCodes = 'inviteCodes';
  static const Uuid _uuid = Uuid();

  @override
  Future<Household> createHousehold({
    required String name,
    required String ownerId,
    required String ownerName,
    String? ownerAvatarId,
  }) async {
    final String householdId = _uuid.v4();
    final DateTime now = DateTime.now();

    // Create household document
    final Household household = Household(
      id: householdId,
      name: name,
      ownerId: ownerId,
      createdAt: now,
      members: <HouseholdMember>[
        HouseholdMember(
          userId: ownerId,
          userName: ownerName,
          avatarId: ownerAvatarId,
          role: 'owner',
          joinedAt: now,
        ),
      ],
    );

    // Write household to Firestore
    await _firestore
        .collection(_households)
        .doc(householdId)
        .set(<String, dynamic>{
          'id': householdId,
          'name': name,
          'ownerId': ownerId,
          'createdAt': now.toIso8601String(),
        });

    // Add owner as member
    await _firestore
        .collection(_households)
        .doc(householdId)
        .collection('members')
        .doc(ownerId)
        .set(<String, dynamic>{
          'userId': ownerId,
          'userName': ownerName,
          'avatarId': ownerAvatarId,
          'role': 'owner',
          'joinedAt': now.toIso8601String(),
        });

    // Update user's householdId
    await updateUserHouseholdId(userId: ownerId, householdId: householdId);

    return household;
  }

  @override
  Future<Household?> getHousehold(String householdId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> householdDoc =
          await _firestore.collection(_households).doc(householdId).get();

      if (!householdDoc.exists) {
        return null;
      }

      final Map<String, dynamic> householdData = householdDoc.data()!;

      // Get members
      final QuerySnapshot<Map<String, dynamic>> membersSnapshot =
          await _firestore
              .collection(_households)
              .doc(householdId)
              .collection('members')
              .get();

      final List<HouseholdMember> members = membersSnapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                HouseholdMember.fromJson(doc.data()),
          )
          .toList();

      return Household(
        id: householdData['id'] as String,
        name: householdData['name'] as String,
        ownerId: householdData['ownerId'] as String,
        createdAt: householdData['createdAt'] != null
            ? DateTime.tryParse(householdData['createdAt'] as String) ??
                  DateTime.now()
            : DateTime.now(),
        members: members,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<Household?> watchHousehold(String householdId) => _firestore
      .collection(_households)
      .doc(householdId)
      .snapshots()
      .asyncMap((DocumentSnapshot<Map<String, dynamic>> snapshot) async {
        if (!snapshot.exists) {
          return null;
        }

        final Map<String, dynamic> householdData = snapshot.data()!;

        // Get members
        final QuerySnapshot<Map<String, dynamic>> membersSnapshot =
            await _firestore
                .collection(_households)
                .doc(householdId)
                .collection('members')
                .get();

        final List<HouseholdMember> members = membersSnapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  HouseholdMember.fromJson(doc.data()),
            )
            .toList();

        return Household(
          id: householdData['id'] as String,
          name: householdData['name'] as String,
          ownerId: householdData['ownerId'] as String,
          createdAt: householdData['createdAt'] != null
              ? DateTime.tryParse(householdData['createdAt'] as String) ??
                    DateTime.now()
              : DateTime.now(),
          members: members,
        );
      });

  @override
  Future<void> joinHousehold({
    required String householdId,
    required String userId,
    required String userName,
    String? avatarId,
  }) async {
    final DateTime now = DateTime.now();

    // Add user as member
    await _firestore
        .collection(_households)
        .doc(householdId)
        .collection('members')
        .doc(userId)
        .set(<String, dynamic>{
          'userId': userId,
          'userName': userName,
          'avatarId': avatarId,
          'role': 'member',
          'joinedAt': now.toIso8601String(),
        });

    // Update user's householdId
    await updateUserHouseholdId(userId: userId, householdId: householdId);
  }

  @override
  Future<void> leaveHousehold({
    required String householdId,
    required String userId,
  }) async {
    // Remove user from members
    await _firestore
        .collection(_households)
        .doc(householdId)
        .collection('members')
        .doc(userId)
        .delete();

    // Update user's householdId to null
    await updateUserHouseholdId(userId: userId);
  }

  @override
  Future<void> updateUserHouseholdId({
    required String userId,
    String? householdId,
  }) async {
    await _firestore.collection(_users).doc(userId).set(<String, dynamic>{
      'householdId': householdId,
    }, SetOptions(merge: true));
  }

  @override
  Future<String> generateInviteCode(String householdId) async {
    // Generate a short invite code (6 characters)
    final String inviteCode = _generateShortCode();
    final DateTime expiresAt = DateTime.now().add(const Duration(days: 7));

    // Store invite code
    await _firestore
        .collection(_inviteCodes)
        .doc(inviteCode)
        .set(<String, dynamic>{
          'householdId': householdId,
          'createdAt': DateTime.now().toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        });

    return inviteCode;
  }

  @override
  Future<String?> getHouseholdIdFromInviteCode(String inviteCode) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> inviteDoc = await _firestore
          .collection(_inviteCodes)
          .doc(inviteCode)
          .get();

      if (!inviteDoc.exists) {
        return null;
      }

      final Map<String, dynamic> data = inviteDoc.data()!;

      // Check expiration
      final DateTime? expiresAt = data['expiresAt'] != null
          ? DateTime.tryParse(data['expiresAt'] as String)
          : null;

      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        // Code expired, delete it
        await _firestore.collection(_inviteCodes).doc(inviteCode).delete();
        return null;
      }

      return data['householdId'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Generate a short 6-character code
  String _generateShortCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      buffer.write(
        chars[(DateTime.now().millisecondsSinceEpoch + i) % chars.length],
      );
    }
    return buffer.toString();
  }
}

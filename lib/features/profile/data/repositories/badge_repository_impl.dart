import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/profile/data/badge_definitions.dart';
import 'package:smartdolap/features/profile/domain/entities/badge.dart';

/// Repository interface for badge operations
abstract class IBadgeRepository {
  /// Saves a badge unlock to Firestore
  Future<void> saveBadge(String userId, Badge badge);

  /// Loads all unlocked badges for a user
  Future<List<Badge>> loadBadges(String userId);
}

/// Firestore implementation of badge repository
class BadgeRepositoryImpl implements IBadgeRepository {
  /// Creates a badge repository with Firestore
  BadgeRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> saveBadge(String userId, Badge badge) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(badge.id)
        .set(badge.toMap());
  }

  @override
  Future<List<Badge>> loadBadges(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      final Badge? definition = BadgeDefinitions.getBadgeById(data['id'] as String);
      if (definition == null) {
        return Badge.fromMap(data);
      }
      // Merge definition with unlockedAt from Firestore
      return definition.copyWith(
        unlockedAt: data['unlockedAt'] != null
            ? DateTime.parse(data['unlockedAt'] as String)
            : null,
      );
    }).toList();
  }
}


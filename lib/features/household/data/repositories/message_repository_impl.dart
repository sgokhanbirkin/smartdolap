import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartdolap/features/household/domain/entities/household_message.dart';
import 'package:smartdolap/features/household/domain/repositories/i_message_repository.dart';
import 'package:uuid/uuid.dart';

/// Message repository implementation
class MessageRepositoryImpl implements IMessageRepository {
  /// Message repository constructor
  MessageRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;
  static const String _households = 'households';
  static const String _messages = 'messages';
  static const Uuid _uuid = Uuid();

  @override
  Stream<List<HouseholdMessage>> watchMessages(String householdId) => _firestore
        .collection(_households)
        .doc(householdId)
        .collection(_messages)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  HouseholdMessage.fromJson(doc.data()),
            )
            .toList(),
    );

  @override
  Future<HouseholdMessage> sendMessage({
    required String householdId,
    required String userId,
    required String userName,
    String? recipeId,
    String? text,
    String? avatarId,
  }) async {
    final String messageId = _uuid.v4();
    final DateTime now = DateTime.now();

    final HouseholdMessage message = HouseholdMessage(
      id: messageId,
      householdId: householdId,
      userId: userId,
      userName: userName,
      avatarId: avatarId,
      text: text,
      recipeId: recipeId,
      createdAt: now,
    );

    await _firestore
        .collection(_households)
        .doc(householdId)
        .collection(_messages)
        .doc(messageId)
        .set(message.toJson());

    return message;
  }

  @override
  Future<void> deleteMessage({
    required String householdId,
    required String messageId,
  }) async {
    await _firestore
        .collection(_households)
        .doc(householdId)
        .collection(_messages)
        .doc(messageId)
        .delete();
  }
}


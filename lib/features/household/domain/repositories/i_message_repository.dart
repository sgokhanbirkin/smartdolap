import 'package:smartdolap/features/household/domain/entities/household_message.dart';

/// Message repository contract (for general messaging and recipe sharing)
abstract class IMessageRepository {
  /// Watch messages for a household
  Stream<List<HouseholdMessage>> watchMessages(String householdId);

  /// Send a message (general message or recipe share)
  Future<HouseholdMessage> sendMessage({
    required String householdId,
    required String userId,
    required String userName,
    String? recipeId,
    String? text,
    String? avatarId,
  });

  /// Delete a message
  Future<void> deleteMessage({
    required String householdId,
    required String messageId,
  });
}


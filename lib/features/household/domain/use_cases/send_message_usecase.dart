import 'package:smartdolap/features/household/domain/entities/household_message.dart';
import 'package:smartdolap/features/household/domain/repositories/i_message_repository.dart';

/// Send message use case - Business logic for sending a message (general or recipe share)
class SendMessageUseCase {
  /// Send message use case constructor
  const SendMessageUseCase(this.repository);

  /// Message repository
  final IMessageRepository repository;

  /// Execute sending message
  Future<HouseholdMessage> call({
    required String householdId,
    required String userId,
    required String userName,
    String? recipeId,
    String? text,
    String? avatarId,
  }) =>
      repository.sendMessage(
        householdId: householdId,
        userId: userId,
        userName: userName,
        recipeId: recipeId,
        text: text,
        avatarId: avatarId,
      );
}


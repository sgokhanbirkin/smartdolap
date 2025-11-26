import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/household/domain/entities/household_message.dart';
import 'package:smartdolap/features/household/domain/entities/shared_recipe.dart';
import 'package:smartdolap/features/household/domain/repositories/i_message_repository.dart';
import 'package:smartdolap/features/household/domain/repositories/i_shared_recipe_repository.dart';
import 'package:smartdolap/features/household/domain/use_cases/send_message_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/share_recipe_usecase.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/share_state.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';

/// Share cubit - Manages recipe sharing and messaging state
class ShareCubit extends Cubit<ShareState> {
  /// Share cubit constructor
  ShareCubit({
    required this.messageRepository,
    required this.sharedRecipeRepository,
    required this.sendMessageUseCase,
    required this.shareRecipeUseCase,
  }) : super(const ShareState.initial());

  final IMessageRepository messageRepository;
  final ISharedRecipeRepository sharedRecipeRepository;
  final SendMessageUseCase sendMessageUseCase;
  final ShareRecipeUseCase shareRecipeUseCase;

  StreamSubscription<List<HouseholdMessage>>? _messagesSubscription;
  StreamSubscription<List<SharedRecipe>>? _recipesSubscription;

  /// Watch messages and shared recipes for a household
  void watchShare(String householdId) {
    emit(const ShareState.loading());

    _messagesSubscription?.cancel();
    _recipesSubscription?.cancel();

    // Watch messages
    _messagesSubscription = messageRepository
        .watchMessages(householdId)
        .listen((List<HouseholdMessage> messages) {
      state.maybeWhen(
        loaded: (List<HouseholdMessage> currentMessages, List<SharedRecipe> currentRecipes) {
          emit(ShareState.loaded(
            messages: messages,
            sharedRecipes: currentRecipes,
          ));
        },
        orElse: () {
          // Initial load - wait for recipes too
        },
      );
    }, onError: (Object error) {
      emit(ShareState.error(error.toString()));
    });

    // Watch shared recipes
    _recipesSubscription = sharedRecipeRepository
        .watchSharedRecipes(householdId)
        .listen((List<SharedRecipe> recipes) {
      state.maybeWhen(
        loaded: (List<HouseholdMessage> currentMessages, List<SharedRecipe> currentRecipes) {
          emit(ShareState.loaded(
            messages: currentMessages,
            sharedRecipes: recipes,
          ));
        },
        orElse: () {
          // Initial load - wait for messages too
        },
      );
    }, onError: (Object error) {
      emit(ShareState.error(error.toString()));
    });

    // Combine initial load
    _loadInitial(householdId);
  }

  Future<void> _loadInitial(String householdId) async {
    try {
      // Get initial messages and recipes
      final List<HouseholdMessage> messages = <HouseholdMessage>[];
      final List<SharedRecipe> recipes = <SharedRecipe>[];

      // Listen to streams and wait for first emission
      final Completer<void> messagesCompleter = Completer<void>();
      final Completer<void> recipesCompleter = Completer<void>();

      messageRepository.watchMessages(householdId).listen(
        (List<HouseholdMessage> msgs) {
          messages.addAll(msgs);
          if (!messagesCompleter.isCompleted) {
            messagesCompleter.complete();
          }
        },
      );

      sharedRecipeRepository.watchSharedRecipes(householdId).listen(
        (List<SharedRecipe> recs) {
          recipes.addAll(recs);
          if (!recipesCompleter.isCompleted) {
            recipesCompleter.complete();
          }
        },
      );

      // Wait a bit for initial data
      await Future.wait(<Future<void>>[
        messagesCompleter.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        ),
        recipesCompleter.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () {},
        ),
      ]);

      emit(ShareState.loaded(messages: messages, sharedRecipes: recipes));
    } catch (e) {
      emit(ShareState.error(e.toString()));
    }
  }

  /// Share a recipe with optional message
  Future<void> shareRecipe({
    required String householdId,
    required String userId,
    required String userName,
    required UserRecipe recipe,
    String? text,
    String? avatarId,
  }) async {
    try {
      // Share recipe
      await shareRecipeUseCase.call(
        householdId: householdId,
        userId: userId,
        userName: userName,
        recipe: recipe,
        avatarId: avatarId,
      );

      // Send message if text provided
      if (text != null && text.isNotEmpty) {
        await sendMessageUseCase.call(
          householdId: householdId,
          userId: userId,
          userName: userName,
          recipeId: recipe.id,
          text: text,
          avatarId: avatarId,
        );
      }
    } catch (e) {
      emit(ShareState.error(e.toString()));
    }
  }

  /// Send a message (general message or recipe share)
  Future<void> sendMessage({
    required String householdId,
    required String userId,
    required String userName,
    String? recipeId,
    String? text,
    String? avatarId,
  }) async {
    try {
      await sendMessageUseCase.call(
        householdId: householdId,
        userId: userId,
        userName: userName,
        recipeId: recipeId,
        text: text,
        avatarId: avatarId,
      );
    } catch (e) {
      emit(ShareState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _recipesSubscription?.cancel();
    return super.close();
  }
}


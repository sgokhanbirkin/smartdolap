import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartdolap/features/household/domain/entities/household.dart';
import 'package:smartdolap/features/household/domain/repositories/i_household_repository.dart';
import 'package:smartdolap/features/household/domain/use_cases/create_household_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/generate_invite_code_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/get_household_from_invite_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/get_household_usecase.dart';
import 'package:smartdolap/features/household/domain/use_cases/join_household_usecase.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/household_state.dart';

/// Household cubit - Manages household state and operations
class HouseholdCubit extends Cubit<HouseholdState> {
  /// Household cubit constructor
  HouseholdCubit({
    required this.createHouseholdUseCase,
    required this.getHouseholdUseCase,
    required this.joinHouseholdUseCase,
    required this.generateInviteCodeUseCase,
    required this.getHouseholdFromInviteUseCase,
    required this.repository,
  }) : super(const HouseholdState.initial());

  final CreateHouseholdUseCase createHouseholdUseCase;
  final GetHouseholdUseCase getHouseholdUseCase;
  final JoinHouseholdUseCase joinHouseholdUseCase;
  final GenerateInviteCodeUseCase generateInviteCodeUseCase;
  final GetHouseholdFromInviteUseCase getHouseholdFromInviteUseCase;
  final IHouseholdRepository repository;

  StreamSubscription<Household?>? _householdSubscription;

  /// Watch household changes
  void watchHousehold(String householdId) {
    emit(const HouseholdState.loading());
    _householdSubscription?.cancel();
    _householdSubscription = repository.watchHousehold(householdId).listen(
      (Household? household) {
        if (household != null) {
          emit(HouseholdState.loaded(household));
        } else {
          emit(const HouseholdState.noHousehold());
        }
      },
      onError: (Object error) {
        emit(HouseholdState.error(error.toString()));
      },
    );
  }

  /// Create a new household
  Future<void> createHousehold({
    required String name,
    required String ownerId,
    required String ownerName,
    String? ownerAvatarId,
  }) async {
    emit(const HouseholdState.loading());
    try {
      final Household household = await createHouseholdUseCase.call(
        name: name,
        ownerId: ownerId,
        ownerName: ownerName,
        ownerAvatarId: ownerAvatarId,
      );
      emit(HouseholdState.loaded(household));
    } catch (e) {
      emit(HouseholdState.error(e.toString()));
    }
  }

  /// Join household with invite code
  Future<void> joinHouseholdWithCode({
    required String inviteCode,
    required String userId,
    required String userName,
    String? avatarId,
  }) async {
    emit(const HouseholdState.loading());
    try {
      final String? householdId =
          await getHouseholdFromInviteUseCase.call(inviteCode);
      if (householdId == null) {
        emit(const HouseholdState.error('Invalid invite code'));
        return;
      }

      await joinHouseholdUseCase.call(
        householdId: householdId,
        userId: userId,
        userName: userName,
        avatarId: avatarId,
      );

      // Load household after joining
      final Household? household = await getHouseholdUseCase.call(householdId);
      if (household != null) {
        emit(HouseholdState.loaded(household));
      } else {
        emit(const HouseholdState.error('Failed to load household'));
      }
    } catch (e) {
      emit(HouseholdState.error(e.toString()));
    }
  }

  /// Generate invite code
  Future<String?> generateInviteCode(String householdId) async {
    try {
      return await generateInviteCodeUseCase.call(householdId);
    } catch (e) {
      emit(HouseholdState.error(e.toString()));
      return null;
    }
  }

  /// Get household by ID
  Future<void> loadHousehold(String householdId) async {
    emit(const HouseholdState.loading());
    try {
      final Household? household = await getHouseholdUseCase.call(householdId);
      if (household != null) {
        emit(HouseholdState.loaded(household));
      } else {
        emit(const HouseholdState.noHousehold());
      }
    } catch (e) {
      emit(HouseholdState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _householdSubscription?.cancel();
    return super.close();
  }
}


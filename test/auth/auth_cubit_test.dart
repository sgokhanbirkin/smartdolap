import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/logout_usecase.dart';
import 'package:smartdolap/features/auth/domain/use_cases/register_usecase.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';

/// Mock IAuthRepository
class MockAuthRepository extends Mock implements IAuthRepository {}

/// Mock LoginUseCase
class MockLoginUseCase extends Mock implements LoginUseCase {}

/// Mock LogoutUseCase
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

/// Mock RegisterUseCase
class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  group('AuthCubit', () {
    late MockAuthRepository mockRepository;
    late MockLoginUseCase mockLoginUseCase;
    late MockLogoutUseCase mockLogoutUseCase;
    late MockRegisterUseCase mockRegisterUseCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      mockLoginUseCase = MockLoginUseCase();
      mockLogoutUseCase = MockLogoutUseCase();
      mockRegisterUseCase = MockRegisterUseCase();
    });

    blocTest<AuthCubit, AuthState>(
      'should emit [loading, authenticated] when login is successful',
      setUp: () {
        const User testUser = User(
          id: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => null);

        when(
          () => mockRepository.currentUserStream,
        ).thenAnswer((_) => const Stream<User?>.empty());

        when(
          () => mockLoginUseCase(
            email: 'test@example.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => testUser);
      },
      build: () => AuthCubit(
        loginUseCase: mockLoginUseCase,
        logoutUseCase: mockLogoutUseCase,
        registerUseCase: mockRegisterUseCase,
        repository: mockRepository,
      ),
      act: (AuthCubit cubit) =>
          cubit.login(email: 'test@example.com', password: 'password123'),
      expect: () => const <AuthState>[
        AuthState.loading(),
        AuthState.unauthenticated(),
        AuthState.authenticated(
          User(
            id: 'test-uid',
            email: 'test@example.com',
            displayName: 'Test User',
          ),
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'should emit [loading, error] when login fails',
      setUp: () {
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => null);

        when(
          () => mockRepository.currentUserStream,
        ).thenAnswer((_) => const Stream<User?>.empty());

        when(
          () => mockLoginUseCase(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
        ).thenThrow(const AuthFailure.invalidCredentials());
      },
      build: () => AuthCubit(
        loginUseCase: mockLoginUseCase,
        logoutUseCase: mockLogoutUseCase,
        registerUseCase: mockRegisterUseCase,
        repository: mockRepository,
      ),
      act: (AuthCubit cubit) =>
          cubit.login(email: 'test@example.com', password: 'wrongpassword'),
      expect: () => const <AuthState>[
        AuthState.loading(),
        AuthState.error(AuthFailure.invalidCredentials()),
        AuthState.unauthenticated(),
      ],
    );

    test('initial state should be AuthState.initial()', () {
      // Arrange
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);

      when(
        () => mockRepository.currentUserStream,
      ).thenAnswer((_) => const Stream<User?>.empty());

      // Act
      final AuthCubit cubit = AuthCubit(
        loginUseCase: mockLoginUseCase,
        logoutUseCase: mockLogoutUseCase,
        registerUseCase: mockRegisterUseCase,
        repository: mockRepository,
      );

      // Assert
      expect(cubit.state, const AuthState.initial());
    });
  });
}

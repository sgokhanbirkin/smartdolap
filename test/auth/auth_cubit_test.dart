import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartdolap/features/auth/data/models/auth_failure.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';

void main() {
  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading] when setLoading is called',
      build: AuthCubit.new,
      act: (AuthCubit cubit) => cubit.setLoading(),
      expect: () => const <AuthState>[AuthState.loading()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits authenticated user when setAuthenticated is called',
      build: AuthCubit.new,
      act: (AuthCubit cubit) => cubit.setAuthenticated(
        const User(id: '123', email: 'user@test.com', displayName: 'Test User'),
      ),
      expect: () => const <AuthState>[
        AuthState.authenticated(
          User(id: '123', email: 'user@test.com', displayName: 'Test User'),
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits unauthenticated when setUnauthenticated is called',
      build: AuthCubit.new,
      act: (AuthCubit cubit) => cubit.setUnauthenticated(),
      expect: () => const <AuthState>[AuthState.unauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits error when setError is called',
      build: AuthCubit.new,
      act: (AuthCubit cubit) =>
          cubit.setError(const AuthFailure.invalidCredentials()),
      expect: () => const <AuthState>[
        AuthState.error(AuthFailure.invalidCredentials()),
      ],
    );

    test('initial state should be AuthState.initial()', () {
      final AuthCubit cubit = AuthCubit();
      expect(cubit.state, const AuthState.initial());
    });
  });
}

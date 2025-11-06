import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart';
import 'package:smartdolap/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:smartdolap/features/auth/domain/use_cases/login_usecase.dart';

/// Mock IAuthRepository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('LoginUseCase', () {
    late MockAuthRepository mockRepository;
    late LoginUseCase loginUseCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      loginUseCase = LoginUseCase(mockRepository);
    });

    test('should return User with uid when login is successful', () async {
      // Arrange
      const String testEmail = 'test@example.com';
      const String testPassword = 'password123';
      const String testUid = 'test-uid-123';
      const User expectedUser = User(
        id: testUid,
        email: testEmail,
        displayName: 'Test User',
      );

      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => expectedUser);

      // Act
      final User result = await loginUseCase(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, equals(expectedUser));
      expect(result.id, equals(testUid));
      expect(result.email, equals(testEmail));
      verify(
        () => mockRepository.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);
    });

    test('should return User with correct uid from repository', () async {
      // Arrange
      const String testEmail = 'user@test.com';
      const String testPassword = 'pass123';
      const String testUid = 'user-uid-456';
      const User expectedUser = User(id: testUid, email: testEmail);

      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).thenAnswer((_) async => expectedUser);

      // Act
      final User result = await loginUseCase(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result.id, equals(testUid));
      expect(result.email, equals(testEmail));
      expect(result.id, isNotEmpty);
    });
  });
}

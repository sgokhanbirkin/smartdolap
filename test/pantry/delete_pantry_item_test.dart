import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';

/// Mock IPantryRepository
class MockPantryRepository extends Mock implements IPantryRepository {}

void main() {
  group('DeletePantryItem', () {
    late MockPantryRepository mockRepository;
    late DeletePantryItem deletePantryItem;

    setUp(() {
      mockRepository = MockPantryRepository();
      deletePantryItem = DeletePantryItem(mockRepository);
    });

    test('should delete pantry item successfully', () async {
      // Arrange
      const String testHouseholdId = 'test-household-123';
      const String testItemId = 'item-123';

      when(
        () => mockRepository.deleteItem(householdId: testHouseholdId, itemId: testItemId),
      ).thenAnswer((_) async => Future<void>.value());

      // Act
      await deletePantryItem(householdId: testHouseholdId, itemId: testItemId);

      // Assert
      verify(
        () => mockRepository.deleteItem(householdId: testHouseholdId, itemId: testItemId),
      ).called(1);
    });

    test('should propagate errors from repository', () async {
      // Arrange
      const String testHouseholdId = 'test-household-123';
      const String testItemId = 'item-123';
      final Exception testError = Exception('Repository error');

      when(
        () => mockRepository.deleteItem(householdId: testHouseholdId, itemId: testItemId),
      ).thenThrow(testError);

      // Act & Assert
      expect(
        () => deletePantryItem(householdId: testHouseholdId, itemId: testItemId),
        throwsA(testError),
      );
      verify(
        () => mockRepository.deleteItem(householdId: testHouseholdId, itemId: testItemId),
      ).called(1);
    });
  });
}

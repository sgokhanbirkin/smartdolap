import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';

/// Mock IPantryRepository
class MockPantryRepository extends Mock implements IPantryRepository {}

void main() {
  group('UpdatePantryItem', () {
    late MockPantryRepository mockRepository;
    late UpdatePantryItem updatePantryItem;

    setUp(() {
      mockRepository = MockPantryRepository();
      updatePantryItem = UpdatePantryItem(mockRepository);
    });

    test('should update pantry item and return updated item', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const PantryItem inputItem = PantryItem(
        id: 'item-123',
        name: 'Yumurta',
        quantity: 6,
        unit: 'adet',
      );
      const PantryItem updatedItem = PantryItem(
        id: 'item-123',
        name: 'Yumurta',
        quantity: 12,
        unit: 'adet',
      );

      when(
        () => mockRepository.updateItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).thenAnswer((_) async => updatedItem);

      // Act
      final PantryItem result = await updatePantryItem(
        userId: testUserId,
        item: inputItem,
      );

      // Assert
      expect(result, equals(updatedItem));
      expect(result.quantity, equals(12));
      verify(
        () => mockRepository.updateItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).called(1);
    });

    test('should update pantry item category', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const PantryItem inputItem = PantryItem(
        id: 'item-123',
        name: 'Süt',
        category: 'Süt Ürünleri',
      );
      const PantryItem updatedItem = PantryItem(
        id: 'item-123',
        name: 'Süt',
        category: 'İçecek',
      );

      when(
        () => mockRepository.updateItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).thenAnswer((_) async => updatedItem);

      // Act
      final PantryItem result = await updatePantryItem(
        userId: testUserId,
        item: inputItem,
      );

      // Assert
      expect(result.category, equals('İçecek'));
      verify(
        () => mockRepository.updateItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).called(1);
    });

    test('should propagate errors from repository', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const PantryItem inputItem = PantryItem(
        id: 'item-123',
        name: 'Test Item',
      );
      final Exception testError = Exception('Repository error');

      when(
        () => mockRepository.updateItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).thenThrow(testError);

      // Act & Assert
      expect(
        () => updatePantryItem(userId: testUserId, item: inputItem),
        throwsA(testError),
      );
      verify(
        () => mockRepository.updateItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).called(1);
    });
  });
}


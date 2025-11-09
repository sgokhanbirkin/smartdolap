import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';

/// Mock IPantryRepository
class MockPantryRepository extends Mock implements IPantryRepository {}

void main() {
  group('AddPantryItem', () {
    late MockPantryRepository mockRepository;
    late AddPantryItem addPantryItem;

    setUp(() {
      mockRepository = MockPantryRepository();
      addPantryItem = AddPantryItem(mockRepository);
    });

    test('should add pantry item and return it with id', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const PantryItem inputItem = PantryItem(
        id: '',
        name: 'Yumurta',
        quantity: 6,
        unit: 'adet',
      );
      const PantryItem expectedItem = PantryItem(
        id: 'item-123',
        name: 'Yumurta',
        quantity: 6,
        unit: 'adet',
      );

      when(
        () => mockRepository.addItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).thenAnswer((_) async => expectedItem);

      // Act
      final PantryItem result = await addPantryItem(
        userId: testUserId,
        item: inputItem,
      );

      // Assert
      expect(result, equals(expectedItem));
      expect(result.id, equals('item-123'));
      expect(result.name, equals('Yumurta'));
      verify(
        () => mockRepository.addItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).called(1);
    });

    test('should add pantry item with category', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const PantryItem inputItem = PantryItem(
        id: '',
        name: 'Süt',
        unit: 'litre',
        category: 'Süt Ürünleri',
      );
      const PantryItem expectedItem = PantryItem(
        id: 'item-456',
        name: 'Süt',
        unit: 'litre',
        category: 'Süt Ürünleri',
      );

      when(
        () => mockRepository.addItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).thenAnswer((_) async => expectedItem);

      // Act
      final PantryItem result = await addPantryItem(
        userId: testUserId,
        item: inputItem,
      );

      // Assert
      expect(result.category, equals('Süt Ürünleri'));
      verify(
        () => mockRepository.addItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).called(1);
    });

    test('should propagate errors from repository', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      const PantryItem inputItem = PantryItem(
        id: '',
        name: 'Test Item',
      );
      final Exception testError = Exception('Repository error');

      when(
        () => mockRepository.addItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).thenThrow(testError);

      // Act & Assert
      expect(
        () => addPantryItem(userId: testUserId, item: inputItem),
        throwsA(testError),
      );
      verify(
        () => mockRepository.addItem(
          userId: testUserId,
          item: inputItem,
        ),
      ).called(1);
    });
  });
}


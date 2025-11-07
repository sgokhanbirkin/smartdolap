import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/repositories/i_pantry_repository.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';

/// Mock IPantryRepository
class MockPantryRepository extends Mock implements IPantryRepository {}

void main() {
  group('ListPantryItems', () {
    late MockPantryRepository mockRepository;
    late ListPantryItems listPantryItems;

    setUp(() {
      mockRepository = MockPantryRepository();
      listPantryItems = ListPantryItems(mockRepository);
    });

    test('should return stream of pantry items from repository', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      final List<PantryItem> testItems = <PantryItem>[
        const PantryItem(
          id: 'item-1',
          name: 'Yumurta',
          quantity: 6,
          unit: 'adet',
        ),
        const PantryItem(
          id: 'item-2',
          name: 'Süt',
          quantity: 1,
          unit: 'litre',
        ),
      ];

      when(
        () => mockRepository.watchItems(userId: testUserId),
      ).thenAnswer((_) => Stream.value(testItems));

      // Act
      final Stream<List<PantryItem>> result =
          listPantryItems(userId: testUserId);

      // Assert
      expect(result, isA<Stream<List<PantryItem>>>());
      final List<PantryItem> items = await result.first;
      expect(items.length, equals(2));
      expect(items.first.name, equals('Yumurta'));
      expect(items.last.name, equals('Süt'));
      verify(() => mockRepository.watchItems(userId: testUserId)).called(1);
    });

    test('should return empty stream when repository returns empty list',
        () async {
      // Arrange
      const String testUserId = 'test-user-123';

      when(
        () => mockRepository.watchItems(userId: testUserId),
      ).thenAnswer((_) => Stream.value(<PantryItem>[]));

      // Act
      final Stream<List<PantryItem>> result =
          listPantryItems(userId: testUserId);

      // Assert
      final List<PantryItem> items = await result.first;
      expect(items, isEmpty);
      verify(() => mockRepository.watchItems(userId: testUserId)).called(1);
    });

    test('should propagate errors from repository', () async {
      // Arrange
      const String testUserId = 'test-user-123';
      final Exception testError = Exception('Repository error');

      when(
        () => mockRepository.watchItems(userId: testUserId),
      ).thenAnswer((_) => Stream<List<PantryItem>>.error(testError));

      // Act & Assert
      final Stream<List<PantryItem>> result =
          listPantryItems(userId: testUserId);
      expect(result, emitsError(testError));
      verify(() => mockRepository.watchItems(userId: testUserId)).called(1);
    });
  });
}


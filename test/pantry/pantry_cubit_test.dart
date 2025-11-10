/*import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/add_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/delete_pantry_item.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/list_pantry_items.dart';
import 'package:smartdolap/features/pantry/domain/use_cases/update_pantry_item.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';
import 'package:smartdolap/product/services/expiry_notification_service.dart';

/// Mock UseCases
class MockListPantryItems extends Mock implements ListPantryItems {}

class MockAddPantryItem extends Mock implements AddPantryItem {}

class MockUpdatePantryItem extends Mock implements UpdatePantryItem {}

class MockDeletePantryItem extends Mock implements DeletePantryItem {}

class MockExpiryNotificationService extends Mock
    implements ExpiryNotificationService {}

void main() {
  group('PantryCubit', () {
    late MockListPantryItems mockListPantryItems;
    late MockAddPantryItem mockAddPantryItem;
    late MockUpdatePantryItem mockUpdatePantryItem;
    late MockDeletePantryItem mockDeletePantryItem;
    late MockExpiryNotificationService mockExpiryNotificationService;

    setUp(() {
      mockListPantryItems = MockListPantryItems();
      mockAddPantryItem = MockAddPantryItem();
      mockUpdatePantryItem = MockUpdatePantryItem();
      mockDeletePantryItem = MockDeletePantryItem();
      mockExpiryNotificationService = MockExpiryNotificationService();

      // Setup default mock behaviors
      when(
        () => mockExpiryNotificationService.schedulePerItem(any()),
      ).thenAnswer((_) async => {});
      when(
        () => mockExpiryNotificationService.cancelItemNotifications(any()),
      ).thenAnswer((_) async => {});
    });

    test('initial state should be PantryInitial', () {
      // Act
      final PantryCubit cubit = PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      );

      // Assert
      expect(cubit.state, const PantryInitial());
    });

    blocTest<PantryCubit, PantryState>(
      'should emit [loading, loaded] when watch is successful',
      setUp: () {
        const String testUserId = 'test-user-123';
        final List<PantryItem> testItems = <PantryItem>[
          const PantryItem(
            id: 'item-1',
            name: 'Yumurta',
            quantity: 6,
            unit: 'adet',
          ),
        ];

        when(
          () => mockListPantryItems(userId: testUserId),
        ).thenAnswer((_) => Stream<List<PantryItem>>.value(testItems));
      },
      build: () => PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      ),
      act: (PantryCubit cubit) => cubit.watch('test-user-123'),
      wait: const Duration(milliseconds: 100),
      expect: () => <Matcher>[
        isA<PantryLoading>(),
        isA<PantryLoaded>()
            .having((PantryLoaded s) => s.items.length, 'items.length', 1)
            .having(
              (PantryLoaded s) => s.items.first.name,
              'items.first.name',
              'Yumurta',
            ),
      ],
    );

    blocTest<PantryCubit, PantryState>(
      'should emit [loading, loaded] with empty list when watch returns empty',
      setUp: () {
        const String testUserId = 'test-user-123';

        when(
          () => mockListPantryItems(userId: testUserId),
        ).thenAnswer((_) => Stream<List<PantryItem>>.value(<PantryItem>[]));
      },
      build: () => PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      ),
      act: (PantryCubit cubit) => cubit.watch('test-user-123'),
      wait: const Duration(milliseconds: 100),
      expect: () => <Matcher>[
        isA<PantryLoading>(),
        isA<PantryLoaded>().having(
          (PantryLoaded s) => s.items,
          'items',
          isEmpty,
        ),
      ],
    );

    blocTest<PantryCubit, PantryState>(
      'should emit [loading, failure] when watch fails',
      setUp: () {
        const String testUserId = 'test-user-123';
        final Exception testError = Exception('Repository error');

        when(
          () => mockListPantryItems(userId: testUserId),
        ).thenAnswer((_) => Stream<List<PantryItem>>.error(testError));
      },
      build: () => PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      ),
      act: (PantryCubit cubit) => cubit.watch('test-user-123'),
      wait: const Duration(milliseconds: 100),
      expect: () => <Matcher>[
        isA<PantryLoading>(),
        isA<PantryFailure>().having(
          (PantryFailure s) => s.message,
          'message',
          'Exception: Repository error',
        ),
      ],
    );

    blocTest<PantryCubit, PantryState>(
      'should emit failure when add fails',
      setUp: () {
        const String testUserId = 'test-user-123';
        const PantryItem testItem = PantryItem(id: '', name: 'Test Item');
        final Exception testError = Exception('Add error');

        when(
          () => mockAddPantryItem(userId: testUserId, item: testItem),
        ).thenThrow(testError);
      },
      build: () => PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      ),
      act: (PantryCubit cubit) => cubit.add(
        'test-user-123',
        const PantryItem(id: '', name: 'Test Item'),
      ),
      expect: () => <Matcher>[
        isA<PantryFailure>().having(
          (PantryFailure s) => s.message,
          'message',
          'Exception: Add error',
        ),
      ],
    );

    blocTest<PantryCubit, PantryState>(
      'should emit failure when update fails',
      setUp: () {
        const String testUserId = 'test-user-123';
        const PantryItem testItem = PantryItem(
          id: 'item-1',
          name: 'Updated Item',
        );
        final Exception testError = Exception('Update error');

        when(
          () => mockUpdatePantryItem(userId: testUserId, item: testItem),
        ).thenThrow(testError);
      },
      build: () => PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      ),
      act: (PantryCubit cubit) => cubit.update(
        'test-user-123',
        const PantryItem(id: 'item-1', name: 'Updated Item'),
      ),
      expect: () => <Matcher>[
        isA<PantryFailure>().having(
          (PantryFailure s) => s.message,
          'message',
          'Exception: Update error',
        ),
      ],
    );

    blocTest<PantryCubit, PantryState>(
      'should emit failure when remove fails',
      setUp: () {
        const String testUserId = 'test-user-123';
        const String testItemId = 'item-1';
        final Exception testError = Exception('Delete error');

        when(
          () => mockDeletePantryItem(userId: testUserId, itemId: testItemId),
        ).thenThrow(testError);
      },
      build: () => PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      ),
      act: (PantryCubit cubit) => cubit.remove('test-user-123', 'item-1'),
      expect: () => <Matcher>[
        isA<PantryFailure>().having(
          (PantryFailure s) => s.message,
          'message',
          'Exception: Delete error',
        ),
      ],
    );

    blocTest<PantryCubit, PantryState>(
      'should call watch when refresh is called',
      setUp: () {
        const String testUserId = 'test-user-123';
        final List<PantryItem> testItems = <PantryItem>[];

        when(
          () => mockListPantryItems(userId: testUserId),
        ).thenAnswer((_) => Stream<List<PantryItem>>.value(testItems));
      },
      build: () => PantryCubit(
        listPantryItems: mockListPantryItems,
        addPantryItem: mockAddPantryItem,
        updatePantryItem: mockUpdatePantryItem,
        deletePantryItem: mockDeletePantryItem,
        expiryNotificationService: mockExpiryNotificationService,
      ),
      act: (PantryCubit cubit) => cubit.refresh('test-user-123'),
      wait: const Duration(milliseconds: 100),
      expect: () => <Matcher>[
        isA<PantryLoading>(),
        isA<PantryLoaded>().having(
          (PantryLoaded s) => s.items,
          'items',
          isEmpty,
        ),
      ],
    );
  });
}
*/

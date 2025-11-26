import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartdolap/features/pantry/domain/entities/pantry_item.dart';
import 'package:smartdolap/product/services/expiry_notification_service.dart';

// Mock classes
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

void main() {
  group('ExpiryNotificationService', () {
    late MockFlutterLocalNotificationsPlugin mockNotifications;
    late ExpiryNotificationService service;

    setUp(() {
      mockNotifications = MockFlutterLocalNotificationsPlugin();
      service = ExpiryNotificationService(mockNotifications);
    });

    group('cancelItemNotifications', () {
      test('should cancel all 4 notification IDs for an item', () async {
        // Arrange
        const String itemId = 'test-item-123';
        final int baseId = itemId.hashCode;

        when(() => mockNotifications.cancel(any())).thenAnswer((_) async => <dynamic, dynamic>{});

        // Act
        await service.cancelItemNotifications(itemId);

        // Assert
        verify(() => mockNotifications.cancel(baseId)).called(1);
        verify(() => mockNotifications.cancel(baseId + 1000)).called(1);
        verify(() => mockNotifications.cancel(baseId + 2000)).called(1);
        verify(() => mockNotifications.cancel(baseId + 3000)).called(1);
      });

      test('should handle cancellation errors gracefully', () async {
        // Arrange
        const String itemId = 'test-item-123';

        when(
          () => mockNotifications.cancel(any()),
        ).thenThrow(Exception('Cancel failed'));

        // Act & Assert - should not throw
        await service.cancelItemNotifications(itemId);
      });
    });

    group('schedulePerItem', () {
      test(
        'should schedule 3-day notification when item expires in 5 days',
        () async {
          // Arrange
          final PantryItem item = PantryItem(
            id: 'item-1',
            name: 'Test Item',
            expiryDate: DateTime.now().add(const Duration(days: 5)),
          );

          when(
            () => mockNotifications.zonedSchedule(
              any(),
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).thenAnswer((_) async => <dynamic, dynamic>{});

          // Act
          await service.schedulePerItem(item);

          // Assert - should schedule 3-day notification
          verify(
            () => mockNotifications.zonedSchedule(
              item.id.hashCode + 1000,
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).called(1);
        },
      );

      test(
        'should schedule 1-day notification when item expires in 2 days',
        () async {
          // Arrange
          final PantryItem item = PantryItem(
            id: 'item-1',
            name: 'Test Item',
            expiryDate: DateTime.now().add(const Duration(days: 2)),
          );

          when(
            () => mockNotifications.zonedSchedule(
              any(),
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).thenAnswer((_) async => <dynamic, dynamic>{});

          // Act
          await service.schedulePerItem(item);

          // Assert - should schedule 1-day notification
          verify(
            () => mockNotifications.zonedSchedule(
              item.id.hashCode + 2000,
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).called(1);
        },
      );

      test(
        'should schedule today notification when item expires today',
        () async {
          // Arrange
          final PantryItem item = PantryItem(
            id: 'item-1',
            name: 'Test Item',
            expiryDate: DateTime.now().add(const Duration(hours: 12)),
          );

          when(
            () => mockNotifications.zonedSchedule(
              any(),
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).thenAnswer((_) async => <dynamic, dynamic>{});

          // Act
          await service.schedulePerItem(item);

          // Assert - should schedule today notification
          verify(
            () => mockNotifications.zonedSchedule(
              item.id.hashCode + 3000,
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).called(1);
        },
      );

      test(
        'should not schedule notification for item without expiry date',
        () async {
          // Arrange
          const PantryItem item = PantryItem(
            id: 'item-1',
            name: 'Test Item',
          );

          // Act
          await service.schedulePerItem(item);

          // Assert - should not schedule any notifications
          verifyNever(
            () => mockNotifications.zonedSchedule(
              any(),
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          );
        },
      );

      test('should skip expired items (more than 1 day ago)', () async {
        // Arrange
        final PantryItem item = PantryItem(
          id: 'item-1',
          name: 'Test Item',
          expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        );

        // Act
        await service.schedulePerItem(item);

        // Assert - should not schedule any notifications
        verifyNever(
          () => mockNotifications.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation: any(
              named: 'uiLocalNotificationDateInterpretation',
            ),
          ),
        );
      });
    });

    group('scheduleNotifications', () {
      test(
        'should cancel and reschedule notifications for all items',
        () async {
          // Arrange
          final List<PantryItem> items = <PantryItem>[
            PantryItem(
              id: 'item-1',
              name: 'Item 1',
              expiryDate: DateTime.now().add(const Duration(days: 5)),
            ),
            PantryItem(
              id: 'item-2',
              name: 'Item 2',
              expiryDate: DateTime.now().add(const Duration(days: 3)),
            ),
          ];

          when(
            () => mockNotifications.zonedSchedule(
              any(),
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).thenAnswer((_) async => <dynamic, dynamic>{});

          // Act
          await service.scheduleNotifications(items);

          // Assert - should cancel notifications for each item
          verify(
            () => mockNotifications.cancel(items[0].id.hashCode),
          ).called(1);
          verify(
            () => mockNotifications.cancel(items[1].id.hashCode),
          ).called(1);
          // Should schedule notifications for each item
          verify(
            () => mockNotifications.zonedSchedule(
              any(),
              any(),
              any(),
              any(),
              any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation: any(
                named: 'uiLocalNotificationDateInterpretation',
              ),
            ),
          ).called(greaterThan(0));
        },
      );

      test('should handle errors gracefully', () async {
        // Arrange
        final List<PantryItem> items = <PantryItem>[
          PantryItem(
            id: 'item-1',
            name: 'Item 1',
            expiryDate: DateTime.now().add(const Duration(days: 5)),
          ),
        ];

        when(
          () => mockNotifications.cancel(any()),
        ).thenThrow(Exception('Cancel failed'));

        // Act & Assert - should not throw
        await service.scheduleNotifications(items);
      });
    });
  });
}

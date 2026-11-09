import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/infrastructure/event/stream_domain_event_bus.dart';

void main() {
  late StreamDomainEventBus eventBus;

  setUp(() {
    eventBus = StreamDomainEventBus();
  });

  tearDown(() async {
    await eventBus.dispose();
  });

  group('StreamDomainEventBus Delivery & Filtering', () {
    test(
      'should deliver event to matching typed subscribers',
      () async {
        final receivedEvents = <ActiveBranchChangedEvent>[];

        final subscription = eventBus.on<ActiveBranchChangedEvent>().listen(
          receivedEvents.add,
        );

        final event = ActiveBranchChangedEvent(
          branchId: 'b-01-smp',
          branchName: 'Sede San Martin',
        );

        eventBus.emit(event);

        await pumpEventQueue();

        expect(receivedEvents.length, equals(1));
        expect(receivedEvents.first.branchId, equals('b-01-smp'));
        expect(receivedEvents.first.branchName, equals('Sede San Martin'));

        await subscription.cancel();
      },
    );

    test(
      'should not deliver events to subscribers of different types',
      () async {
        final branchEvents = <ActiveBranchChangedEvent>[];
        final sessionEvents = <SessionExpiredEvent>[];

        final sub1 = eventBus.on<ActiveBranchChangedEvent>().listen(
          branchEvents.add,
        );
        final sub2 = eventBus.on<SessionExpiredEvent>().listen(
          sessionEvents.add,
        );

        eventBus.emit(SessionExpiredEvent(reason: 'Token expired'));

        await pumpEventQueue();

        expect(branchEvents, isEmpty);
        expect(sessionEvents.length, equals(1));
        expect(sessionEvents.first.reason, equals('Token expired'));

        await sub1.cancel();
        await sub2.cancel();
      },
    );

    test(
      'should cease delivering events after subscription is canceled',
      () async {
        final receivedEvents = <UserLoggedOutEvent>[];

        final subscription = eventBus.on<UserLoggedOutEvent>().listen(
          receivedEvents.add,
        );

        eventBus.emit(UserLoggedOutEvent(userId: 'usr-1', reason: 'manual'));
        await pumpEventQueue();

        expect(receivedEvents.length, equals(1));

        await subscription.cancel();

        eventBus.emit(UserLoggedOutEvent(userId: 'usr-2', reason: 'timeout'));
        await pumpEventQueue();

        // Count should not have incremented
        expect(receivedEvents.length, equals(1));
      },
    );
  });

  group('Dart 3 Pattern Matching on Sealed DomainEvent Hierarchy', () {
    test('should exhaustively match all event subtypes with destructuring', () {
      final events = <DomainEvent>[
        ActiveBranchChangedEvent(
          branchId: 'b-99',
          branchName: 'Callao Workshop',
        ),
        UserLoggedInEvent(
          userId: 'usr-10',
          username: 'owner@shiftiq.com',
          roles: ['ROLE_OWNER'],
        ),
        UserLoggedOutEvent(userId: 'usr-42', reason: 'User clicked logout'),
        SessionExpiredEvent(reason: 'JWT 401 Unauthorized'),
      ];

      final summaries = events.map((event) {
        return switch (event) {
          ActiveBranchChangedEvent(:final branchId, :final branchName) =>
            'BRANCH:$branchId:$branchName',
          UserLoggedInEvent(:final userId, :final username) =>
            'LOGIN:$userId:$username',
          UserLoggedOutEvent(:final userId, :final reason) =>
            'LOGOUT:$userId:$reason',
          SessionExpiredEvent(:final reason) =>
            'EXPIRED:$reason',
        };
      }).toList();

      expect(
        summaries[0],
        equals('BRANCH:b-99:Callao Workshop'),
      );
      expect(
        summaries[1],
        equals('LOGIN:usr-10:owner@shiftiq.com'),
      );
      expect(
        summaries[2],
        equals('LOGOUT:usr-42:User clicked logout'),
      );
      expect(
        summaries[3],
        equals('EXPIRED:JWT 401 Unauthorized'),
      );
    });
  });
}

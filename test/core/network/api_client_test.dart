import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/infrastructure/event/stream_domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';

void main() {
  late StreamDomainEventBus eventBus;
  late SessionStorage sessionStorage;

  setUp(() {
    eventBus = StreamDomainEventBus();
    sessionStorage = SessionStorage();
  });

  tearDown(() async {
    await eventBus.dispose();
  });

  group('ApiClient 401 & SessionExpiredEvent', () {
    test(
      'should emit SessionExpiredEvent on 401 Unauthorized response',
      () async {
        final capturedEvents = <SessionExpiredEvent>[];
        final subscription = eventBus.on<SessionExpiredEvent>().listen(
          capturedEvents.add,
        );

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'Invalid access token'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          sessionStorage: sessionStorage,
          eventBus: eventBus,
          client: mockClient,
        );

        expect(
          () => apiClient.get('/api/v1/test-endpoint'),
          throwsA(isA<AuthenticationException>()),
        );

        await pumpEventQueue();

        expect(capturedEvents.length, equals(1));
        expect(capturedEvents.first.reason, equals('Invalid access token'));

        await subscription.cancel();
      },
    );

    test(
      'should process 200 OK responses without emitting events',
      () async {
        final capturedEvents = <DomainEvent>[];
        final subscription = eventBus.on<DomainEvent>().listen(
          capturedEvents.add,
        );

        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'status': 'ok', 'data': 123}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          sessionStorage: sessionStorage,
          eventBus: eventBus,
          client: mockClient,
        );

        final result = await apiClient.get('/api/v1/success');

        await pumpEventQueue();

        expect(result['status'], equals('ok'));
        expect(capturedEvents, isEmpty);

        await subscription.cancel();
      },
    );

    test(
      'should map 400 Bad Request to ValidationException',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'Invalid request payload'}),
            400,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          sessionStorage: sessionStorage,
          eventBus: eventBus,
          client: mockClient,
        );

        expect(
          () => apiClient.post('/api/v1/create', body: {'invalid': true}),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });
}

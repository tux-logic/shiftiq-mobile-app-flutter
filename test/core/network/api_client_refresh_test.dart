import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';

class _FakeDomainEventBus implements DomainEventBus {
  final _controller = StreamController<DomainEvent>.broadcast();

  @override
  void emit(DomainEvent event) => _controller.add(event);

  @override
  Stream<T> on<T extends DomainEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  @override
  Future<void> dispose() => _controller.close();
}

void main() {
  group('ApiClient 401 Automatic Token Refresh', () {
    late SessionStorage sessionStorage;
    late _FakeDomainEventBus eventBus;

    setUp(() async {
      sessionStorage = SessionStorage();
      await sessionStorage.saveSession(
        accessToken: 'expired-access-token',
        refreshToken: 'valid-refresh-token',
        userId: 'user-1',
        username: 'owner@shiftiq.com',
        roles: ['ROLE_OWNER'],
      );
      eventBus = _FakeDomainEventBus();
    });

    tearDown(() {
      eventBus.dispose();
    });

    test(
      'refreshes tokens on 401 and retries original GET request with new token',
      () async {
        var refreshCalls = 0;
        final mockClient = MockClient((request) async {
          if (request.url.path == ApiConstants.authRefresh) {
            refreshCalls++;
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['refreshToken'], 'valid-refresh-token');
            return http.Response(
              jsonEncode({
                'token': 'fresh-access-token',
                'refreshToken': 'fresh-refresh-token',
              }),
              200,
            );
          }

          final authHeader = request.headers['authorization'];
          if (authHeader == 'Bearer expired-access-token') {
            return http.Response(
              jsonEncode({'message': 'JWT expired'}),
              401,
            );
          }

          if (authHeader == 'Bearer fresh-access-token') {
            return http.Response(jsonEncode([{'id': 'appt-1'}]), 200);
          }

          return http.Response('Unexpected header: $authHeader', 500);
        });

        final client = ApiClient(
          sessionStorage: sessionStorage,
          eventBus: eventBus,
          client: mockClient,
        );

        final result = await client.get(ApiConstants.appointments);

        expect(refreshCalls, 1);
        expect(result, isA<List<dynamic>>());
        expect((result as List).first['id'], 'appt-1');
        expect(await sessionStorage.getAccessToken(), 'fresh-access-token');
        expect(await sessionStorage.getRefreshToken(), 'fresh-refresh-token');
      },
    );

    test(
      'shares a single refresh request across concurrent 401 responses',
      () async {
        var refreshCalls = 0;
        final mockClient = MockClient((request) async {
          if (request.url.path == ApiConstants.authRefresh) {
            refreshCalls++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
            return http.Response(
              jsonEncode({
                'token': 'fresh-access-token',
                'refreshToken': 'fresh-refresh-token',
              }),
              200,
            );
          }

          final authHeader = request.headers['authorization'];
          if (authHeader == 'Bearer expired-access-token') {
            return http.Response(jsonEncode({'message': 'Expired'}), 401);
          }

          return http.Response(jsonEncode([]), 200);
        });

        final client = ApiClient(
          sessionStorage: sessionStorage,
          eventBus: eventBus,
          client: mockClient,
        );

        final results = await Future.wait([
          client.get(ApiConstants.appointments),
          client.get(ApiConstants.inventoryProducts),
        ]);

        expect(refreshCalls, 1);
        expect(results, hasLength(2));
      },
    );

    test(
      'emits SessionExpiredEvent and throws AuthenticationException when refresh fails',
      () async {
        final expiredEvents = <SessionExpiredEvent>[];
        final sub = eventBus.on<SessionExpiredEvent>().listen(expiredEvents.add);

        final mockClient = MockClient((request) async {
          if (request.url.path == ApiConstants.authRefresh) {
            return http.Response(
              jsonEncode({'message': 'Refresh token expired'}),
              401,
            );
          }
          return http.Response(jsonEncode({'message': 'Unauthorized'}), 401);
        });

        final client = ApiClient(
          sessionStorage: sessionStorage,
          eventBus: eventBus,
          client: mockClient,
        );

        await expectLater(
          () => client.get(ApiConstants.inventoryProducts),
          throwsA(isA<AuthenticationException>()),
        );

        await Future<void>.delayed(Duration.zero);
        expect(expiredEvents, hasLength(1));
        await sub.cancel();
      },
    );
  });
}

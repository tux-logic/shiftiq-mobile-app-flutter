import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/infrastructure/event/stream_domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/get_user_profile_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/login_with_google_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/logout_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/otp_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/password_recovery_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/refresh_token_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/sign_up_user_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/update_user_credentials_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/value_objects/user_role.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/auth_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/user_api.dart';

void main() {
  late StreamDomainEventBus eventBus;
  late SessionStorage sessionStorage;
  late AuthApi authApi;
  late UserApi userApi;
  late AuthRepositoryImpl repository;

  setUp(() {
    eventBus = StreamDomainEventBus();
    sessionStorage = SessionStorage();

    final mockClient = MockClient((request) async {
      final path = request.url.path;

      if (path.contains('/authentication/sessions/google')) {
        return http.Response(
          '''
          {
            "id": "usr-google-1",
            "email": "carlos.google@shiftiq.com",
            "role": "ROLE_USER",
            "token": "jwt-google-token-xyz",
            "refreshToken": "refresh-google-token-123",
            "accessTokenExpiresInSeconds": 900
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.contains('/authentication/sessions/refresh')) {
        return http.Response(
          '''
          {
            "id": "usr-rotated-1",
            "email": "carlos.rotated@shiftiq.com",
            "role": "ROLE_USER",
            "token": "jwt-new-token",
            "refreshToken": "refresh-new-token",
            "accessTokenExpiresInSeconds": 900
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path == '/api/v1/authentication/sessions' &&
          request.method == 'DELETE') {
        return http.Response('', 204);
      }

      if (path.contains('/authentication/password-recoveries') ||
          path.contains('/authentication/password-resets') ||
          path.contains('/authentication/otp/send') ||
          path.contains('/authentication/otp/verify')) {
        return http.Response('{"message":"Success"}', 200,
            headers: {'content-type': 'application/json'});
      }

      if (path == '/api/v1/users' && request.method == 'POST') {
        return http.Response(
          '''
          {
            "id": "usr-new-id-77",
            "email": "new.user@shiftiq.com",
            "role": "ROLE_USER"
          }
          ''',
          201,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.contains('/api/v1/users/usr-77/email')) {
        return http.Response(
          '''
          {
            "id": "usr-77",
            "email": "updated.email@shiftiq.com",
            "role": "ROLE_USER",
            "token": "jwt-email-token",
            "refreshToken": "refresh-email-token",
            "accessTokenExpiresInSeconds": 900
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (path.contains('/api/v1/users/usr-77/password')) {
        return http.Response('{"message":"Password updated"}', 200,
            headers: {'content-type': 'application/json'});
      }

      if (path.contains('/api/v1/users')) {
        return http.Response(
          '''
          {
            "id": "usr-77",
            "email": "carlos.cliente@shiftiq.com",
            "role": "ROLE_CUSTOMER"
          }
          ''',
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      return http.Response('{"error":"Not Found"}', 404,
          headers: {'content-type': 'application/json'});
    });

    final apiClient = ApiClient(
      sessionStorage: sessionStorage,
      eventBus: eventBus,
      client: mockClient,
    );

    authApi = AuthApi(apiClient: apiClient);
    userApi = UserApi(apiClient: apiClient);

    repository = AuthRepositoryImpl(
      authApi: authApi,
      userApi: userApi,
      sessionStorage: sessionStorage,
      eventBus: eventBus,
    );
  });

  tearDown(() async {
    await eventBus.dispose();
  });

  group('Authentication Use Cases & Domain Event Dispatch', () {
    test(
      'LoginWithGoogleUseCase should establish session and emit UserLoggedInEvent',
      () async {
        final capturedEvents = <UserLoggedInEvent>[];
        final subscription = eventBus.on<UserLoggedInEvent>().listen(
          capturedEvents.add,
        );

        final useCase = LoginWithGoogleUseCase(repository: repository);
        final session = await useCase.execute(idToken: 'google-id-token');

        await pumpEventQueue();

        expect(session.id, equals('usr-google-1'));
        expect(session.username, equals('carlos.google@shiftiq.com'));
        expect(session.token, equals('jwt-google-token-xyz'));
        expect(capturedEvents.length, equals(1));
        expect(capturedEvents.first.userId, equals('usr-google-1'));

        await subscription.cancel();
      },
    );

    test(
      'RefreshTokenUseCase should rotate tokens in session storage',
      () async {
        await sessionStorage.saveSession(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
          userId: 'usr-1',
          username: 'user@shiftiq.com',
          roles: ['ROLE_USER'],
        );

        final useCase = RefreshTokenUseCase(repository: repository);
        final session = await useCase.execute();

        expect(session.token, equals('jwt-new-token'));
        expect(session.refreshToken, equals('refresh-new-token'));
        expect(await sessionStorage.getAccessToken(), equals('jwt-new-token'));
      },
    );

    test(
      'LogoutUseCase should clear session storage and emit UserLoggedOutEvent',
      () async {
        final capturedEvents = <UserLoggedOutEvent>[];
        final subscription = eventBus.on<UserLoggedOutEvent>().listen(
          capturedEvents.add,
        );

        await sessionStorage.saveSession(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          userId: 'usr-logout-target',
          username: 'user@shiftiq.com',
          roles: ['ROLE_USER'],
        );

        final useCase = LogoutUseCase(repository: repository);
        await useCase.execute();

        await pumpEventQueue();

        expect(sessionStorage.isAuthenticated, isFalse);
        expect(capturedEvents.length, equals(1));
        expect(capturedEvents.first.userId, equals('usr-logout-target'));

        await subscription.cancel();
      },
    );

    test('Password recovery and reset use cases should complete successfully',
        () async {
      final reqUseCase = RequestPasswordRecoveryUseCase(repository: repository);
      final resetUseCase = ResetPasswordUseCase(repository: repository);

      await expectLater(
        reqUseCase.execute(email: 'user@shiftiq.com'),
        completes,
      );

      await expectLater(
        resetUseCase.execute(
          token: 'token-abc',
          newPassword: 'NewPassword123!',
        ),
        completes,
      );
    });

    test('SendOtpUseCase and VerifyOtpUseCase should complete without error',
        () async {
      final sendOtp = SendOtpUseCase(repository: repository);
      final verifyOtp = VerifyOtpUseCase(repository: repository);

      await expectLater(
        sendOtp.execute(email: 'new@shiftiq.com'),
        completes,
      );

      await expectLater(
        verifyOtp.execute(email: 'new@shiftiq.com', code: '123456'),
        completes,
      );
    });
  });

  group('User Management Use Cases', () {
    test('SignUpUserUseCase should register user and return UserAccount',
        () async {
      final useCase = SignUpUserUseCase(repository: repository);
      final account = await useCase.execute(
        email: 'new.user@shiftiq.com',
        password: 'Password123!',
      );

      expect(account.id, equals('usr-new-id-77'));
      expect(account.email, equals('new.user@shiftiq.com'));
      expect(account.role, equals(UserRole.user));
    });

    test('GetUserProfileUseCase should fetch user account by ID and email',
        () async {
      final useCase = GetUserProfileUseCase(repository: repository);

      final byId = await useCase.byId('usr-77');
      expect(byId.id, equals('usr-77'));
      expect(byId.email, equals('carlos.cliente@shiftiq.com'));
      expect(byId.role, equals(UserRole.customer));

      final byEmail = await useCase.byEmail('carlos.cliente@shiftiq.com');
      expect(byEmail.id, equals('usr-77'));
    });

    test('UpdateUserEmailUseCase should rotate tokens and update session',
        () async {
      final useCase = UpdateUserEmailUseCase(repository: repository);
      final session = await useCase.execute(
        userId: 'usr-77',
        newEmail: 'updated.email@shiftiq.com',
      );

      expect(session.username, equals('updated.email@shiftiq.com'));
      expect(session.token, equals('jwt-email-token'));
      expect(
        await sessionStorage.getAccessToken(),
        equals('jwt-email-token'),
      );
    });

    test(
        'UpdateUserPasswordUseCase should invalidate session and emit UserLoggedOutEvent',
        () async {
      final capturedEvents = <UserLoggedOutEvent>[];
      final subscription = eventBus.on<UserLoggedOutEvent>().listen(
        capturedEvents.add,
      );

      final useCase = UpdateUserPasswordUseCase(repository: repository);
      await useCase.execute(
        userId: 'usr-77',
        currentPassword: 'OldPassword123!',
        newPassword: 'NewPassword123!',
      );

      await pumpEventQueue();

      expect(sessionStorage.isAuthenticated, isFalse);
      expect(capturedEvents.length, equals(1));
      expect(capturedEvents.first.userId, equals('usr-77'));

      await subscription.cancel();
    });
  });
}

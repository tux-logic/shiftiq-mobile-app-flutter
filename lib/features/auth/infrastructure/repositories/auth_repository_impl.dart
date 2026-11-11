import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/aggregates/user_session.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/entities/user_account.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/user_api.dart';

/// Concrete implementation of [AuthRepository] coordinating IAM remote APIs,
/// local persistent session storage, and core domain event messaging.
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi authApi;
  final UserApi userApi;
  final SessionStorage sessionStorage;
  final DomainEventBus eventBus;

  AuthRepositoryImpl({
    required this.authApi,
    required this.userApi,
    required this.sessionStorage,
    required this.eventBus,
  }) {
    _listenToSessionExpiration();
  }

  void _listenToSessionExpiration() {
    eventBus.on<SessionExpiredEvent>().listen((_) async {
      await sessionStorage.clearSession();
    });
  }

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    final dto = await authApi.signIn(email: email, password: password);
    final session = dto.toDomain();

    await sessionStorage.saveSession(
      accessToken: session.token,
      refreshToken: session.refreshToken,
      userId: session.id,
      username: session.username,
      roles: session.roles,
    );

    eventBus.emit(
      UserLoggedInEvent(
        userId: session.id,
        username: session.username,
        roles: session.roles,
      ),
    );

    return session;
  }

  @override
  Future<UserSession> loginWithGoogle({required String idToken}) async {
    final dto = await authApi.signInWithGoogle(idToken: idToken);
    final session = dto.toDomain();

    await sessionStorage.saveSession(
      accessToken: session.token,
      refreshToken: session.refreshToken,
      userId: session.id,
      username: session.username,
      roles: session.roles,
    );

    eventBus.emit(
      UserLoggedInEvent(
        userId: session.id,
        username: session.username,
        roles: session.roles,
      ),
    );

    return session;
  }

  @override
  Future<UserSession> refreshToken() async {
    final currentRefreshToken = await sessionStorage.getRefreshToken();
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw AuthenticationException(
        message: 'No active session refresh token found.',
      );
    }

    final dto = await authApi.refreshToken(
      refreshToken: currentRefreshToken,
    );
    final session = dto.toDomain();

    await sessionStorage.updateTokens(
      accessToken: session.token,
      refreshToken: session.refreshToken,
    );

    return session;
  }

  @override
  Future<void> logout() async {
    final currentRefreshToken = await sessionStorage.getRefreshToken();
    final userId = sessionStorage.userId;

    if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
      try {
        await authApi.logout(refreshToken: currentRefreshToken);
      } catch (_) {
        // Proceed with local logout even if server is unreachable
      }
    }

    await sessionStorage.clearSession();

    eventBus.emit(
      UserLoggedOutEvent(
        userId: userId,
        reason: 'Explicit user logout',
      ),
    );
  }

  @override
  Future<void> requestPasswordRecovery({required String email}) async {
    await authApi.requestPasswordRecovery(email: email);
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await authApi.resetPassword(token: token, newPassword: newPassword);
    await sessionStorage.clearSession();
    eventBus.emit(
      UserLoggedOutEvent(
        reason: 'Password reset performed',
      ),
    );
  }

  @override
  Future<void> sendOtp({required String email}) async {
    await authApi.sendOtp(email: email);
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    await authApi.verifyOtp(email: email, code: code);
  }

  @override
  Future<UserAccount> signUp({
    required String email,
    required String password,
  }) async {
    final dto = await userApi.signUp(email: email, password: password);
    return dto.toDomain();
  }

  @override
  Future<UserAccount> getUserById(String userId) async {
    final dto = await userApi.getUserById(userId);
    return dto.toDomain();
  }

  @override
  Future<UserAccount> getUserByEmail(String email) async {
    final dto = await userApi.getUserByEmail(email);
    return dto.toDomain();
  }

  @override
  Future<UserSession> updateUserEmail({
    required String userId,
    required String newEmail,
  }) async {
    final dto = await userApi.updateUserEmail(
      userId: userId,
      email: newEmail,
    );
    final session = dto.toDomain();

    await sessionStorage.saveSession(
      accessToken: session.token,
      refreshToken: session.refreshToken,
      userId: session.id,
      username: session.username,
      roles: session.roles,
    );

    return session;
  }

  @override
  Future<void> updateUserPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    await userApi.updateUserPassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    await sessionStorage.clearSession();
    eventBus.emit(
      UserLoggedOutEvent(
        userId: userId,
        reason: 'Password updated',
      ),
    );
  }
}

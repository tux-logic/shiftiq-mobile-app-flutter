import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi authApi;
  final SessionStorage sessionStorage;

  AuthRepositoryImpl({
    required this.authApi,
    required this.sessionStorage,
  });

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    final dto = await authApi.signIn(email: email, password: password);
    final session = dto.toDomain();

    // Verify authorized roles for B2B workshop app
    if (!session.hasWorkshopManagementAccess && !session.isEmployee) {
      throw AccessDeniedException(
        message: 'Esta aplicación es exclusiva para dueños y administradores de talleres. Su cuenta no tiene los permisos requeridos.',
      );
    }

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
  Future<UserSession> refreshToken() async {
    final currentRefreshToken = await sessionStorage.getRefreshToken();
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      throw AuthenticationException(
        message: 'No existe sesión activa para renovar token.',
      );
    }

    final dto = await authApi.refreshToken(refreshToken: currentRefreshToken);
    final session = dto.toDomain();

    await sessionStorage.updateTokens(
      accessToken: session.token,
      refreshToken: session.refreshToken,
    );

    return session;
  }

  @override
  Future<void> logout() async {
    await sessionStorage.clearSession();
  }

  @override
  Future<void> recoverPassword(String email) async {
    await authApi.sendPasswordRecoveryOtp(email);
  }
}

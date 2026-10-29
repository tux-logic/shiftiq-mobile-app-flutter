import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dtos/google_login_request_dto.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/refresh_token_request_dto.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userDto = await remoteDataSource.loginWithEmail(
        LoginRequestDto(email: email, password: password),
      );

      // Persist auth session securely
      await localDataSource.saveAuthSession(
        accessToken: userDto.token,
        refreshToken: userDto.refreshToken,
        userId: userDto.id,
        role: userDto.role,
      );

      return userDto.toDomainUser();
    } on UnauthorizedException catch (e) {
      throw InvalidCredentialsFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerAuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerAuthFailure(message: 'Error al procesar el inicio de sesión: $e');
    }
  }

  @override
  Future<User> loginWithGoogle({required String idToken}) async {
    try {
      final userDto = await remoteDataSource.loginWithGoogle(
        GoogleLoginRequestDto(idToken: idToken),
      );

      await localDataSource.saveAuthSession(
        accessToken: userDto.token,
        refreshToken: userDto.refreshToken,
        userId: userDto.id,
        role: userDto.role,
      );

      return userDto.toDomainUser();
    } on ServerException catch (e) {
      throw ServerAuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerAuthFailure(message: 'Error al autenticar con Google: $e');
    }
  }

  @override
  Future<AuthTokens> refreshToken() async {
    try {
      final currentRefreshToken = await localDataSource.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw const SessionExpiredFailure();
      }

      final userDto = await remoteDataSource.refreshToken(
        RefreshTokenRequestDto(refreshToken: currentRefreshToken),
      );

      // Persist newly rotated tokens and refreshed user role/id
      await localDataSource.saveAuthSession(
        accessToken: userDto.token,
        refreshToken: userDto.refreshToken,
        userId: userDto.id,
        role: userDto.role,
      );

      return userDto.toDomainTokens();
    } on UnauthorizedException {
      await localDataSource.clearAuthSession();
      throw const SessionExpiredFailure();
    } on ServerException catch (e) {
      throw ServerAuthFailure(message: e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerAuthFailure(message: 'Error al refrescar sesión: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final currentRefreshToken = await localDataSource.getRefreshToken();
      if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
        await remoteDataSource.logout(refreshToken: currentRefreshToken);
      }
    } finally {
      await localDataSource.clearAuthSession();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final hasSession = await localDataSource.hasActiveSession();
    if (!hasSession) return null;

    final userId = await localDataSource.getUserId();
    final role = await localDataSource.getUserRole();

    if (userId == null) return null;

    return User(
      id: userId,
      email: '', // Retrieved from profile or JWT claims if stored
      role: role ?? 'ROLE_USER',
    );
  }

  @override
  Future<List<String>> getActiveRoles(String userId) async {
    try {
      final roles = await remoteDataSource.getActiveRoles(userId);
      if (roles.isNotEmpty) return roles;

      final localRole = await localDataSource.getUserRole();
      return localRole != null ? [localRole] : [];
    } on ServerException catch (e) {
      final localRole = await localDataSource.getUserRole();
      if (localRole != null) return [localRole];
      throw ServerAuthFailure(message: e.message);
    } catch (e) {
      final localRole = await localDataSource.getUserRole();
      if (localRole != null) return [localRole];
      throw ServerAuthFailure(message: 'Error al obtener roles activos: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return localDataSource.hasActiveSession();
  }
}

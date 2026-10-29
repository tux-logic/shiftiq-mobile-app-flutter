import '../entities/auth_tokens.dart';
import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User> loginWithEmail({
    required String email,
    required String password,
  });

  Future<User> loginWithGoogle({
    required String idToken,
  });

  Future<AuthTokens> refreshToken();

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<List<String>> getActiveRoles(String userId);

  Future<bool> isAuthenticated();
}

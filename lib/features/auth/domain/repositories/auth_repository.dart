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

  Future<void> sendOtp({
    required String email,
  });

  Future<void> verifyOtp({
    required String email,
    required String code,
  });

  Future<User> signUp({
    required String email,
    required String password,
  });

  Future<void> requestPasswordRecovery({
    required String email,
  });

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<AuthTokens> refreshToken();

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<List<String>> getActiveRoles(String userId);

  Future<bool> isAuthenticated();
}

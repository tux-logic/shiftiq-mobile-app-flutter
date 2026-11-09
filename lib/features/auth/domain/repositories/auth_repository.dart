import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/aggregates/user_session.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/entities/user_account.dart';

/// Contract interface defining all authentication and user management
/// operations for the IAM Bounded Context following Clean Architecture.
abstract class AuthRepository {
  /// Authenticates user with registered email and password.
  Future<UserSession> login({
    required String email,
    required String password,
  });

  /// Authenticates or provisions user using a verified Google OAuth ID Token.
  Future<UserSession> loginWithGoogle({
    required String idToken,
  });

  /// Rotates the active refresh token for a new access & refresh token pair.
  Future<UserSession> refreshToken();

  /// Revokes active session tokens server-side and clears local storage.
  Future<void> logout();

  /// Requests a password recovery token email to the specified address.
  Future<void> requestPasswordRecovery({
    required String email,
  });

  /// Resets user password using the single-use recovery token.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Dispatches a 6-digit OTP code to the target email for verification.
  Future<void> sendOtp({
    required String email,
  });

  /// Verifies the 6-digit OTP code for the target email.
  Future<void> verifyOtp({
    required String email,
    required String code,
  });

  /// Registers a new user account with pre-verified email.
  Future<UserAccount> signUp({
    required String email,
    required String password,
  });

  /// Retrieves user account details by unique user identifier.
  Future<UserAccount> getUserById(String userId);

  /// Retrieves user account details by registered email address.
  Future<UserAccount> getUserByEmail(String email);

  /// Updates account email address and returns rotated session credentials.
  Future<UserSession> updateUserEmail({
    required String userId,
    required String newEmail,
  });

  /// Updates user password with current password verification.
  Future<void> updateUserPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });
}

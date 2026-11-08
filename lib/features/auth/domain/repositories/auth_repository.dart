import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/aggregates/user_session.dart';

/// Contract interface for authentication operations following DDD principles in IAM Context
abstract class AuthRepository {
  Future<UserSession> login({required String email, required String password});

  Future<UserSession> refreshToken();

  Future<void> logout();

  Future<void> recoverPassword(String email);
}


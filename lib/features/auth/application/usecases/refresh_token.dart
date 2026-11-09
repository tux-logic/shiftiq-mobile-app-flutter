import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';

/// Use case orchestrating single-use refresh token rotation.
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase({required this.repository});

  Future<UserSession> execute() {
    return repository.refreshToken();
  }
}

import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';

/// Use case orchestrating user login using email and password credentials.
class LoginWithPasswordUseCase {
  final AuthRepository repository;

  LoginWithPasswordUseCase({required this.repository});

  Future<UserSession> execute({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}

/// Backward compatibility alias for existing presentation layer components.
typedef LoginUseCase = LoginWithPasswordUseCase;

import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';

/// Use case orchestrating password recovery request via email.
class RequestPasswordRecoveryUseCase {
  final AuthRepository repository;

  RequestPasswordRecoveryUseCase({required this.repository});

  Future<void> execute({required String email}) {
    return repository.requestPasswordRecovery(email: email);
  }
}

/// Use case orchestrating password reset using a single-use recovery token.
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<void> execute({
    required String token,
    required String newPassword,
  }) {
    return repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}

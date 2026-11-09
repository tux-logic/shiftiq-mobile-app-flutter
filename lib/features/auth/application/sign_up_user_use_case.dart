import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/entities/user_account.dart';

/// Use case orchestrating new user account registration with pre-verified email.
class SignUpUserUseCase {
  final AuthRepository repository;

  SignUpUserUseCase({required this.repository});

  Future<UserAccount> execute({
    required String email,
    required String password,
  }) {
    return repository.signUp(email: email, password: password);
  }
}

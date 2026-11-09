import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';

/// Use case orchestrating Google OAuth Sign-In via verified Google ID Token.
class LoginWithGoogleUseCase {
  final AuthRepository repository;

  LoginWithGoogleUseCase({required this.repository});

  Future<UserSession> execute({required String idToken}) {
    return repository.loginWithGoogle(idToken: idToken);
  }
}

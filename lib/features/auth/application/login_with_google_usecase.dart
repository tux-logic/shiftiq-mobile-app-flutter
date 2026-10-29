import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final IAuthRepository repository;

  const LoginWithGoogleUseCase({required this.repository});

  Future<User> call({required String idToken}) {
    return repository.loginWithGoogle(idToken: idToken);
  }
}

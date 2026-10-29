import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final IAuthRepository repository;

  const LoginWithEmailUseCase({required this.repository});

  Future<User> call({required String email, required String password}) {
    return repository.loginWithEmail(email: email, password: password);
  }
}

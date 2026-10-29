import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final IAuthRepository repository;

  const SignUpUseCase({required this.repository});

  Future<User> call({required String email, required String password}) {
    return repository.signUp(email: email, password: password);
  }
}

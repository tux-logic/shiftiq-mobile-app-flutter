import '../../../../core/errors/failures.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/value_objects/email.dart';
import '../domain/value_objects/password.dart';

class LoginWithEmailUseCase {
  final IAuthRepository repository;

  const LoginWithEmailUseCase({required this.repository});

  Future<User> call({required String email, required String password}) {
    final emailVo = Email(email);
    final passwordVo = Password(password);

    if (!emailVo.isValid) {
      throw ValidationFailure(message: emailVo.errorMessage ?? 'Email inválido');
    }
    if (!passwordVo.isValid) {
      throw ValidationFailure(message: passwordVo.errorMessage ?? 'Contraseña inválida');
    }

    return repository.loginWithEmail(
      email: emailVo.value,
      password: passwordVo.value,
    );
  }
}

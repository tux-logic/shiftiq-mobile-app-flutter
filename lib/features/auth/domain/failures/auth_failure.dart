import '../../../../core/errors/failures.dart';

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    super.message = 'Credenciales incorrectas. Verifica tu correo y contraseña.',
    super.code = 'INVALID_CREDENTIALS',
  });
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({
    super.message = 'No se encontró una cuenta con estos datos.',
    super.code = 'USER_NOT_FOUND',
  });
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({
    super.message = 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.',
    super.code = 'SESSION_EXPIRED',
  });
}

class GoogleSignInCancelledFailure extends Failure {
  const GoogleSignInCancelledFailure({
    super.message = 'El inicio de sesión con Google fue cancelado.',
    super.code = 'GOOGLE_SIGN_IN_CANCELLED',
  });
}

class ServerAuthFailure extends Failure {
  const ServerAuthFailure({
    required super.message,
    super.code = 'SERVER_AUTH_ERROR',
  });
}

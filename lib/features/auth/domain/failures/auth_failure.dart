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

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({
    super.message = 'Este correo electrónico ya se encuentra registrado.',
    super.code = 'EMAIL_ALREADY_IN_USE',
  });
}

class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure({
    super.message = 'El código de verificación es incorrecto.',
    super.code = 'INVALID_OTP',
  });
}

class OtpExpiredFailure extends Failure {
  const OtpExpiredFailure({
    super.message = 'El código de verificación ha expirado. Solicita uno nuevo.',
    super.code = 'OTP_EXPIRED',
  });
}

class OtpRateLimitFailure extends Failure {
  const OtpRateLimitFailure({
    super.message = 'Has excedido el límite de envíos de código. Intenta más tarde.',
    super.code = 'RATE_LIMITED',
  });
}

class PasswordResetInvalidTokenFailure extends Failure {
  const PasswordResetInvalidTokenFailure({
    super.message = 'El token de recuperación no es válido o ha expirado.',
    super.code = 'INVALID_RESET_TOKEN',
  });
}

class ServerAuthFailure extends Failure {
  const ServerAuthFailure({
    required super.message,
    super.code = 'SERVER_AUTH_ERROR',
  });
}

/// Base class for all application exceptions in ShiftIQ Mobile
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AppException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

/// Thrown when an HTTP 401 Unauthorized occurs or JWT is invalid/expired
class AuthenticationException extends AppException {
  AuthenticationException({
    super.message = 'Sesión expirada o no autorizada. Inicie sesión nuevamente.',
    super.statusCode = 401,
    super.details,
  });
}

/// Thrown when an HTTP 403 Forbidden occurs (e.g. multi-tenancy violation)
class AccessDeniedException extends AppException {
  AccessDeniedException({
    super.message = 'No tiene permisos para acceder a esta sede o recurso.',
    super.statusCode = 403,
    super.details,
  });
}

/// Thrown when an HTTP 400 Bad Request / Validation error occurs
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.statusCode = 400,
    super.details,
  });
}

/// Thrown when an HTTP 404 Not Found occurs
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'El recurso solicitado no fue encontrado.',
    super.statusCode = 404,
    super.details,
  });
}

/// Thrown when an HTTP 409 Conflict occurs (e.g. duplicate resource or invalid state transition)
class ConflictException extends AppException {
  ConflictException({
    super.message = 'The operation conflicted with the current state of the resource.',
    super.statusCode = 409,
    super.details,
  });
}

/// Thrown when an HTTP 500+ Internal Server Error occurs
class ServerException extends AppException {
  ServerException({
    super.message = 'Ocurrió un error en el servidor. Intente nuevamente más tarde.',
    super.statusCode = 500,
    super.details,
  });
}

/// Thrown when there is no internet connection or a socket/network timeout occurs
class NetworkException extends AppException {
  NetworkException({
    super.message = 'No se pudo conectar con el servidor. Verifique su conexión a internet.',
    super.statusCode,
    super.details,
  });
}


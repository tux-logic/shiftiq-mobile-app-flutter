class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    this.statusCode,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Error de conexión de red.',
    super.code = 'NETWORK_ERROR',
  });
}

class CacheException extends AppException {
  const CacheException({
    super.message = 'Error en el almacenamiento de caché local.',
    super.code = 'CACHE_ERROR',
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Sesión no autorizada o expirada.',
    super.code = 'UNAUTHORIZED',
  });
}

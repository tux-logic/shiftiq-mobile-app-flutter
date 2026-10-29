import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No se pudo conectar al servidor. Revisa tu conexión a internet.',
    super.code = 'NETWORK_ERROR',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder al almacenamiento local seguro.',
    super.code = 'CACHE_ERROR',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code = 'VALIDATION_ERROR'});
}

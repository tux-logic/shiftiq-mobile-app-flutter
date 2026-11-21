import 'package:flutter/foundation.dart';

/// Represents the root API connectivity ping response.
@immutable
class PingResponse {
  final String status;
  final String app;
  final String docs;

  const PingResponse({
    required this.status,
    required this.app,
    required this.docs,
  });

  bool get isUp => status.toUpperCase() == 'UP';

  PingResponse copyWith({
    String? status,
    String? app,
    String? docs,
  }) {
    return PingResponse(
      status: status ?? this.status,
      app: app ?? this.app,
      docs: docs ?? this.docs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PingResponse &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          app == other.app &&
          docs == other.docs;

  @override
  int get hashCode => Object.hash(status, app, docs);

  @override
  String toString() => 'PingResponse(status: $status, app: $app, docs: $docs)';
}

/// Represents the platform system health probe status.
@immutable
class SystemHealth {
  final String status;

  const SystemHealth({
    required this.status,
  });

  bool get isHealthy => status.toUpperCase() == 'UP';

  SystemHealth copyWith({
    String? status,
  }) {
    return SystemHealth(
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemHealth &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() => 'SystemHealth(status: $status)';
}

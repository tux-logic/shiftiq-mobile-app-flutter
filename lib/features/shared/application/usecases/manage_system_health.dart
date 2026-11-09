import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/system_health.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/repositories/shared_repository.dart';

/// Application use case managing platform connectivity and system health probes.
class ManageSystemHealth {
  final SharedRepository repository;

  ManageSystemHealth({required this.repository});

  /// Pings the platform root endpoint to verify application reachability.
  Future<PingResponse> pingRoot() async {
    return repository.pingRoot();
  }

  /// Queries the health readiness check endpoint.
  Future<SystemHealth> checkHealth() async {
    return repository.checkHealth();
  }

  /// Verifies complete operational status across both ping and readiness probes.
  Future<bool> isPlatformOperational() async {
    try {
      final ping = await pingRoot();
      final health = await checkHealth();
      return ping.isUp && health.isHealthy;
    } catch (_) {
      return false;
    }
  }
}

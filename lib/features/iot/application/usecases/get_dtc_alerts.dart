import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to inspect, query, and resolve OBD-II diagnostic trouble code (DTC) alerts.
class GetDtcAlerts {
  final IotRepository repository;

  const GetDtcAlerts({required this.repository});

  /// Queries DTC fault alerts for a branch, filterable by status and severity.
  Future<List<DtcAlert>> execute({
    required String branchId,
    DtcStatus? status,
    DtcSeverity? severity,
    int page = 0,
    int size = 20,
  }) async {
    return repository.getDtcAlerts(
      branchId: branchId.trim(),
      status: status,
      severity: severity,
      page: page,
      size: size,
    );
  }

  /// Retrieves a specific DTC alert with freeze frame and AI diagnostic details.
  Future<DtcAlert> getById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Alert ID cannot be empty.');
    }

    return repository.getDtcAlertById(trimmedId);
  }

  /// Transitions the operational status of a DTC alert (e.g. active -> inInspection -> resolved).
  Future<DtcAlert> updateStatus({
    required String alertId,
    required DtcStatus newStatus,
  }) async {
    final trimmedId = alertId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Alert ID cannot be empty.');
    }

    return repository.updateDtcStatus(
      alertId: trimmedId,
      newStatus: newStatus,
    );
  }

  /// Retrieves all DTC alerts recorded for a specific vehicle.
  Future<List<DtcAlert>> getForVehicle({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    final trimmedId = vehicleId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }

    return repository.getVehicleDtcAlerts(
      vehicleId: trimmedId,
      page: page,
      size: size,
    );
  }
}

import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to pair, unpair, and inspect OBD-II scanner device-to-vehicle registrations.
class ManageObd2Registrations {
  final IotRepository repository;

  const ManageObd2Registrations({required this.repository});

  /// Pairs an available OBD2 device to a vehicle in the specified branch.
  Future<Obd2DeviceRegistration> linkDeviceToVehicle({
    required String obd2DeviceId,
    required String branchId,
    required String vehicleId,
  }) async {
    final trimmedDeviceId = obd2DeviceId.trim();
    final trimmedBranchId = branchId.trim();
    final trimmedVehicleId = vehicleId.trim();

    if (trimmedDeviceId.isEmpty) {
      throw ArgumentError('OBD2 Device ID cannot be empty.');
    }
    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }
    if (trimmedVehicleId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }

    return repository.linkObd2DeviceToVehicle(
      obd2DeviceId: trimmedDeviceId,
      branchId: trimmedBranchId,
      vehicleId: trimmedVehicleId,
    );
  }

  /// Transitions registration to INACTIVE to unpair scanner and free hardware device.
  Future<Obd2DeviceRegistration> unpairDevice(String registrationId) async {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Registration ID cannot be empty.');
    }

    return repository.updateObd2DeviceRegistrationStatus(
      registrationId: trimmedId,
      status: 'INACTIVE',
    );
  }

  /// Updates registration status directly.
  Future<Obd2DeviceRegistration> updateStatus({
    required String registrationId,
    required String status,
  }) async {
    final trimmedId = registrationId.trim();
    final trimmedStatus = status.trim().toUpperCase();

    if (trimmedId.isEmpty) {
      throw ArgumentError('Registration ID cannot be empty.');
    }
    if (trimmedStatus.isEmpty) {
      throw ArgumentError('Status cannot be empty.');
    }

    return repository.updateObd2DeviceRegistrationStatus(
      registrationId: trimmedId,
      status: trimmedStatus,
    );
  }

  /// Retrieves registrations for a branch, optionally filtered by status (ACTIVE / INACTIVE).
  Future<List<Obd2DeviceRegistration>> getRegistrations({
    required String branchId,
    String? status,
  }) async {
    final trimmedBranchId = branchId.trim();
    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }

    return repository.getObd2DeviceRegistrations(
      branchId: trimmedBranchId,
      status: status?.trim().toUpperCase(),
    );
  }

  /// Retrieves paginated historical telemetry snapshots associated with this registration.
  Future<List<TelemetrySnapshot>> getSnapshots({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Registration ID cannot be empty.');
    }

    return repository.getRegistrationTelemetrySnapshots(
      registrationId: trimmedId,
      page: page,
      size: size,
    );
  }

  /// Retrieves DTC trouble code alerts captured under this registration.
  Future<List<DtcAlert>> getDtcAlerts({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    final trimmedId = registrationId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Registration ID cannot be empty.');
    }

    return repository.getRegistrationDtcAlerts(
      registrationId: trimmedId,
      page: page,
      size: size,
    );
  }
}

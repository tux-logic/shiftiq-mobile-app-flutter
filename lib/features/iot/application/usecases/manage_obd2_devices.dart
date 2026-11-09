import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to manage physical OBD-II scanning hardware devices.
class ManageObd2Devices {
  final IotRepository repository;

  const ManageObd2Devices({required this.repository});

  /// Registers a new OBD2 scanner hardware device.
  Future<Obd2Device> register({
    required String branchId,
    required String macAddress,
  }) async {
    final trimmedBranchId = branchId.trim();
    final trimmedMac = macAddress.trim().toUpperCase();

    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }
    if (trimmedMac.isEmpty) {
      throw ArgumentError('MAC address cannot be empty.');
    }

    return repository.registerObd2Device(
      branchId: trimmedBranchId,
      macAddress: trimmedMac,
    );
  }

  /// Retrieves all OBD2 devices for a given branch, optionally filtered by status.
  Future<List<Obd2Device>> getDevices({
    required String branchId,
    String? status,
  }) async {
    final trimmedBranchId = branchId.trim();
    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }

    return repository.getObd2Devices(
      branchId: trimmedBranchId,
      status: status?.trim().toUpperCase(),
    );
  }

  /// Retrieves a specific OBD2 device by its unique identifier.
  Future<Obd2Device> getDeviceById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Device ID cannot be empty.');
    }

    return repository.getObd2DeviceById(trimmedId);
  }

  /// Updates an OBD2 device's network MAC address.
  Future<Obd2Device> updateDevice({
    required String id,
    required String macAddress,
  }) async {
    final trimmedId = id.trim();
    final trimmedMac = macAddress.trim().toUpperCase();

    if (trimmedId.isEmpty) {
      throw ArgumentError('Device ID cannot be empty.');
    }
    if (trimmedMac.isEmpty) {
      throw ArgumentError('MAC address cannot be empty.');
    }

    return repository.updateObd2Device(
      id: trimmedId,
      macAddress: trimmedMac,
    );
  }

  /// Deletes an OBD2 device by its unique identifier.
  Future<void> deleteDevice(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Device ID cannot be empty.');
    }

    return repository.deleteObd2Device(trimmedId);
  }
}

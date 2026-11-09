import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to retrieve real-time and historical vehicular telemetry snapshots.
class GetTelemetrySnapshots {
  final IotRepository repository;

  const GetTelemetrySnapshots({required this.repository});

  /// Retrieves the latest telemetry snapshot for a physical OBD2 device.
  Future<TelemetrySnapshot> getLatest(String deviceId) async {
    final trimmedId = deviceId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Device ID cannot be empty.');
    }

    return repository.getLatestTelemetrySnapshot(trimmedId);
  }

  /// Retrieves paginated historical snapshots for a vehicle.
  Future<List<TelemetrySnapshot>> getForVehicle({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    final trimmedId = vehicleId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }

    return repository.getVehicleTelemetrySnapshots(
      vehicleId: trimmedId,
      page: page,
      size: size,
    );
  }

  /// Retrieves live sensor readings for UI monitoring components.
  Future<List<LiveSensorReading>> getLiveSensors(String vehicleId) async {
    final trimmedId = vehicleId.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }

    return repository.getLiveSensorReadings(trimmedId);
  }

  /// Streams real-time live sensor updates for a branch.
  Stream<List<LiveSensorReading>> getLiveStream(String branchId) {
    return repository.getLiveSensorStream(branchId.trim());
  }
}

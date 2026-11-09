import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to validate and ingest bulk vehicular telemetry batches from OBD2 scanners.
class IngestTelemetryBatch {
  final IotRepository repository;

  const IngestTelemetryBatch({required this.repository});

  /// Ingests a bulk batch of up to 100 snapshots, validating chronological and odometer integrity.
  Future<void> execute(TelemetryBatch batch) async {
    final trimmedDeviceId = batch.obd2DeviceId.trim();
    if (trimmedDeviceId.isEmpty) {
      throw ArgumentError('OBD2 Device ID cannot be empty.');
    }
    if (batch.snapshots.isEmpty) {
      throw ArgumentError('Telemetry batch must contain at least 1 snapshot.');
    }
    if (batch.snapshots.length > 100) {
      throw ArgumentError('Telemetry batch cannot exceed maximum of 100 snapshots.');
    }

    // Validate non-decreasing odometer progression
    double? lastOdometer;
    for (final snapshot in batch.snapshots) {
      if (lastOdometer != null && snapshot.odometerKm < lastOdometer) {
        throw ArgumentError(
          'Odometer reading cannot decrease: ${snapshot.odometerKm} < $lastOdometer.',
        );
      }
      lastOdometer = snapshot.odometerKm;
    }

    await repository.ingestTelemetryBatch(batch);
  }
}

/// A single DTC fault item within a telemetry batch snapshot.
class TelemetryBatchDtcCode {
  final String dtcCode;
  final String description;
  final String severity;

  const TelemetryBatchDtcCode({
    required this.dtcCode,
    required this.description,
    required this.severity,
  });
}

/// A single sensor snapshot entry within a bulk telemetry batch.
class TelemetryBatchItem {
  final int rpm;
  final int temperature;
  final double speedKmh;
  final double odometerKm;
  final double fuelLevelPercent;
  final DateTime createdAt;
  final List<TelemetryBatchDtcCode> dtcCodes;

  const TelemetryBatchItem({
    required this.rpm,
    required this.temperature,
    required this.speedKmh,
    required this.odometerKm,
    required this.fuelLevelPercent,
    required this.createdAt,
    this.dtcCodes = const [],
  });
}

/// Container aggregate for bulk offline telemetry transmission.
class TelemetryBatch {
  final String obd2DeviceId;
  final List<TelemetryBatchItem> snapshots;

  const TelemetryBatch({
    required this.obd2DeviceId,
    required this.snapshots,
  });
}

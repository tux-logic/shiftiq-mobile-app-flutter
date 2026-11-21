/// Entity representing an instantaneous sensor reading snapshot from vehicle telemetry.
class TelemetrySnapshot {
  final String id;
  final String? obd2DeviceRegistrationId;
  final String? branchId;
  final int rpm;
  final int temperature;
  final double speedKmh;
  final double odometerKm;
  final double fuelLevelPercent;
  final DateTime createdAt;

  const TelemetrySnapshot({
    required this.id,
    this.obd2DeviceRegistrationId,
    this.branchId,
    required this.rpm,
    required this.temperature,
    required this.speedKmh,
    required this.odometerKm,
    required this.fuelLevelPercent,
    required this.createdAt,
  });

  bool get isOverheating => temperature > 105;
  bool get isHighRpm => rpm > 5000;
  bool get isLowFuel => fuelLevelPercent < 15.0;

  TelemetrySnapshot copyWith({
    String? id,
    String? obd2DeviceRegistrationId,
    String? branchId,
    int? rpm,
    int? temperature,
    double? speedKmh,
    double? odometerKm,
    double? fuelLevelPercent,
    DateTime? createdAt,
  }) {
    return TelemetrySnapshot(
      id: id ?? this.id,
      obd2DeviceRegistrationId:
          obd2DeviceRegistrationId ?? this.obd2DeviceRegistrationId,
      branchId: branchId ?? this.branchId,
      rpm: rpm ?? this.rpm,
      temperature: temperature ?? this.temperature,
      speedKmh: speedKmh ?? this.speedKmh,
      odometerKm: odometerKm ?? this.odometerKm,
      fuelLevelPercent: fuelLevelPercent ?? this.fuelLevelPercent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

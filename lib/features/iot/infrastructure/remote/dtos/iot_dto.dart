import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';

/// Serialization and deserialization utilities for the IoT Bounded Context data transfer objects.
class IotDto {
  IotDto._();

  /// Deserializes a [Vehicle] entity using Dart 3 pattern matching.
  static Vehicle vehicleFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'plateNumber': final String plate,
        'brand': final String brand,
        'model': final String model,
        'year': final int year,
        'vin': final String vin,
      } =>
        Vehicle(
          id: id,
          plateNumber: plate,
          brand: brand,
          model: model,
          year: year,
          vin: vin,
          photoUrl: json['photoUrl'] as String?,
          customerId: json['customerId'] as String?,
        ),
      _ => throw const FormatException('Invalid Vehicle JSON payload: missing required fields'),
    };
  }

  /// Deserializes a list of [Vehicle] entities.
  static List<Vehicle> vehicleListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(vehicleFromJson)
        .toList();
  }

  /// Deserializes an [Obd2Device] entity using Dart 3 pattern matching.
  static Obd2Device obd2DeviceFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'branchId': final String branchId,
        'macAddress': final String mac,
      } =>
        Obd2Device(
          id: id,
          branchId: branchId,
          macAddress: mac,
          status: Obd2DeviceStatus.fromString(json['status'] as String? ?? 'AVAILABLE'),
        ),
      _ => throw const FormatException('Invalid Obd2Device JSON payload: missing required fields'),
    };
  }

  /// Deserializes a list of [Obd2Device] entities.
  static List<Obd2Device> obd2DeviceListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(obd2DeviceFromJson)
        .toList();
  }

  /// Deserializes an [Obd2DeviceRegistration] entity using Dart 3 pattern matching.
  static Obd2DeviceRegistration obd2RegistrationFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'obd2DeviceId': final String deviceId,
        'branchId': final String branchId,
        'vehicleId': final String vehicleId,
      } =>
        Obd2DeviceRegistration(
          id: id,
          obd2DeviceId: deviceId,
          branchId: branchId,
          vehicleId: vehicleId,
          status: json['status'] as String? ?? 'ACTIVE',
          createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        ),
      _ => throw const FormatException('Invalid Obd2DeviceRegistration JSON payload'),
    };
  }

  /// Deserializes a list of [Obd2DeviceRegistration] entities.
  static List<Obd2DeviceRegistration> obd2RegistrationListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(obd2RegistrationFromJson)
        .toList();
  }

  /// Deserializes a [TelemetrySnapshot] entity.
  static TelemetrySnapshot telemetrySnapshotFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
      } =>
        TelemetrySnapshot(
          id: id,
          obd2DeviceRegistrationId: json['obd2DeviceRegistrationId'] as String?,
          branchId: json['branchId'] as String?,
          rpm: (json['rpm'] as num?)?.toInt() ?? 0,
          temperature: (json['temperature'] as num?)?.toInt() ?? 0,
          speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 0.0,
          odometerKm: (json['odometerKm'] as num?)?.toDouble() ?? 0.0,
          fuelLevelPercent: (json['fuelLevelPercent'] as num?)?.toDouble() ?? 0.0,
          createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        ),
      _ => throw const FormatException('Invalid TelemetrySnapshot JSON payload'),
    };
  }

  /// Deserializes a list of [TelemetrySnapshot] entities.
  static List<TelemetrySnapshot> telemetrySnapshotListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(telemetrySnapshotFromJson)
        .toList();
  }

  /// Deserializes a [DtcAlert] entity.
  static DtcAlert dtcAlertFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
      } =>
        DtcAlert(
          id: id,
          branchId: json['branchId'] as String? ?? '',
          vehicleId: json['vehicleId'] as String? ?? '',
          vehiclePlate: json['vehiclePlate'] as String? ?? 'S/P',
          vehicleModel: json['vehicleModel'] as String? ?? 'Vehículo General',
          customerName: json['customerName'] as String? ?? 'Cliente del Taller',
          code: json['dtcCode'] as String? ?? json['code'] as String? ?? 'P0000',
          description: json['description'] as String? ?? '',
          systemCategory: json['systemCategory'] as String? ?? 'General Engine',
          severity: _parseSeverity(json['severity']),
          aiDiagnosticRecommendation: json['aiDiagnosticRecommendation'] as String? ??
              'Realizar escaneo computarizado preventivo.',
          detectedAt: DateTime.tryParse(
                json['createdAt'] as String? ?? json['detectedAt'] as String? ?? '',
              ) ??
              DateTime.now(),
          status: _parseStatus(json['status']),
          freezeFrame: (json['freezeFrame'] as Map?)?.map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              ) ??
              const {},
        ),
      _ => throw const FormatException('Invalid DtcAlert JSON payload'),
    };
  }

  /// Deserializes a list of [DtcAlert] entities.
  static List<DtcAlert> dtcAlertListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(dtcAlertFromJson)
        .toList();
  }

  /// Serializes a [TelemetryBatch] to a JSON payload.
  static Map<String, dynamic> telemetryBatchToJson(TelemetryBatch batch) {
    return {
      'obd2DeviceId': batch.obd2DeviceId,
      'snapshots': batch.snapshots
          .map((s) => {
                'rpm': s.rpm,
                'temperature': s.temperature,
                'speedKmh': s.speedKmh,
                'odometerKm': s.odometerKm,
                'fuelLevelPercent': s.fuelLevelPercent,
                'createdAt': s.createdAt.toIso8601String(),
                'dtcCodes': s.dtcCodes
                    .map((d) => {
                          'dtcCode': d.dtcCode,
                          'description': d.description,
                          'severity': d.severity.toUpperCase(),
                        })
                    .toList(),
              })
          .toList(),
    };
  }

  static DtcSeverity _parseSeverity(dynamic severity) {
    return DtcSeverity.fromString(severity?.toString());
  }

  static DtcStatus _parseStatus(dynamic status) {
    return DtcStatus.fromString(status?.toString());
  }
}

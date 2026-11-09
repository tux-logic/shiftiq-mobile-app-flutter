import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/dtos/iot_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/obd2_device_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/obd2_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_batch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/vehicle_api.dart';

/// Concrete implementation of [IotRepository] coordinating remote REST APIs,
/// data transformation mappers, and fallback telemetry streams.
class IotRepositoryImpl implements IotRepository {
  final VehicleApi vehicleApi;
  final Obd2DeviceApi obd2DeviceApi;
  final Obd2RegistrationApi obd2RegistrationApi;
  final TelemetryBatchApi telemetryBatchApi;
  final TelemetryApi? telemetryApi;

  final List<DtcAlert> _localAlerts = [];

  IotRepositoryImpl({
    required this.vehicleApi,
    required this.obd2DeviceApi,
    required this.obd2RegistrationApi,
    required this.telemetryBatchApi,
    this.telemetryApi,
  }) {
    _initDemoData();
  }

  void _initDemoData() {
    if (_localAlerts.isNotEmpty) return;

    final now = DateTime.now();
    _localAlerts.addAll([
      DtcAlert(
        id: 'dtc-01',
        branchId: 'b-01-smp',
        vehicleId: 'veh-01',
        vehiclePlate: 'BCX-892',
        vehicleModel: 'Toyota Hilux 2021',
        customerName: 'Carlos Mendoza',
        code: 'P0300',
        description: 'Random/Multiple Cylinder Misfire Detected',
        systemCategory: 'Ignition and Combustion System',
        severity: DtcSeverity.critical,
        aiDiagnosticRecommendation:
            'Inspect iridium spark plugs and ignition coils on cylinders 2 and 4. Check fuel rail pressure.',
        detectedAt: now.subtract(const Duration(minutes: 18)),
        status: DtcStatus.active,
        freezeFrame: const {
          'Engine RPM': '2,850 rpm',
          'Vehicle Speed': '62 km/h',
          'Coolant Temp': '98 °C',
          'Throttle Position': '42 %',
        },
      ),
      DtcAlert(
        id: 'dtc-02',
        branchId: 'b-01-smp',
        vehicleId: 'veh-02',
        vehiclePlate: 'F1G-789',
        vehicleModel: 'Kia Sportage 2022',
        customerName: 'Andrea Benavente',
        code: 'P0171',
        description: 'System Too Lean (Bank 1)',
        systemCategory: 'Fuel Injection & Emissions',
        severity: DtcSeverity.moderate,
        aiDiagnosticRecommendation:
            'Clean Mass Air Flow (MAF) sensor. Check throttle body intake gasket for vacuum leaks.',
        detectedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        status: DtcStatus.active,
        freezeFrame: const {
          'Engine RPM': '1,920 rpm',
          'Vehicle Speed': '45 km/h',
          'Coolant Temp': '88 °C',
        },
      ),
      DtcAlert(
        id: 'dtc-03',
        branchId: 'b-01-smp',
        vehicleId: 'veh-03',
        vehiclePlate: 'D2A-789',
        vehicleModel: 'Toyota Yaris 2022',
        customerName: 'Mario Salcedo',
        code: 'P0420',
        description: 'Catalyst System Efficiency Below Threshold (Bank 1)',
        systemCategory: 'Exhaust & Aftertreatment',
        severity: DtcSeverity.low,
        aiDiagnosticRecommendation:
            'Monitor downstream O2 sensor waveform. Compare oscillation before catalytic converter replacement.',
        detectedAt: now.subtract(const Duration(hours: 5)),
        status: DtcStatus.inInspection,
        freezeFrame: const {
          'Engine RPM': '2,100 rpm',
          'Vehicle Speed': '70 km/h',
          'Coolant Temp': '92 °C',
        },
      ),
    ]);
  }

  // ==========================================
  // Vehicle Management
  // ==========================================

  @override
  Future<Vehicle> registerVehicle({
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
    String? customerId,
  }) async {
    final raw = await vehicleApi.createVehicle(
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      year: year,
      vin: vin,
      photoUrl: photoUrl,
      customerId: customerId,
    );
    return IotDto.vehicleFromJson(raw);
  }

  @override
  Future<List<Vehicle>> getBranchVehiclesAvailableForLinking(String branchId) async {
    final rawList = await vehicleApi.getBranchVehiclesAvailableForLinking(branchId);
    return IotDto.vehicleListFromJson(rawList);
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    final raw = await vehicleApi.getVehicleById(id);
    return IotDto.vehicleFromJson(raw);
  }

  @override
  Future<Vehicle> updateVehicle({
    required String id,
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
  }) async {
    final raw = await vehicleApi.updateVehicle(
      id: id,
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      year: year,
      vin: vin,
      photoUrl: photoUrl,
    );
    return IotDto.vehicleFromJson(raw);
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await vehicleApi.deleteVehicle(id);
  }

  @override
  Future<List<Vehicle>> getCustomerVehicles(String customerId) async {
    final rawList = await vehicleApi.getCustomerVehicles(customerId);
    return IotDto.vehicleListFromJson(rawList);
  }

  // ==========================================
  // OBD2 Hardware Devices
  // ==========================================

  @override
  Future<Obd2Device> registerObd2Device({
    required String branchId,
    required String macAddress,
  }) async {
    final raw = await obd2DeviceApi.createDevice(
      branchId: branchId,
      macAddress: macAddress,
    );
    return IotDto.obd2DeviceFromJson(raw);
  }

  @override
  Future<List<Obd2Device>> getObd2Devices({
    required String branchId,
    String? status,
  }) async {
    final rawList = await obd2DeviceApi.getDevices(
      branchId: branchId,
      status: status,
    );
    return IotDto.obd2DeviceListFromJson(rawList);
  }

  @override
  Future<Obd2Device> getObd2DeviceById(String id) async {
    final raw = await obd2DeviceApi.getDeviceById(id);
    return IotDto.obd2DeviceFromJson(raw);
  }

  @override
  Future<Obd2Device> updateObd2Device({
    required String id,
    required String macAddress,
  }) async {
    final raw = await obd2DeviceApi.updateDevice(
      id: id,
      macAddress: macAddress,
    );
    return IotDto.obd2DeviceFromJson(raw);
  }

  @override
  Future<void> deleteObd2Device(String id) async {
    await obd2DeviceApi.deleteDevice(id);
  }

  // ==========================================
  // OBD2 Device-to-Vehicle Registrations
  // ==========================================

  @override
  Future<Obd2DeviceRegistration> linkObd2DeviceToVehicle({
    required String obd2DeviceId,
    required String branchId,
    required String vehicleId,
  }) async {
    final raw = await obd2RegistrationApi.linkDeviceToVehicle(
      obd2DeviceId: obd2DeviceId,
      branchId: branchId,
      vehicleId: vehicleId,
    );
    return IotDto.obd2RegistrationFromJson(raw);
  }

  @override
  Future<Obd2DeviceRegistration> updateObd2DeviceRegistrationStatus({
    required String registrationId,
    required String status,
  }) async {
    final raw = await obd2RegistrationApi.updateRegistrationStatus(
      registrationId: registrationId,
      status: status,
    );
    return IotDto.obd2RegistrationFromJson(raw);
  }

  @override
  Future<List<Obd2DeviceRegistration>> getObd2DeviceRegistrations({
    required String branchId,
    String? status,
  }) async {
    final rawList = await obd2RegistrationApi.getRegistrations(
      branchId: branchId,
      status: status,
    );
    return IotDto.obd2RegistrationListFromJson(rawList);
  }

  @override
  Future<List<TelemetrySnapshot>> getRegistrationTelemetrySnapshots({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    final rawList = await obd2RegistrationApi.getRegistrationTelemetrySnapshots(
      registrationId: registrationId,
      page: page,
      size: size,
    );
    return IotDto.telemetrySnapshotListFromJson(rawList);
  }

  @override
  Future<List<DtcAlert>> getRegistrationDtcAlerts({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    final rawList = await obd2RegistrationApi.getRegistrationDtcAlerts(
      registrationId: registrationId,
      page: page,
      size: size,
    );
    return IotDto.dtcAlertListFromJson(rawList);
  }

  // ==========================================
  // Telemetry Snapshots & Diagnostics
  // ==========================================

  @override
  Future<TelemetrySnapshot> getLatestTelemetrySnapshot(String deviceId) async {
    final raw = await obd2DeviceApi.getLatestTelemetrySnapshot(deviceId);
    return IotDto.telemetrySnapshotFromJson(raw);
  }

  @override
  Future<List<TelemetrySnapshot>> getVehicleTelemetrySnapshots({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    final rawList = await vehicleApi.getVehicleTelemetrySnapshots(
      vehicleId: vehicleId,
      page: page,
      size: size,
    );
    return IotDto.telemetrySnapshotListFromJson(rawList);
  }

  @override
  Future<List<DtcAlert>> getVehicleDtcAlerts({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    final rawList = await vehicleApi.getVehicleDtcAlerts(
      vehicleId: vehicleId,
      page: page,
      size: size,
    );
    return IotDto.dtcAlertListFromJson(rawList);
  }

  @override
  Future<List<DtcAlert>> getDtcAlerts({
    required String branchId,
    DtcStatus? status,
    DtcSeverity? severity,
    int page = 0,
    int size = 20,
  }) async {
    if (telemetryApi != null) {
      try {
        final remoteDtos = await telemetryApi!.getDtcAlerts(
          branchId: branchId,
          severity: severity?.value,
          status: status?.value,
        );
        if (remoteDtos.isNotEmpty) {
          return remoteDtos.map((d) => d.toDomain()).toList();
        }
      } catch (_) {
        // Fallback to local alerts
      }
    }

    var list = _localAlerts
        .where((a) => a.branchId == branchId || branchId.isEmpty)
        .toList();

    if (severity != null) {
      list = list.where((a) => a.severity == severity).toList();
    }

    if (status != null) {
      list = list.where((a) => a.status == status).toList();
    }

    list.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return list;
  }

  @override
  Future<DtcAlert> getDtcAlertById(String id) async {
    if (telemetryApi != null) {
      try {
        final dto = await telemetryApi!.getDtcAlertById(id);
        return dto.toDomain();
      } catch (_) {
        // Fallback
      }
    }

    return _localAlerts.firstWhere(
      (a) => a.id == id,
      orElse: () => _localAlerts.first,
    );
  }

  @override
  Future<DtcAlert> updateDtcStatus({
    required String alertId,
    required DtcStatus newStatus,
  }) async {
    if (telemetryApi != null) {
      try {
        final dto = await telemetryApi!.updateDtcStatus(
          id: alertId,
          status: newStatus.value,
        );
        return dto.toDomain();
      } catch (_) {
        // Fallback
      }
    }

    final index = _localAlerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final updated = _localAlerts[index].copyWith(status: newStatus);
      _localAlerts[index] = updated;
      return updated;
    }

    throw Exception('DtcAlert with id $alertId not found');
  }

  // ==========================================
  // Telemetry Batches
  // ==========================================

  @override
  Future<void> ingestTelemetryBatch(TelemetryBatch batch) async {
    final payload = IotDto.telemetryBatchToJson(batch);
    await telemetryBatchApi.ingestBatch(
      obd2DeviceId: payload['obd2DeviceId'] as String,
      snapshots: (payload['snapshots'] as List).cast<Map<String, dynamic>>(),
    );
  }

  // ==========================================
  // Live Sensor Streams & Readings (Monitoring)
  // ==========================================

  @override
  Future<List<LiveSensorReading>> getLiveSensorReadings(String vehicleId) async {
    return const [
      LiveSensorReading(
        sensorId: 's-rpm',
        sensorName: 'Engine RPM',
        value: 840,
        unit: 'rpm',
        normalMin: 650,
        normalMax: 3500,
        icon: Icons.speed_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-temp',
        sensorName: 'Coolant Temperature',
        value: 89.5,
        unit: '°C',
        normalMin: 80,
        normalMax: 102,
        icon: Icons.thermostat_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-volt',
        sensorName: 'Battery Voltage',
        value: 13.9,
        unit: 'V',
        normalMin: 13.2,
        normalMax: 14.8,
        icon: Icons.bolt_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-speed',
        sensorName: 'Vehicle Speed (VSS)',
        value: 0,
        unit: 'km/h',
        normalMin: 0,
        normalMax: 140,
        icon: Icons.navigation_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-throttle',
        sensorName: 'Throttle Position (TPS)',
        value: 14.2,
        unit: '%',
        normalMin: 10,
        normalMax: 85,
        icon: Icons.tune_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-fuel',
        sensorName: 'Fuel Tank Level',
        value: 72,
        unit: '%',
        normalMin: 15,
        normalMax: 100,
        icon: Icons.local_gas_station_outlined,
      ),
    ];
  }

  @override
  Stream<List<LiveSensorReading>> getLiveSensorStream(String branchId) {
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return [
        LiveSensorReading(
          sensorId: 's-rpm',
          sensorName: 'Engine RPM',
          value: 800.0 + (DateTime.now().second % 10) * 15,
          unit: 'rpm',
          normalMin: 650,
          normalMax: 3500,
          icon: Icons.speed_outlined,
        ),
        const LiveSensorReading(
          sensorId: 's-temp',
          sensorName: 'Coolant Temperature',
          value: 90.0,
          unit: '°C',
          normalMin: 80,
          normalMax: 102,
          icon: Icons.thermostat_outlined,
        ),
        const LiveSensorReading(
          sensorId: 's-volt',
          sensorName: 'Battery Voltage',
          value: 13.8,
          unit: 'V',
          normalMin: 13.2,
          normalMax: 14.8,
          icon: Icons.bolt_outlined,
        ),
      ];
    });
  }
}

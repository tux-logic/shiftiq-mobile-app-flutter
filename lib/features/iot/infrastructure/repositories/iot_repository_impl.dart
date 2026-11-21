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

/// Concrete implementation of [IotRepository] coordinating remote REST APIs
/// and domain transformation mappers.
class IotRepositoryImpl implements IotRepository {
  final VehicleApi vehicleApi;
  final Obd2DeviceApi obd2DeviceApi;
  final Obd2RegistrationApi obd2RegistrationApi;
  final TelemetryBatchApi telemetryBatchApi;
  final TelemetryApi? telemetryApi;

  IotRepositoryImpl({
    required this.vehicleApi,
    required this.obd2DeviceApi,
    required this.obd2RegistrationApi,
    required this.telemetryBatchApi,
    this.telemetryApi,
  });

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
      status: status ?? 'ACTIVE',
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
    if (branchId.isEmpty) return const [];

    final registrations = await obd2RegistrationApi.getRegistrations(
      branchId: branchId,
      status: 'ACTIVE',
    );

    final List<DtcAlert> remoteAlerts = [];
    for (final reg in registrations) {
      if (reg is Map<String, dynamic> && reg['id'] != null) {
        final regId = reg['id'].toString();
        final rawDtcList = await obd2RegistrationApi.getRegistrationDtcAlerts(
          registrationId: regId,
        );
        final alerts = IotDto.dtcAlertListFromJson(rawDtcList);
        remoteAlerts.addAll(alerts);
      }
    }

    var list = remoteAlerts;
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
    throw Exception('DtcAlert lookup by ID is not supported without branch context: $id');
  }

  @override
  Future<DtcAlert> updateDtcStatus({
    required String alertId,
    required DtcStatus newStatus,
  }) async {
    throw UnimplementedError('DTC status update endpoint is not available for alertId=$alertId');
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

  List<LiveSensorReading> _mapSnapshotToSensors(TelemetrySnapshot snapshot) {
    return [
      LiveSensorReading(
        sensorId: 's-rpm',
        sensorName: 'Engine RPM',
        value: snapshot.rpm.toDouble(),
        unit: 'rpm',
        normalMin: 650,
        normalMax: 3500,
        icon: Icons.speed_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-temp',
        sensorName: 'Coolant Temperature',
        value: snapshot.temperature.toDouble(),
        unit: '°C',
        normalMin: 80,
        normalMax: 102,
        icon: Icons.thermostat_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-speed',
        sensorName: 'Vehicle Speed (VSS)',
        value: snapshot.speedKmh,
        unit: 'km/h',
        normalMin: 0,
        normalMax: 140,
        icon: Icons.navigation_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-odom',
        sensorName: 'Odometer',
        value: snapshot.odometerKm,
        unit: 'km',
        normalMin: 0,
        normalMax: 500000,
        icon: Icons.route_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-fuel',
        sensorName: 'Fuel Tank Level',
        value: snapshot.fuelLevelPercent,
        unit: '%',
        normalMin: 15,
        normalMax: 100,
        icon: Icons.local_gas_station_outlined,
      ),
    ];
  }

  @override
  Future<List<LiveSensorReading>> getLiveSensorReadings(String vehicleId) async {
    if (vehicleId.isEmpty) return const [];
    final snapshots = await getVehicleTelemetrySnapshots(
      vehicleId: vehicleId,
      page: 0,
      size: 1,
    );
    if (snapshots.isEmpty) return const [];
    return _mapSnapshotToSensors(snapshots.first);
  }

  @override
  Stream<List<LiveSensorReading>> getLiveSensorStream(String branchId) async* {
    while (true) {
      if (branchId.isEmpty) {
        yield const [];
      } else {
        final registrations = await obd2RegistrationApi.getRegistrations(
          branchId: branchId,
          status: 'ACTIVE',
        );
        List<LiveSensorReading> readings = const [];
        for (final reg in registrations) {
          if (reg is Map<String, dynamic> && reg['id'] != null) {
            final snapshots = await getRegistrationTelemetrySnapshots(
              registrationId: reg['id'].toString(),
              page: 0,
              size: 1,
            );
            if (snapshots.isNotEmpty) {
              readings = _mapSnapshotToSensors(snapshots.first);
              break;
            }
          }
        }
        yield readings;
      }
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  }
}

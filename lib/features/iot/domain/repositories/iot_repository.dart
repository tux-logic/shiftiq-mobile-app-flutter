import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';

/// Contract interface defining data access and operations for the IoT Bounded Context.
abstract class IotRepository {
  // --- Vehicles ---
  Future<Vehicle> registerVehicle({
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
    String? customerId,
  });

  Future<List<Vehicle>> getBranchVehiclesAvailableForLinking(String branchId);

  Future<Vehicle> getVehicleById(String id);

  Future<Vehicle> updateVehicle({
    required String id,
    required String plateNumber,
    required String brand,
    required String model,
    required int year,
    required String vin,
    String? photoUrl,
  });

  Future<void> deleteVehicle(String id);

  Future<List<Vehicle>> getCustomerVehicles(String customerId);

  // --- OBD2 Hardware Devices ---
  Future<Obd2Device> registerObd2Device({
    required String branchId,
    required String macAddress,
  });

  Future<List<Obd2Device>> getObd2Devices({
    required String branchId,
    String? status,
  });

  Future<Obd2Device> getObd2DeviceById(String id);

  Future<Obd2Device> updateObd2Device({
    required String id,
    required String macAddress,
  });

  Future<void> deleteObd2Device(String id);

  // --- OBD2 Device-to-Vehicle Registrations (Pairing) ---
  Future<Obd2DeviceRegistration> linkObd2DeviceToVehicle({
    required String obd2DeviceId,
    required String branchId,
    required String vehicleId,
  });

  Future<Obd2DeviceRegistration> updateObd2DeviceRegistrationStatus({
    required String registrationId,
    required String status,
  });

  Future<List<Obd2DeviceRegistration>> getObd2DeviceRegistrations({
    required String branchId,
    String? status,
  });

  Future<List<TelemetrySnapshot>> getRegistrationTelemetrySnapshots({
    required String registrationId,
    int page = 0,
    int size = 20,
  });

  Future<List<DtcAlert>> getRegistrationDtcAlerts({
    required String registrationId,
    int page = 0,
    int size = 20,
  });

  // --- Telemetry Snapshots & Diagnostics ---
  Future<TelemetrySnapshot> getLatestTelemetrySnapshot(String deviceId);

  Future<List<TelemetrySnapshot>> getVehicleTelemetrySnapshots({
    required String vehicleId,
    int page = 0,
    int size = 20,
  });

  Future<List<DtcAlert>> getVehicleDtcAlerts({
    required String vehicleId,
    int page = 0,
    int size = 20,
  });

  Future<List<DtcAlert>> getDtcAlerts({
    required String branchId,
    DtcStatus? status,
    DtcSeverity? severity,
    int page = 0,
    int size = 20,
  });

  Future<DtcAlert> getDtcAlertById(String id);

  Future<DtcAlert> updateDtcStatus({
    required String alertId,
    required DtcStatus newStatus,
  });

  // --- Telemetry Batches ---
  Future<void> ingestTelemetryBatch(TelemetryBatch batch);

  // --- Live Sensor Stream & Readings (Monitoring compatibility) ---
  Future<List<LiveSensorReading>> getLiveSensorReadings(String vehicleId);
  Stream<List<LiveSensorReading>> getLiveSensorStream(String branchId);
}

/// Backward compatibility alias.
typedef TelemetryRepository = IotRepository;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/iot_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';

class FakeIotRepository implements IotRepository {
  final List<Vehicle> vehicles = [
    const Vehicle(
      id: 'veh-01',
      plateNumber: 'BCX-892',
      brand: 'Toyota',
      model: 'Hilux',
      year: 2021,
      vin: '1HGCR2F83HA000001',
      customerId: 'cust-01',
    ),
    const Vehicle(
      id: 'veh-02',
      plateNumber: 'F1G-789',
      brand: 'Kia',
      model: 'Sportage',
      year: 2022,
      vin: '1HGCR2F83HA000002',
      customerId: 'cust-02',
    ),
  ];

  final List<Obd2Device> devices = [
    const Obd2Device(
      id: 'dev-01',
      branchId: 'b-01',
      macAddress: 'AA:BB:CC:DD:EE:01',
      status: Obd2DeviceStatus.available,
    ),
    const Obd2Device(
      id: 'dev-02',
      branchId: 'b-01',
      macAddress: 'AA:BB:CC:DD:EE:02',
      status: Obd2DeviceStatus.linked,
    ),
  ];

  final List<Obd2DeviceRegistration> registrations = [
    Obd2DeviceRegistration(
      id: 'reg-01',
      obd2DeviceId: 'dev-02',
      branchId: 'b-01',
      vehicleId: 'veh-01',
      status: 'ACTIVE',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final List<DtcAlert> dtcAlerts = [
    DtcAlert(
      id: 'dtc-01',
      branchId: 'b-01',
      vehicleId: 'veh-01',
      vehiclePlate: 'BCX-892',
      vehicleModel: 'Toyota Hilux 2021',
      customerName: 'Carlos Mendoza',
      code: 'P0300',
      description: 'Random Cylinder Misfire Detected',
      systemCategory: 'Ignition System',
      severity: DtcSeverity.critical,
      aiDiagnosticRecommendation: 'Check spark plugs and coils.',
      detectedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      status: DtcStatus.active,
      freezeFrame: const {'Engine RPM': '2,850 rpm'},
    ),
    DtcAlert(
      id: 'dtc-02',
      branchId: 'b-01',
      vehicleId: 'veh-02',
      vehiclePlate: 'F1G-789',
      vehicleModel: 'Kia Sportage 2022',
      customerName: 'Andrea Benavente',
      code: 'P0171',
      description: 'System Too Lean Bank 1',
      systemCategory: 'Fuel System',
      severity: DtcSeverity.moderate,
      aiDiagnosticRecommendation: 'Clean MAF sensor.',
      detectedAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DtcStatus.active,
    ),
  ];

  final List<TelemetryBatch> ingestedBatches = [];

  // --- Vehicles ---
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
    final newVehicle = Vehicle(
      id: 'veh-${vehicles.length + 1}',
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      year: year,
      vin: vin,
      photoUrl: photoUrl,
      customerId: customerId,
    );
    vehicles.add(newVehicle);
    return newVehicle;
  }

  @override
  Future<List<Vehicle>> getBranchVehiclesAvailableForLinking(String branchId) async {
    return vehicles;
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    return vehicles.firstWhere((v) => v.id == id);
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
    final idx = vehicles.indexWhere((v) => v.id == id);
    if (idx == -1) throw Exception('Vehicle not found');
    final updated = Vehicle(
      id: id,
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      year: year,
      vin: vin,
      photoUrl: photoUrl ?? vehicles[idx].photoUrl,
      customerId: vehicles[idx].customerId,
    );
    vehicles[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    vehicles.removeWhere((v) => v.id == id);
  }

  @override
  Future<List<Vehicle>> getCustomerVehicles(String customerId) async {
    return vehicles.where((v) => v.customerId == customerId).toList();
  }

  // --- OBD2 Devices ---
  @override
  Future<Obd2Device> registerObd2Device({
    required String branchId,
    required String macAddress,
  }) async {
    final newDevice = Obd2Device(
      id: 'dev-${devices.length + 1}',
      branchId: branchId,
      macAddress: macAddress,
      status: Obd2DeviceStatus.available,
    );
    devices.add(newDevice);
    return newDevice;
  }

  @override
  Future<List<Obd2Device>> getObd2Devices({
    required String branchId,
    String? status,
  }) async {
    var result = devices.where((d) => d.branchId == branchId);
    if (status != null && status.isNotEmpty) {
      result = result.where((d) => d.status.value == status);
    }
    return result.toList();
  }

  @override
  Future<Obd2Device> getObd2DeviceById(String id) async {
    return devices.firstWhere((d) => d.id == id);
  }

  @override
  Future<Obd2Device> updateObd2Device({
    required String id,
    required String macAddress,
  }) async {
    final idx = devices.indexWhere((d) => d.id == id);
    if (idx == -1) throw Exception('Device not found');
    final updated = Obd2Device(
      id: id,
      branchId: devices[idx].branchId,
      macAddress: macAddress,
      status: devices[idx].status,
    );
    devices[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteObd2Device(String id) async {
    devices.removeWhere((d) => d.id == id);
  }

  // --- OBD2 Registrations ---
  @override
  Future<Obd2DeviceRegistration> linkObd2DeviceToVehicle({
    required String obd2DeviceId,
    required String branchId,
    required String vehicleId,
  }) async {
    final newReg = Obd2DeviceRegistration(
      id: 'reg-${registrations.length + 1}',
      obd2DeviceId: obd2DeviceId,
      branchId: branchId,
      vehicleId: vehicleId,
      status: 'ACTIVE',
      createdAt: DateTime.now(),
    );
    registrations.add(newReg);
    return newReg;
  }

  @override
  Future<Obd2DeviceRegistration> updateObd2DeviceRegistrationStatus({
    required String registrationId,
    required String status,
  }) async {
    final idx = registrations.indexWhere((r) => r.id == registrationId);
    if (idx == -1) throw Exception('Registration not found');
    final updated = Obd2DeviceRegistration(
      id: registrations[idx].id,
      obd2DeviceId: registrations[idx].obd2DeviceId,
      branchId: registrations[idx].branchId,
      vehicleId: registrations[idx].vehicleId,
      status: status,
      createdAt: registrations[idx].createdAt,
    );
    registrations[idx] = updated;
    return updated;
  }

  @override
  Future<List<Obd2DeviceRegistration>> getObd2DeviceRegistrations({
    required String branchId,
    String? status,
  }) async {
    var result = registrations.where((r) => r.branchId == branchId);
    if (status != null && status.isNotEmpty) {
      result = result.where((r) => r.status == status);
    }
    return result.toList();
  }

  @override
  Future<List<TelemetrySnapshot>> getRegistrationTelemetrySnapshots({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    return [
      TelemetrySnapshot(
        id: 'snap-01',
        obd2DeviceRegistrationId: registrationId,
        branchId: 'b-01',
        speedKmh: 45.0,
        rpm: 2100,
        temperature: 90,
        fuelLevelPercent: 65.0,
        odometerKm: 42000.0,
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<DtcAlert>> getRegistrationDtcAlerts({
    required String registrationId,
    int page = 0,
    int size = 20,
  }) async {
    return dtcAlerts;
  }

  // --- Telemetry & Diagnostics ---
  @override
  Future<TelemetrySnapshot> getLatestTelemetrySnapshot(String deviceId) async {
    return TelemetrySnapshot(
      id: 'snap-latest',
      obd2DeviceRegistrationId: 'reg-01',
      branchId: 'b-01',
      speedKmh: 60.0,
      rpm: 2400,
      temperature: 88,
      fuelLevelPercent: 70.0,
      odometerKm: 45000.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<TelemetrySnapshot>> getVehicleTelemetrySnapshots({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    return [
      TelemetrySnapshot(
        id: 'snap-veh-01',
        obd2DeviceRegistrationId: 'reg-01',
        branchId: 'b-01',
        speedKmh: 55.0,
        rpm: 2200,
        temperature: 89,
        fuelLevelPercent: 68.0,
        odometerKm: 43000.0,
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<DtcAlert>> getVehicleDtcAlerts({
    required String vehicleId,
    int page = 0,
    int size = 20,
  }) async {
    return dtcAlerts.where((a) => a.vehicleId == vehicleId).toList();
  }

  @override
  Future<List<DtcAlert>> getDtcAlerts({
    required String branchId,
    DtcStatus? status,
    DtcSeverity? severity,
    int page = 0,
    int size = 20,
  }) async {
    var result = dtcAlerts.where((a) => a.branchId == branchId);
    if (status != null) {
      result = result.where((a) => a.status == status);
    }
    if (severity != null) {
      result = result.where((a) => a.severity == severity);
    }
    return result.toList();
  }

  @override
  Future<DtcAlert> getDtcAlertById(String id) async {
    return dtcAlerts.firstWhere((a) => a.id == id);
  }

  @override
  Future<DtcAlert> updateDtcStatus({
    required String alertId,
    required DtcStatus newStatus,
  }) async {
    final idx = dtcAlerts.indexWhere((a) => a.id == alertId);
    if (idx == -1) throw Exception('DtcAlert not found');
    final updated = dtcAlerts[idx].copyWith(status: newStatus);
    dtcAlerts[idx] = updated;
    return updated;
  }

  // --- Telemetry Batches ---
  @override
  Future<void> ingestTelemetryBatch(TelemetryBatch batch) async {
    ingestedBatches.add(batch);
  }

  // --- Live Sensor Compatibility ---
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
    ];
  }

  @override
  Stream<List<LiveSensorReading>> getLiveSensorStream(String branchId) {
    return Stream.value(const [
      LiveSensorReading(
        sensorId: 's-rpm',
        sensorName: 'Engine RPM',
        value: 850,
        unit: 'rpm',
        normalMin: 650,
        normalMax: 3500,
        icon: Icons.speed_outlined,
      ),
    ]);
  }
}

void main() {
  late FakeIotRepository repository;

  setUp(() {
    repository = FakeIotRepository();
  });

  group('Vehicle Use Cases', () {
    test('RegisterVehicle enforces validation invariants and registers vehicle successfully', () async {
      final registerVehicle = RegisterVehicle(repository: repository);

      expect(
        () => registerVehicle.execute(
          plateNumber: '',
          brand: 'Toyota',
          model: 'Corolla',
          year: 2022,
          vin: '1HGCR2F83HA000003',
        ),
        throwsArgumentError,
      );

      expect(
        () => registerVehicle.execute(
          plateNumber: 'ABC-123',
          brand: 'Toyota',
          model: 'Corolla',
          year: 2022,
          vin: 'SHORT_VIN',
        ),
        throwsArgumentError,
      );

      final vehicle = await registerVehicle.execute(
        plateNumber: 'abc-123',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2022,
        vin: '1hgcr2f83ha000003',
        customerId: 'cust-03',
      );

      expect(vehicle.id, isNotEmpty);
      expect(vehicle.plateNumber, 'ABC-123');
      expect(vehicle.vin, '1HGCR2F83HA000003');
      expect(repository.vehicles.length, 3);
    });

    test('GetVehicles and GetCustomerVehicles query available vehicles', () async {
      final getVehicles = GetVehicles(repository: repository);
      final getCustomerVehicles = GetCustomerVehicles(repository: repository);

      final available = await getVehicles.execute(branchId: 'b-01');
      expect(available.length, 2);

      final single = await getVehicles.getById('veh-01');
      expect(single.plateNumber, 'BCX-892');

      final customerVehicles = await getCustomerVehicles.execute('cust-01');
      expect(customerVehicles.length, 1);
      expect(customerVehicles.first.id, 'veh-01');
    });

    test('UpdateVehicle modifies metadata and deletes vehicle', () async {
      final updateVehicle = UpdateVehicle(repository: repository);

      final updated = await updateVehicle.execute(
        id: 'veh-01',
        plateNumber: 'NEW-999',
        brand: 'Toyota',
        model: 'Hilux SRV',
        year: 2023,
        vin: '1HGCR2F83HA000001',
      );

      expect(updated.plateNumber, 'NEW-999');
      expect(updated.model, 'Hilux SRV');

      await updateVehicle.delete('veh-01');
      expect(repository.vehicles.any((v) => v.id == 'veh-01'), isFalse);
    });
  });

  group('OBD2 Hardware & Registration Use Cases', () {
    test('ManageObd2Devices registers, queries, updates, and deletes devices', () async {
      final manageDevices = ManageObd2Devices(repository: repository);

      final device = await manageDevices.register(
        branchId: 'b-01',
        macAddress: 'cc:dd:ee:ff:00:11',
      );
      expect(device.macAddress, 'CC:DD:EE:FF:00:11');
      expect(device.status, Obd2DeviceStatus.available);

      final branchDevices = await manageDevices.getDevices(branchId: 'b-01');
      expect(branchDevices.length, 3);

      final updated = await manageDevices.updateDevice(
        id: device.id,
        macAddress: '11:22:33:44:55:66',
      );
      expect(updated.macAddress, '11:22:33:44:55:66');

      await manageDevices.deleteDevice(device.id);
      expect(repository.devices.any((d) => d.id == device.id), isFalse);
    });

    test('ManageObd2Registrations pairs scanner to vehicle and unpairs device', () async {
      final manageRegistrations = ManageObd2Registrations(repository: repository);

      final registration = await manageRegistrations.linkDeviceToVehicle(
        obd2DeviceId: 'dev-01',
        branchId: 'b-01',
        vehicleId: 'veh-02',
      );

      expect(registration.status, 'ACTIVE');
      expect(registration.obd2DeviceId, 'dev-01');

      final unpaired = await manageRegistrations.unpairDevice(registration.id);
      expect(unpaired.status, 'INACTIVE');

      final snapshots = await manageRegistrations.getSnapshots(registrationId: 'reg-01');
      expect(snapshots, isNotEmpty);
      expect(snapshots.first.speedKmh, 45.0);
    });
  });

  group('Telemetry & Batch Ingestion Use Cases', () {
    test('GetTelemetrySnapshots retrieves latest snapshot and live sensor readings', () async {
      final getSnapshots = GetTelemetrySnapshots(repository: repository);

      final latest = await getSnapshots.getLatest('dev-02');
      expect(latest.speedKmh, 60.0);
      expect(latest.rpm, 2400.0);

      final liveSensors = await getSnapshots.getLiveSensors('veh-01');
      expect(liveSensors.length, 2);
      expect(liveSensors.first.sensorName, 'Engine RPM');
    });

    test('GetDtcAlerts queries alerts by filter, retrieves details, and updates status', () async {
      final getDtcAlerts = GetDtcAlerts(repository: repository);

      final criticalAlerts = await getDtcAlerts.execute(
        branchId: 'b-01',
        severity: DtcSeverity.critical,
      );
      expect(criticalAlerts.length, 1);
      expect(criticalAlerts.first.code, 'P0300');

      final alert = await getDtcAlerts.getById('dtc-01');
      expect(alert.freezeFrame['Engine RPM'], '2,850 rpm');

      final resolved = await getDtcAlerts.updateStatus(
        alertId: 'dtc-01',
        newStatus: DtcStatus.resolved,
      );
      expect(resolved.status, DtcStatus.resolved);
    });

    test('IngestTelemetryBatch validates batch size and non-decreasing odometer progression', () async {
      final ingestBatch = IngestTelemetryBatch(repository: repository);

      final invalidDecreasingBatch = TelemetryBatch(
        obd2DeviceId: 'dev-01',
        snapshots: [
          TelemetryBatchItem(
            speedKmh: 50.0,
            rpm: 2000,
            temperature: 85,
            fuelLevelPercent: 70.0,
            odometerKm: 50000.0,
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          TelemetryBatchItem(
            speedKmh: 55.0,
            rpm: 2200,
            temperature: 87,
            fuelLevelPercent: 69.0,
            odometerKm: 49990.0, // decreasing!
            createdAt: DateTime.now(),
          ),
        ],
      );

      expect(
        () => ingestBatch.execute(invalidDecreasingBatch),
        throwsArgumentError,
      );

      final validBatch = TelemetryBatch(
        obd2DeviceId: 'dev-01',
        snapshots: [
          TelemetryBatchItem(
            speedKmh: 50.0,
            rpm: 2000,
            temperature: 85,
            fuelLevelPercent: 70.0,
            odometerKm: 50000.0,
            createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          TelemetryBatchItem(
            speedKmh: 55.0,
            rpm: 2200,
            temperature: 87,
            fuelLevelPercent: 69.0,
            odometerKm: 50005.0,
            createdAt: DateTime.now(),
          ),
        ],
      );

      await ingestBatch.execute(validBatch);
      expect(repository.ingestedBatches.length, 1);
    });
  });

  group('TelemetryViewModel Presentation Flow', () {
    test('TelemetryViewModel loads alerts, updates status, and filters', () async {
      final viewModel = TelemetryViewModel(
        getDtcAlerts: GetDtcAlerts(repository: repository),
        getTelemetrySnapshots: GetTelemetrySnapshots(repository: repository),
      );

      await viewModel.loadDtcAlerts('b-01');
      expect(viewModel.alerts.length, 2);
      expect(viewModel.activeCount, 2);
      expect(viewModel.criticalCount, 1);

      await viewModel.loadDtcDetail('dtc-01');
      expect(viewModel.selectedAlert?.code, 'P0300');

      await viewModel.loadLiveSensors('veh-01');
      expect(viewModel.liveSensors.length, 2);

      await viewModel.updateDtcStatus('dtc-01', DtcStatus.resolved, 'b-01');
      expect(repository.dtcAlerts.firstWhere((a) => a.id == 'dtc-01').status, DtcStatus.resolved);
    });
  });
}

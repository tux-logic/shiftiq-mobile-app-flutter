import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/commandservices/update_dtc_status_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_dtc_alerts_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_dtc_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_live_sensor_stream_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_severity.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/telemetry_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';

class MockTelemetryRepository implements TelemetryRepository {
  final List<DtcAlert> _alerts = [
    DtcAlert(
      id: 'dtc-01',
      branchId: 'b-01-smp',
      vehicleId: 'veh-01',
      vehiclePlate: 'BCX-892',
      vehicleModel: 'Toyota Hilux 2021',
      customerName: 'Carlos Mendoza',
      code: 'P0300',
      description: 'Fallo de encendido en cilindros múltiples',
      systemCategory: 'Encendido',
      severity: DtcSeverity.critical,
      aiDiagnosticRecommendation: 'Revisar bujías de iridio y bobinas.',
      detectedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      status: DtcStatus.active,
      freezeFrame: const {'RPM Motor': '2850 rpm'},
    ),
    DtcAlert(
      id: 'dtc-02',
      branchId: 'b-01-smp',
      vehicleId: 'veh-02',
      vehiclePlate: 'F1G-789',
      vehicleModel: 'Kia Sportage 2022',
      customerName: 'Andrea Benavente',
      code: 'P0171',
      description: 'Sistema demasiado pobre (Banco 1)',
      systemCategory: 'Combustible',
      severity: DtcSeverity.moderate,
      aiDiagnosticRecommendation: 'Limpiar sensor MAF.',
      detectedAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: DtcStatus.active,
    ),
    DtcAlert(
      id: 'dtc-03',
      branchId: 'b-01-smp',
      vehicleId: 'veh-03',
      vehiclePlate: 'D2A-789',
      vehicleModel: 'Toyota Yaris 2022',
      customerName: 'Mario Salcedo',
      code: 'P0420',
      description: 'Eficiencia catalizador baja',
      systemCategory: 'Escape',
      severity: DtcSeverity.low,
      aiDiagnosticRecommendation: 'Comprobar sensor O2S.',
      detectedAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: DtcStatus.resolved,
    ),
  ];

  @override
  Future<List<DtcAlert>> getDtcAlerts({
    required String branchId,
    DtcSeverity? severity,
    DtcStatus? status,
  }) async {
    return _alerts.where((a) {
      if (a.branchId != branchId) return false;
      if (severity != null && a.severity != severity) return false;
      if (status != null && a.status != status) return false;
      return true;
    }).toList();
  }

  @override
  Future<DtcAlert> getDtcAlertById(String id) async {
    return _alerts.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Alert not found'),
    );
  }

  @override
  Future<DtcAlert> updateDtcStatus({
    required String id,
    required DtcStatus status,
  }) async {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index == -1) throw Exception('Alert not found');
    final updated = _alerts[index].copyWith(status: status);
    _alerts[index] = updated;
    return updated;
  }

  @override
  Future<List<LiveSensorReading>> getLiveSensorReadings(String vehicleId) async {
    return const [
      LiveSensorReading(
        sensorId: 's-rpm',
        sensorName: 'Régimen de Motor',
        value: 850,
        unit: 'rpm',
        normalMin: 650,
        normalMax: 3500,
      ),
      LiveSensorReading(
        sensorId: 's-temp',
        sensorName: 'Temperatura Refrigerante',
        value: 90,
        unit: '°C',
        normalMin: 80,
        normalMax: 102,
      ),
    ];
  }
}

void main() {
  late MockTelemetryRepository repository;
  late GetDtcAlertsQueryService getDtcAlertsQuery;
  late GetDtcDetailQueryService getDtcDetailQuery;
  late GetLiveSensorStreamQueryService getLiveSensorsQuery;
  late UpdateDtcStatusCommandService updateDtcStatusCommand;

  setUp(() {
    repository = MockTelemetryRepository();
    getDtcAlertsQuery = GetDtcAlertsQueryService(telemetryRepository: repository);
    getDtcDetailQuery = GetDtcDetailQueryService(telemetryRepository: repository);
    getLiveSensorsQuery = GetLiveSensorStreamQueryService(telemetryRepository: repository);
    updateDtcStatusCommand = UpdateDtcStatusCommandService(telemetryRepository: repository);
  });

  group('Hito 6: IoT Telemetry & DTC Alerts B2B', () {
    test('1. GetDtcAlertsQueryService returns active alerts for branch', () async {
      final results = await getDtcAlertsQuery.execute(branchId: 'b-01-smp');
      expect(results.length, equals(3));
      expect(results.every((a) => a.branchId == 'b-01-smp'), isTrue);
    });

    test('2. Query filters DTC alerts by severity correctly', () async {
      final results = await getDtcAlertsQuery.execute(
        branchId: 'b-01-smp',
        severity: DtcSeverity.critical,
      );
      expect(results.length, equals(1));
      expect(results.first.code, equals('P0300'));
      expect(results.first.isCritical, isTrue);
    });

    test('3. GetDtcDetailQueryService returns full alert with freeze frame', () async {
      final alert = await getDtcDetailQuery.execute('dtc-01');
      expect(alert.code, equals('P0300'));
      expect(alert.freezeFrame['RPM Motor'], equals('2850 rpm'));
      expect(alert.aiDiagnosticRecommendation, contains('bujías'));
    });

    test('4. GetDtcDetailQueryService throws ArgumentError on empty id', () async {
      expect(() => getDtcDetailQuery.execute(''), throwsArgumentError);
    });

    test('5. UpdateDtcStatusCommandService transitions DTC status', () async {
      final updated = await updateDtcStatusCommand.execute(
        alertId: 'dtc-01',
        status: DtcStatus.resolved,
      );
      expect(updated.status, equals(DtcStatus.resolved));
      expect(updated.isActive, isFalse);
    });

    test('6. GetLiveSensorStreamQueryService returns sensor readings', () async {
      final sensors = await getLiveSensorsQuery.execute('veh-01');
      expect(sensors.length, equals(2));
      expect(sensors.first.sensorName, equals('Régimen de Motor'));
      expect(sensors.first.isWarning, isFalse);
    });

    test('7. TelemetryViewModel handles alert loading, severity filters and status update', () async {
      final viewModel = TelemetryViewModel(
        getDtcAlertsQuery: getDtcAlertsQuery,
        getDtcDetailQuery: getDtcDetailQuery,
        getLiveSensorsQuery: getLiveSensorsQuery,
        updateDtcStatusCommand: updateDtcStatusCommand,
      );

      await viewModel.loadDtcAlerts('b-01-smp');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.activeCount, equals(2)); // dtc-01, dtc-02 active
      expect(viewModel.criticalCount, equals(1));

      // Filter by severity
      await viewModel.filterBySeverity(DtcSeverity.critical, 'b-01-smp');
      expect(viewModel.alerts.length, equals(1));
      expect(viewModel.alerts.first.code, equals('P0300'));

      // Update status to resolved
      await viewModel.updateDtcStatus('dtc-01', DtcStatus.resolved, 'b-01-smp');
      // Because active status filter is active, resolved alert is excluded from active view
      expect(viewModel.alerts.any((a) => a.id == 'dtc-01'), isFalse);

      // Reset filters to see resolved alert
      await viewModel.filterByStatus(DtcStatus.resolved, 'b-01-smp');
      final target = viewModel.alerts.firstWhere((a) => a.id == 'dtc-01');
      expect(target.status, equals(DtcStatus.resolved));
    });
  });
}

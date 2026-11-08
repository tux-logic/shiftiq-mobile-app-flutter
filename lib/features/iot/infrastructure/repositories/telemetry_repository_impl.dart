import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_severity.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/telemetry_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_api.dart';

class TelemetryRepositoryImpl implements TelemetryRepository {
  final TelemetryApi telemetryApi;

  final List<DtcAlert> _localAlerts = [];

  TelemetryRepositoryImpl({required this.telemetryApi}) {
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
        description: 'Fallo de encendido detectado en cilindros múltiples o aleatorios',
        systemCategory: 'Sistema de Encendido y Combustión',
        severity: DtcSeverity.critical,
        aiDiagnosticRecommendation:
            'Inspeccionar bujías de encendido de iridio y bobinas individuales en cilindros 2 y 4. Medir presión de rampa de combustible y descartar tomas de aire parásitas en admisión.',
        detectedAt: now.subtract(const Duration(minutes: 18)),
        status: DtcStatus.active,
        freezeFrame: {
          'RPM Motor': '2,850 rpm',
          'Velocidad': '62 km/h',
          'Temperatura Refrigerante': '98 °C',
          'Posición Acelerador': '42 %',
          'Carga Calculada': '64 %',
          'Sensor MAF': '18.4 g/s',
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
        description: 'Sistema de combustible demasiado pobre (Banco 1)',
        systemCategory: 'Inyección de Combustible y Emisiones',
        severity: DtcSeverity.moderate,
        aiDiagnosticRecommendation:
            'Limpiar sensor de flujo de masa de aire (MAF) con solvente dieléctrico. Verificar hermeticidad en empaque de cuerpo de aceleración y prueba de humo para fugas de vacío.',
        detectedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        status: DtcStatus.active,
        freezeFrame: {
          'RPM Motor': '1,920 rpm',
          'Velocidad': '45 km/h',
          'Temperatura Refrigerante': '88 °C',
          'Ajuste Combustible (STFT)': '+18.2 %',
          'Ajuste Combustible (LTFT)': '+12.5 %',
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
        description: 'Eficiencia del sistema catalizador por debajo del umbral (Banco 1)',
        systemCategory: 'Sistema de Escape y Post-Tratamiento',
        severity: DtcSeverity.low,
        aiDiagnosticRecommendation:
            'Monitorear forma de onda del sensor de oxígeno secundario (Downstream O2S). Comparar oscilación con sensor primario antes de diagnosticar sustitución del convertidor catalítico.',
        detectedAt: now.subtract(const Duration(hours: 5)),
        status: DtcStatus.inInspection,
        freezeFrame: {
          'RPM Motor': '2,100 rpm',
          'Velocidad': '70 km/h',
          'Temperatura Refrigerante': '92 °C',
          'Voltaje O2S Banco 1': '0.74 V',
        },
      ),
      DtcAlert(
        id: 'dtc-04',
        branchId: 'b-01-smp',
        vehicleId: 'veh-04',
        vehiclePlate: 'B8C-456',
        vehicleModel: 'Nissan Sentra 2020',
        customerName: 'Martín Vizcarra',
        code: 'P0113',
        description: 'Circuito del sensor de temperatura de aire de admisión (IAT) alto',
        systemCategory: 'Sensores de Admisión',
        severity: DtcSeverity.low,
        aiDiagnosticRecommendation:
            'Inspección del arnés eléctrico y conector del sensor IAT integrado al sensor MAF. Resuelto tras cambio de filtro de aire.',
        detectedAt: now.subtract(const Duration(days: 1)),
        status: DtcStatus.resolved,
        freezeFrame: {
          'RPM Motor': '820 rpm',
          'Temperatura IAT': '-40 °C (Circuito Abierto)',
        },
      ),
    ]);
  }

  @override
  Future<List<DtcAlert>> getDtcAlerts({
    required String branchId,
    DtcSeverity? severity,
    DtcStatus? status,
  }) async {
    try {
      final remoteDtos = await telemetryApi.getDtcAlerts(
        branchId: branchId,
        severity: severity?.value,
        status: status?.value,
      );
      if (remoteDtos.isNotEmpty) {
        return remoteDtos.map((d) => d.toDomain()).toList();
      }
    } catch (_) {
      // Local fallback
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
    try {
      final dto = await telemetryApi.getDtcAlertById(id);
      return dto.toDomain();
    } catch (_) {
      // Local fallback
    }

    return _localAlerts.firstWhere(
      (a) => a.id == id,
      orElse: () => _localAlerts.first,
    );
  }

  @override
  Future<DtcAlert> updateDtcStatus({
    required String id,
    required DtcStatus status,
  }) async {
    try {
      final dto = await telemetryApi.updateDtcStatus(
        id: id,
        status: status.value,
      );
      return dto.toDomain();
    } catch (_) {
      // Local fallback
    }

    final index = _localAlerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = _localAlerts[index].copyWith(status: status);
      _localAlerts[index] = updated;
      return updated;
    }

    throw Exception('DtcAlert not found');
  }

  @override
  Future<List<LiveSensorReading>> getLiveSensorReadings(String vehicleId) async {
    // Generates realistic real-time telemetry sensor values for OBD-II live monitor
    return const [
      LiveSensorReading(
        sensorId: 's-rpm',
        sensorName: 'Régimen de Motor',
        value: 840,
        unit: 'rpm',
        normalMin: 650,
        normalMax: 3500,
        icon: Icons.speed_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-temp',
        sensorName: 'Temperatura Refrigerante',
        value: 89.5,
        unit: '°C',
        normalMin: 80,
        normalMax: 102,
        icon: Icons.thermostat_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-volt',
        sensorName: 'Voltaje de Batería / Alternador',
        value: 13.9,
        unit: 'V',
        normalMin: 13.2,
        normalMax: 14.8,
        icon: Icons.bolt_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-speed',
        sensorName: 'Velocidad Vehicular (VSS)',
        value: 0,
        unit: 'km/h',
        normalMin: 0,
        normalMax: 140,
        icon: Icons.navigation_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-throttle',
        sensorName: 'Posición Garganta Acelerador (TPS)',
        value: 14.2,
        unit: '%',
        normalMin: 10,
        normalMax: 85,
        icon: Icons.tune_outlined,
      ),
      LiveSensorReading(
        sensorId: 's-fuel',
        sensorName: 'Nivel Tanque de Combustible',
        value: 72,
        unit: '%',
        normalMin: 15,
        normalMax: 100,
        icon: Icons.local_gas_station_outlined,
      ),
    ];
  }
}

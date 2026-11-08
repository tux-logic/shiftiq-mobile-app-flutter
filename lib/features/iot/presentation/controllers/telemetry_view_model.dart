import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/commandservices/update_dtc_status_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_dtc_alerts_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_dtc_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_live_sensor_stream_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_severity.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';

class TelemetryViewModel extends ChangeNotifier {
  final GetDtcAlertsQueryService getDtcAlertsQuery;
  final GetDtcDetailQueryService getDtcDetailQuery;
  final GetLiveSensorStreamQueryService getLiveSensorsQuery;
  final UpdateDtcStatusCommandService updateDtcStatusCommand;

  TelemetryViewModel({
    required this.getDtcAlertsQuery,
    required this.getDtcDetailQuery,
    required this.getLiveSensorsQuery,
    required this.updateDtcStatusCommand,
  });

  bool _isLoading = false;
  String? _errorMessage;
  List<DtcAlert> _alerts = [];
  DtcSeverity? _selectedSeverity;
  DtcStatus? _selectedStatus = DtcStatus.active;
  DtcAlert? _selectedAlert;
  List<LiveSensorReading> _liveSensors = [];
  bool _isDongleConnected = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DtcAlert> get alerts => _alerts;
  DtcSeverity? get selectedSeverity => _selectedSeverity;
  DtcStatus? get selectedStatus => _selectedStatus;
  DtcAlert? get selectedAlert => _selectedAlert;
  List<LiveSensorReading> get liveSensors => _liveSensors;
  bool get isDongleConnected => _isDongleConnected;

  int get criticalCount =>
      _alerts.where((a) => a.severity == DtcSeverity.critical && a.isActive).length;
  int get moderateCount =>
      _alerts.where((a) => a.severity == DtcSeverity.moderate && a.isActive).length;
  int get activeCount => _alerts.where((a) => a.isActive).length;

  Future<void> loadDtcAlerts(String branchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _alerts = await getDtcAlertsQuery.execute(
        branchId: branchId,
        severity: _selectedSeverity,
        status: _selectedStatus,
      );
    } catch (e) {
      _errorMessage = 'Error al cargar alertas DTC de telemetría: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterBySeverity(DtcSeverity? severity, String branchId) async {
    _selectedSeverity = severity;
    await loadDtcAlerts(branchId);
  }

  Future<void> filterByStatus(DtcStatus? status, String branchId) async {
    _selectedStatus = status;
    await loadDtcAlerts(branchId);
  }

  Future<void> loadDtcDetail(String alertId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedAlert = await getDtcDetailQuery.execute(alertId);
    } catch (e) {
      _errorMessage = 'Error al cargar detalle del código DTC: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLiveSensors(String vehicleId) async {
    try {
      _liveSensors = await getLiveSensorsQuery.execute(vehicleId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateDtcStatus(
    String alertId,
    DtcStatus newStatus,
    String branchId,
  ) async {
    try {
      await updateDtcStatusCommand.execute(
        alertId: alertId,
        status: newStatus,
      );
      if (_selectedAlert != null && _selectedAlert!.id == alertId) {
        await loadDtcDetail(alertId);
      }
      await loadDtcAlerts(branchId);
    } catch (e) {
      _errorMessage = 'Error al actualizar estado DTC: $e';
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/iot_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';

/// ViewModel managing state for vehicular telemetry diagnostics and sensor streaming.
class TelemetryViewModel extends ChangeNotifier {
  final GetDtcAlerts getDtcAlerts;
  final GetTelemetrySnapshots getTelemetrySnapshots;

  TelemetryViewModel({
    required this.getDtcAlerts,
    required this.getTelemetrySnapshots,
  });

  bool _isLoading = false;
  String? _errorMessage;
  List<DtcAlert> _alerts = [];
  DtcSeverity? _selectedSeverity;
  DtcStatus? _selectedStatus = DtcStatus.active;
  DtcAlert? _selectedAlert;
  List<LiveSensorReading> _liveSensors = [];
  final bool _isDongleConnected = true;

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
      _alerts = await getDtcAlerts.execute(
        branchId: branchId,
        severity: _selectedSeverity,
        status: _selectedStatus,
      );
    } catch (e) {
      _errorMessage = 'Error loading DTC telemetry alerts: $e';
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
      _selectedAlert = await getDtcAlerts.getById(alertId);
    } catch (e) {
      _errorMessage = 'Error loading DTC code detail: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLiveSensors(String vehicleId) async {
    try {
      _liveSensors = await getTelemetrySnapshots.getLiveSensors(vehicleId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateDtcStatus(
    String alertId,
    DtcStatus newStatus,
    String branchId,
  ) async {
    try {
      await getDtcAlerts.updateStatus(
        alertId: alertId,
        newStatus: newStatus,
      );
      if (_selectedAlert != null && _selectedAlert!.id == alertId) {
        await loadDtcDetail(alertId);
      }
      await loadDtcAlerts(branchId);
    } catch (e) {
      _errorMessage = 'Error updating DTC status: $e';
      notifyListeners();
    }
  }
}

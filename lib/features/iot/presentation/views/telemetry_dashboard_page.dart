import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/views/dtc_detail_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/views/live_sensors_monitor_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/widgets/dtc_alert_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/create_work_order_page.dart';

class TelemetryDashboardPage extends StatefulWidget {
  final String? branchId;
  final TelemetryViewModel? viewModel;

  const TelemetryDashboardPage({
    super.key,
    this.branchId,
    this.viewModel,
  });

  @override
  State<TelemetryDashboardPage> createState() => _TelemetryDashboardPageState();
}

class _TelemetryDashboardPageState extends State<TelemetryDashboardPage> {
  late final TelemetryViewModel _viewModel;
  late final String _effectiveBranchId;
  String _branchName = 'Sede Principal';

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<TelemetryViewModel>();
    final session = getIt.isRegistered<SessionStorage>() ? getIt<SessionStorage>() : null;
    _effectiveBranchId = widget.branchId ?? session?.activeBranchId ?? ApiConstants.defaultBranchId;
    _branchName = session?.activeBranchName ?? ApiConstants.defaultBranchName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadDtcAlerts(_effectiveBranchId);
    });
  }

  void _openDtcDetail(DtcAlert alert) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DtcDetailPage(
          alert: alert,
          branchId: _effectiveBranchId,
          viewModel: _viewModel,
        ),
      ),
    );
  }

  void _openLiveSensors() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveSensorsMonitorPage(
          vehiclePlate: 'BCX-892',
          viewModel: _viewModel,
        ),
      ),
    );
  }

  void _openWorkOrderFromDtc(DtcAlert alert) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateWorkOrderPage(
          branchId: _effectiveBranchId,
          initialPlate: alert.vehiclePlate,
          initialCustomerName: alert.customerName,
          initialModel: alert.vehicleModel,
          initialDiagnostic:
              'Alerta OBD-II Código ${alert.code}: ${alert.description}. Diagnóstico IA: ${alert.aiDiagnosticRecommendation}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telemetría IoT & OBD-II',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Diagnóstico en Vivo · $_branchName',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.loadDtcAlerts(_effectiveBranchId),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final alerts = _viewModel.alerts;
          final isLoading = _viewModel.isLoading;
          final error = _viewModel.errorMessage;

          return Column(
            children: [
              // Dongle Status & Live Sensors Quick Button
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ShiftIQColors.preventiveGreen.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: ShiftIQColors.preventiveGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'ELM327 Activo',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ShiftIQColors.preventiveGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _openLiveSensors,
                      icon: const Icon(Icons.sensors, size: 16),
                      label: const Text('Sensores en Vivo'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ShiftIQColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // KPI Counters Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: ShiftIQColors.borderSlate),
                  ),
                ),
                child: Row(
                  children: [
                    _buildPill(
                      label: 'Todas (${_viewModel.activeCount})',
                      color: ShiftIQColors.graphiteText,
                      isSelected: _viewModel.selectedSeverity == null,
                      onTap: () => _viewModel.filterBySeverity(null, _effectiveBranchId),
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      label: 'Críticas (${_viewModel.criticalCount})',
                      color: ShiftIQColors.severityCrimson,
                      isSelected: _viewModel.selectedSeverity == DtcSeverity.critical,
                      onTap: () => _viewModel.filterBySeverity(DtcSeverity.critical, _effectiveBranchId),
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      label: 'Moderadas (${_viewModel.moderateCount})',
                      color: ShiftIQColors.severityAmber,
                      isSelected: _viewModel.selectedSeverity == DtcSeverity.moderate,
                      onTap: () => _viewModel.filterBySeverity(DtcSeverity.moderate, _effectiveBranchId),
                    ),
                  ],
                ),
              ),

              if (error != null)
                Container(
                  color: ShiftIQColors.severityCrimson.withAlpha(20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: ShiftIQColors.severityCrimson, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                              color: ShiftIQColors.severityCrimson, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Alerts List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : alerts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: ShiftIQColors.preventiveGreen,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Sin códigos DTC activos en la flota',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Los vehículos escaneados operan en parámetros normales',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: alerts.length,
                            itemBuilder: (context, index) {
                              final alert = alerts[index];
                              return DtcAlertCard(
                                alert: alert,
                                onTap: () => _openDtcDetail(alert),
                                onOpenWorkOrder: () =>
                                    _openWorkOrderFromDtc(alert),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
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
    final plate = _viewModel.alerts.isNotEmpty
        ? _viewModel.alerts.first.vehiclePlate
        : '';
    if (plate.isEmpty) {
      ShiftIQToast.show(
        context,
        message: 'No hay vehículos con telemetría activa en esta sede.',
        type: ShiftIQToastType.warning,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveSensorsMonitorPage(
          vehiclePlate: plate,
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: Column(
        children: [
          ShiftIQPageHeader(
            title: 'Telemetría IoT & OBD-II',
            subtitle: 'Alertas DTC & Snapshots · $_branchName',
          ),
          Expanded(
            child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final alerts = _viewModel.alerts;
          final isLoading = _viewModel.isLoading;
          final error = _viewModel.errorMessage;

          return Column(
            children: [
              // Snapshot Access Card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withAlpha(9),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: ShiftIQColors.primaryBlue.withAlpha(18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_toggle_off_rounded,
                              size: 14,
                              color: ShiftIQColors.primaryBlue,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Snapshots OBD-II',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: ShiftIQColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ShiftIQPrimaryPillButton(
                        label: loc.translate('live_telemetry'),
                        icon: Icons.analytics_outlined,
                        onPressed: _openLiveSensors,
                      ),
                    ],
                  ),
                ),
              ),

              // Minimalist Severity Filter Pills (no counters)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterPill(
                        label: 'Todas',
                        isSelected: _viewModel.selectedSeverity == null,
                        onTap: () =>
                            _viewModel.filterBySeverity(null, _effectiveBranchId),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        label: 'Críticas',
                        isSelected:
                            _viewModel.selectedSeverity == DtcSeverity.critical,
                        onTap: () => _viewModel.filterBySeverity(
                          DtcSeverity.critical,
                          _effectiveBranchId,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        label: 'Moderadas',
                        isSelected:
                            _viewModel.selectedSeverity == DtcSeverity.moderate,
                        onTap: () => _viewModel.filterBySeverity(
                          DtcSeverity.moderate,
                          _effectiveBranchId,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (error != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.severityCrimson.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ShiftIQColors.severityCrimson.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: ShiftIQColors.severityCrimson,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: ShiftIQColors.severityCrimson,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Alerts List with Pull-to-Refresh
              Expanded(
                child: ShiftIQPullToRefresh(
                  onRefresh: () => _viewModel.loadDtcAlerts(_effectiveBranchId),
                  skeleton: const ShiftIQSkeletonCardList(),
                  child: ShiftIQContentTransition(
                    child: isLoading && alerts.isEmpty
                        ? const ShiftIQSkeletonCardList(
                            key: ValueKey('iot_loading'),
                          )
                        : alerts.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(32, 64, 32, 120),
                              children: [
                                const Center(
                                  child: ShiftIQEmptyStateIcon(),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Sin códigos DTC activos en la flota',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Los vehículos escaneados operan en parámetros normales',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
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
                ),
              ),
            ],
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F172A)
                : ShiftIQColors.borderSlate,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withAlpha(28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

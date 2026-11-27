import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_kanban_tab_bar.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton_dummies.dart';
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

class _TelemetryDashboardPageState extends State<TelemetryDashboardPage>
    with SingleTickerProviderStateMixin {
  static const List<DtcSeverity?> _tabSeverities = [
    null,
    DtcSeverity.critical,
    DtcSeverity.moderate,
  ];

  late final TelemetryViewModel _viewModel;
  late final TabController _tabController;
  late final String _effectiveBranchId;
  String _branchName = 'Sede Principal';

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<TelemetryViewModel>();
    _tabController = TabController(length: _tabSeverities.length, vsync: this);
    _tabController.addListener(_handleTabChanged);
    final session = getIt.isRegistered<SessionStorage>() ? getIt<SessionStorage>() : null;
    _effectiveBranchId = widget.branchId ?? session?.activeBranchId ?? ApiConstants.defaultBranchId;
    _branchName = session?.activeBranchName ?? ApiConstants.defaultBranchName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadDtcAlerts(_effectiveBranchId);
    });
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    _viewModel.filterBySeverity(
      _tabSeverities[_tabController.index],
      _effectiveBranchId,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
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
    final loc = AppLocalizations.of(context);
    final plate = _viewModel.alerts.isNotEmpty
        ? _viewModel.alerts.first.vehiclePlate
        : '';
    if (plate.isEmpty) {
      ShiftIQToast.show(
        context,
        message: loc.translate('iot_no_active_telemetry_branch'),
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
    final loc = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateWorkOrderPage(
          branchId: _effectiveBranchId,
          initialPlate: alert.vehiclePlate,
          initialCustomerName: alert.customerName,
          initialModel: alert.vehicleModel,
          initialDiagnostic:
              '${loc.translate('iot_obd_alert_prefix')} ${alert.code}: ${alert.description}. ${loc.translate('iot_ai_diagnosis_prefix')}: ${alert.aiDiagnosticRecommendation}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: ShiftIQCollapsibleHeaderBody(
        header: ShiftIQPageHeader(
          title: loc.translate('iot_telemetry_title'),
          subtitle: '${loc.translate('iot_dtc_snapshots_subtitle')} · $_branchName',
        ),
        body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.history_toggle_off_rounded,
                              size: 14,
                              color: ShiftIQColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              loc.translate('iot_obd_snapshots_badge'),
                              style: const TextStyle(
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

              // Minimalist Kanban TabBar for DTC Severity
              ShiftIQKanbanTabBar(
                controller: _tabController,
                tabs: [
                  ShiftIQKanbanTabItem(
                    label: loc.translate('iot_tab_all'),
                    count: _viewModel.alertsForSeverity(null).length,
                  ),
                  ShiftIQKanbanTabItem(
                    label: loc.translate('iot_tab_critical'),
                    count: _viewModel
                        .alertsForSeverity(DtcSeverity.critical)
                        .length,
                  ),
                  ShiftIQKanbanTabItem(
                    label: loc.translate('iot_tab_moderate'),
                    count: _viewModel
                        .alertsForSeverity(DtcSeverity.moderate)
                        .length,
                  ),
                ],
              ),
              const SizedBox(height: 8),

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

              // Swipeable Kanban TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabSeverities
                      .map((severity) => _buildAlertsTab(isLoading, severity))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildAlertsTab(bool isLoading, DtcSeverity? severity) {
    final loc = AppLocalizations.of(context);
    final tabAlerts = _viewModel.alertsForSeverity(severity);
    return ShiftIQPullToRefresh(
      onRefresh: () => _viewModel.loadDtcAlerts(_effectiveBranchId),
      skeleton: _buildDtcSkeletonList(),
      child: ShiftIQContentTransition(
        child: isLoading && tabAlerts.isEmpty
            ? _buildDtcSkeletonList()
            : tabAlerts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(32, 64, 32, 120),
                    children: [
                      const Center(child: ShiftIQEmptyStateIcon()),
                      const SizedBox(height: 16),
                      Text(
                        loc.translate('iot_no_active_dtc_fleet'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.translate('iot_all_vehicles_normal'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: tabAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = tabAlerts[index];
                      return DtcAlertCard(
                        alert: alert,
                        onTap: () => _openDtcDetail(alert),
                        onOpenWorkOrder: () => _openWorkOrderFromDtc(alert),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildDtcSkeletonList() {
    final dummies = ShiftIQSkeletonDummies.dtcAlerts();
    return ShiftIQSkeletonizer(
      key: const ValueKey('iot_loading'),
      enabled: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: dummies.length,
        itemBuilder: (_, index) => DtcAlertCard(
          alert: dummies[index],
          onTap: () {},
          onOpenWorkOrder: () {},
        ),
      ),
    );
  }
}

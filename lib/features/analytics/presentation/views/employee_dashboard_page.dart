import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/controllers/employee_dashboard_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/dtc_alert_banner.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/employee_workload_charts.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/kpi_metric_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_page.dart';

/// Personal operational dashboard for workshop employees/mechanics,
/// reusing ShiftIQ's KPI tiles, DTC alert banner, and pull-to-refresh patterns.
class EmployeeDashboardPage extends StatefulWidget {
  final EmployeeDashboardViewModel? viewModel;
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToTelemetry;

  const EmployeeDashboardPage({
    super.key,
    this.viewModel,
    this.onNavigateToOrders,
    this.onNavigateToTelemetry,
  });

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  late final EmployeeDashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<EmployeeDashboardViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        final summary = vm.summary;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          body: Column(
            children: [
              ShiftIQPageHeader(
                title: 'Mi Resumen',
                subtitle: 'Cola operativa · ${vm.activeBranchName}',
                actions: [
                  ShiftIQLiquidIconButton(
                    tooltip: 'Mi perfil',
                    icon: Icons.person_outline_rounded,
                    onDarkBackground: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: ShiftIQContentTransition(
                  child: vm.isLoading && summary == null
                      ? const ShiftIQSkeletonDetail(
                          key: ValueKey('employee_dashboard_loading'),
                        )
                      : ShiftIQPullToRefresh(
                          onRefresh: vm.refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                            children: [
                              if (vm.error != null) ...[
                                _ErrorBanner(
                                  message: vm.error!,
                                  onRetry: vm.refresh,
                                ),
                                const SizedBox(height: 14),
                              ],
                              if (summary != null &&
                                  summary.activeDtcAlertsCount > 0) ...[
                                DtcAlertBanner(
                                  alertCount: summary.activeDtcAlertsCount,
                                  onDetailsPressed: widget.onNavigateToTelemetry,
                                ),
                                const SizedBox(height: 16),
                              ],
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.32,
                                children: [
                                  KpiMetricCard(
                                    title: 'OTs Asignadas',
                                    value:
                                        '${summary?.assignedWorkOrdersCount ?? 0}',
                                    numericValue:
                                        (summary?.assignedWorkOrdersCount ?? 0)
                                            .toDouble(),
                                    valueFormatter: (v) =>
                                        v.round().toString(),
                                    subtitle: 'Activas en bahía',
                                    icon: Icons.build_circle_outlined,
                                    accentColor: ShiftIQColors.primaryBlue,
                                    onTap: widget.onNavigateToOrders,
                                  ),
                                  KpiMetricCard(
                                    title: 'Tareas Pendientes',
                                    value:
                                        '${summary?.pendingTasksCount ?? 0}',
                                    numericValue:
                                        (summary?.pendingTasksCount ?? 0)
                                            .toDouble(),
                                    valueFormatter: (v) =>
                                        v.round().toString(),
                                    subtitle: 'Por ejecutar',
                                    icon: Icons.pending_actions_rounded,
                                    accentColor: ShiftIQColors.severityAmber,
                                    onTap: widget.onNavigateToOrders,
                                  ),
                                  KpiMetricCard(
                                    title: 'Tareas Completadas',
                                    value:
                                        '${summary?.completedTasksCount ?? 0}',
                                    numericValue:
                                        (summary?.completedTasksCount ?? 0)
                                            .toDouble(),
                                    valueFormatter: (v) =>
                                        v.round().toString(),
                                    subtitle: 'Finalizadas',
                                    icon: Icons.task_alt_rounded,
                                    accentColor: ShiftIQColors.preventiveGreen,
                                  ),
                                  KpiMetricCard(
                                    title: 'Alertas DTC',
                                    value:
                                        '${summary?.activeDtcAlertsCount ?? 0}',
                                    numericValue:
                                        (summary?.activeDtcAlertsCount ?? 0)
                                            .toDouble(),
                                    valueFormatter: (v) =>
                                        v.round().toString(),
                                    subtitle: 'En tu cola',
                                    icon: Icons.sensors_rounded,
                                    accentColor: ShiftIQColors.severityCrimson,
                                    onTap: widget.onNavigateToTelemetry,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              EmployeeTaskRingChart(
                                completedTasks:
                                    summary?.completedTasksCount ?? 0,
                                pendingTasks: summary?.pendingTasksCount ?? 0,
                              ),
                              if (summary != null &&
                                  summary.assignedWorkOrders.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                EmployeeQueueWorkloadChart(
                                  orders: summary.assignedWorkOrders,
                                  onOrderTap: (order) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => WorkOrderDetailPage(
                                          workOrderId: order.workOrderId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(height: 22),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Mi Cola de Trabajo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: ShiftIQColors.graphiteText,
                                    ),
                                  ),
                                  if (widget.onNavigateToOrders != null)
                                    TextButton(
                                      onPressed: widget.onNavigateToOrders,
                                      child: const Text('Ver todas'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (summary == null ||
                                  summary.assignedWorkOrders.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: ShiftIQColors.borderSlate,
                                    ),
                                  ),
                                  child: const Column(
                                    children: [
                                      ShiftIQEmptyStateIcon(),
                                      SizedBox(height: 12),
                                      Text(
                                        'Sin órdenes asignadas en tu cola.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: ShiftIQColors.graphiteText,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Cuando el taller te asigne tareas aparecerán aquí.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...summary.assignedWorkOrders.map(
                                  (order) => _AssignedOrderTile(
                                    order: order,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => WorkOrderDetailPage(
                                            workOrderId: order.workOrderId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AssignedOrderTile extends StatelessWidget {
  final EmployeeAssignedWorkOrderSummary order;
  final VoidCallback onTap;

  const _AssignedOrderTile({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInProgress = order.status.toUpperCase() == 'IN_PROGRESS';
    final statusColor = isInProgress
        ? ShiftIQColors.secondaryTeal
        : ShiftIQColors.severityAmber;
    final statusLabel = isInProgress ? 'En progreso' : 'Pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.primaryBlue.withAlpha(16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    size: 20,
                    color: ShiftIQColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OT #${order.internalNumber.toString().padLeft(6, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.assignedTasksCount} tareas · ${order.pendingTasksCount} pendientes',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(24),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShiftIQColors.severityCrimson.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShiftIQColors.severityCrimson.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: ShiftIQColors.severityCrimson,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: ShiftIQColors.severityCrimson,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

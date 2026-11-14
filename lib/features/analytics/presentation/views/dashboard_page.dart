import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/controllers/dashboard_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/activity_bar_chart.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/dtc_alert_banner.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/kpi_metric_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/quick_actions_row.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/revenue_trend_chart.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/billing_dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/controllers/appointments_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/views/customer_directory_page.dart';

/// Minimalist, reactive branch analytics and operations dashboard.
class DashboardPage extends StatefulWidget {
  final DashboardViewModel? viewModel;
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToAppointments;
  final VoidCallback? onNavigateToInventory;
  final VoidCallback? onNavigateToIot;

  const DashboardPage({
    super.key,
    this.viewModel,
    this.onNavigateToOrders,
    this.onNavigateToAppointments,
    this.onNavigateToInventory,
    this.onNavigateToIot,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<DashboardViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  bool get _isOwnerAdmin {
    if (!getIt.isRegistered<SessionStorage>()) return false;
    return RoleRouter.resolveScope(getIt<SessionStorage>().roles) ==
        MobileRoleScope.ownerAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        final isOwnerAdmin = _isOwnerAdmin;
        final summary = vm.summary;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          appBar: AppBar(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 16,
            title: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BranchSelectionPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vm.activeBranchName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isOwnerAdmin
                                ? loc.translate('executive_dashboard')
                                : loc.translate('operational_dashboard'),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: loc.translate('tooltip_customer_directory'),
                icon: const Icon(Icons.people_outline_rounded, size: 22),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CustomerDirectoryPage(
                        branchId: vm.activeBranchId,
                        viewModel: getIt<AppointmentsViewModel>(),
                      ),
                    ),
                  );
                },
              ),
              if (isOwnerAdmin)
                IconButton(
                  tooltip: loc.translate('tooltip_billing'),
                  icon: const Icon(Icons.receipt_long_outlined, size: 21),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BillingDashboardPage(),
                      ),
                    );
                  },
                ),
              IconButton(
                tooltip: loc.translate('tooltip_profile'),
                icon: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: vm.refresh,
            color: ShiftIQColors.primaryBlue,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: vm.isLoading && summary == null
                  ? const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(
                        color: ShiftIQColors.primaryBlue,
                      ),
                    )
                  : SingleChildScrollView(
                      key: const ValueKey('content'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) {
                          return Opacity(
                            opacity: t,
                            child: Transform.translate(
                              offset: Offset(0, (1 - t) * 10),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (summary != null &&
                                summary.dtcAlertsCount > 0) ...[
                              DtcAlertBanner(
                                alertCount: summary.dtcAlertsCount,
                                onDetailsPressed: widget.onNavigateToIot,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Minimalist 2x2 KPI grid
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.18,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                if (isOwnerAdmin)
                                  KpiMetricCard(
                                    title: loc.translate('month_revenue'),
                                    value: summary?.formattedRevenue ??
                                        'S/ 0.00',
                                    numericValue: summary?.totalRevenue ?? 0.0,
                                    valueFormatter: (v) =>
                                        'S/ ${NumberFormat('#,##0.00', 'en_US').format(v)}',
                                    icon: Icons.trending_up_rounded,
                                    accentColor: ShiftIQColors.preventiveGreen,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const BillingDashboardPage(),
                                        ),
                                      );
                                    },
                                  )
                                else
                                  KpiMetricCard(
                                    title: loc.translate('bays_in_service'),
                                    value: loc.translate('bays_active_label'),
                                    icon: Icons.car_repair_outlined,
                                    accentColor: ShiftIQColors.preventiveGreen,
                                    onTap: widget.onNavigateToOrders,
                                  ),
                                KpiMetricCard(
                                  title: loc.translate('work_orders_kpi'),
                                  value:
                                      '${summary?.completedWorkOrdersCount ?? 0}',
                                  numericValue: (summary
                                              ?.completedWorkOrdersCount ??
                                          0)
                                      .toDouble(),
                                  valueFormatter: (v) => '${v.round()}',
                                  subtitle: loc.translate('orders_tab'),
                                  icon: Icons.build_circle_outlined,
                                  accentColor: ShiftIQColors.primaryBlue,
                                  onTap: widget.onNavigateToOrders,
                                ),
                                KpiMetricCard(
                                  title:
                                      loc.translate('today_appointments_kpi'),
                                  value:
                                      '${summary?.totalAppointmentsCount ?? 0}',
                                  numericValue:
                                      (summary?.totalAppointmentsCount ?? 0)
                                          .toDouble(),
                                  valueFormatter: (v) => '${v.round()}',
                                  subtitle: loc.translate('appointments_tab'),
                                  icon: Icons.calendar_today_outlined,
                                  accentColor: ShiftIQColors.secondaryTeal,
                                  onTap: widget.onNavigateToAppointments,
                                ),
                                KpiMetricCard(
                                  title: loc.translate('critical_stock_kpi'),
                                  value: '${summary?.lowStockAlertsCount ?? 0}',
                                  numericValue:
                                      (summary?.lowStockAlertsCount ?? 0)
                                          .toDouble(),
                                  valueFormatter: (v) => '${v.round()}',
                                  subtitle: loc.translate('reorder_today'),
                                  icon: Icons.inventory_2_outlined,
                                  accentColor: ShiftIQColors.severityAmber,
                                  onTap: widget.onNavigateToInventory,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Animated Analytics Charts
                            if (isOwnerAdmin || vm.snapshots.isNotEmpty) ...[
                              RevenueTrendChart(
                                snapshots: vm.snapshots,
                                selectedRangeDays: vm.selectedRangeDays,
                                onRangeChanged: vm.setRangeDays,
                              ),
                              const SizedBox(height: 12),
                              ActivityBarChart(snapshots: vm.snapshots),
                              const SizedBox(height: 18),
                            ],

                            QuickActionsRow(
                              onNewOrder: widget.onNavigateToOrders,
                              onNewAppointment: widget.onNavigateToAppointments,
                              onNewBatch: widget.onNavigateToInventory,
                            ),

                            const SizedBox(height: 18),

                            // Clean Recent Work Orders Card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE8EDF4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.03),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        loc.translate('active_work_orders'),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: ShiftIQColors.graphiteText,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: widget.onNavigateToOrders,
                                        child: Text(
                                          loc.translate('view_all'),
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: ShiftIQColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (vm.recentWorkOrders.isEmpty)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: Text(
                                          'No hay órdenes activas en esta sede.',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    ...vm.recentWorkOrders.map(
                                      (order) => Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: _OrderPreviewRow(
                                          code: order.formattedNumber.isNotEmpty
                                              ? order.formattedNumber
                                              : 'OT-${order.internalNumber}',
                                          vehicle:
                                              '${order.vehicleModel} (${order.vehiclePlate})',
                                          service: order
                                                  .diagnosticSummary.isNotEmpty
                                              ? order.diagnosticSummary
                                              : 'Revisión general',
                                          status: order.status.label,
                                          statusColor: order.status.color,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderPreviewRow extends StatelessWidget {
  final String code;
  final String vehicle;
  final String service;
  final String status;
  final Color statusColor;

  const _OrderPreviewRow({
    required this.code,
    required this.vehicle,
    required this.service,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$code · $vehicle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                service,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}

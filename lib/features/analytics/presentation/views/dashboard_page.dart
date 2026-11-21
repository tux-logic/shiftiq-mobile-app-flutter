import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/controllers/dashboard_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/activity_bar_chart.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/dtc_alert_banner.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/quick_actions_row.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/revenue_trend_chart.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/billing_dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
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
          body: Column(
            children: [
              // Unified gradient header matching BranchSelectionPage
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 14, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(22),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withAlpha(45),
                                ),
                              ),
                              child: Text(
                                isOwnerAdmin
                                    ? 'OWNER / ADMIN'
                                    : 'WORKSHOP STAFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShiftIQLiquidIconButton(
                                  tooltip: loc
                                      .translate('tooltip_customer_directory'),
                                  icon: Icons.people_outline_rounded,
                                  onDarkBackground: true,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CustomerDirectoryPage(
                                          branchId: vm.activeBranchId,
                                          viewModel:
                                              getIt<AppointmentsViewModel>(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (isOwnerAdmin) ...[
                                  const SizedBox(width: 8),
                                  ShiftIQLiquidIconButton(
                                    tooltip: loc.translate('tooltip_billing'),
                                    icon: Icons.receipt_long_outlined,
                                    onDarkBackground: true,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const BillingDashboardPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                const SizedBox(width: 8),
                                ShiftIQLiquidIconButton(
                                  tooltip: loc.translate('tooltip_profile'),
                                  icon: Icons.person_outline_rounded,
                                  onDarkBackground: true,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProfilePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BranchSelectionPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  vm.activeBranchName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 22,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOwnerAdmin
                              ? loc.translate('executive_dashboard')
                              : loc.translate('operational_dashboard'),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ShiftIQPullToRefresh(
                  onRefresh: vm.refresh,
                  skeleton: const ShiftIQSkeletonDashboard(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: vm.isLoading && summary == null
                        ? const ShiftIQSkeletonDashboard(key: ValueKey('loading'))
                        : SingleChildScrollView(
                      key: const ValueKey('content'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
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

                            // Minimalist Executive Overview (no quantity counter boxes)
                            _ExecutiveMinimalistCard(
                              isOwnerAdmin: isOwnerAdmin,
                              summary: summary,
                              networkSummary: vm.networkSummary,
                              revenueTitle: loc.translate('month_revenue'),
                              baysTitle: loc.translate('bays_in_service'),
                              baysStatusLabel:
                                  loc.translate('bays_active_label'),
                              ordersLabel: loc.translate('orders_tab'),
                              appointmentsLabel:
                                  loc.translate('appointments_tab'),
                              onOpenBilling: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BillingDashboardPage(),
                                  ),
                                );
                              },
                              onNavigateToOrders: widget.onNavigateToOrders,
                              onNavigateToAppointments:
                                  widget.onNavigateToAppointments,
                              onNavigateToInventory: widget.onNavigateToInventory,
                              onNavigateToIot: widget.onNavigateToIot,
                            ),

                            const SizedBox(height: 16),

                            // Animated Analytics Charts (Owner / Admin only)
                            if (isOwnerAdmin) ...[
                              RevenueTrendChart(
                                snapshots: vm.snapshots,
                                selectedRangeDays: vm.selectedRangeDays,
                                onRangeChanged: vm.setRangeDays,
                              ),
                              const SizedBox(height: 16),
                              ActivityBarChart(snapshots: vm.snapshots),
                              const SizedBox(height: 16),
                            ],

                            QuickActionsRow(
                              onNewOrder: widget.onNavigateToOrders,
                              onNewAppointment: widget.onNavigateToAppointments,
                              onNewBatch: widget.onNavigateToInventory,
                            ),

                            const SizedBox(height: 16),

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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExecutiveMinimalistCard extends StatelessWidget {
  final bool isOwnerAdmin;
  final BranchAnalyticsSummary? summary;
  final NetworkAnalyticsSummary? networkSummary;
  final String revenueTitle;
  final String baysTitle;
  final String baysStatusLabel;
  final String ordersLabel;
  final String appointmentsLabel;
  final VoidCallback onOpenBilling;
  final VoidCallback? onNavigateToOrders;
  final VoidCallback? onNavigateToAppointments;
  final VoidCallback? onNavigateToInventory;
  final VoidCallback? onNavigateToIot;

  const _ExecutiveMinimalistCard({
    required this.isOwnerAdmin,
    required this.summary,
    required this.networkSummary,
    required this.revenueTitle,
    required this.baysTitle,
    required this.baysStatusLabel,
    required this.ordersLabel,
    required this.appointmentsLabel,
    required this.onOpenBilling,
    this.onNavigateToOrders,
    this.onNavigateToAppointments,
    this.onNavigateToInventory,
    this.onNavigateToIot,
  });

  @override
  Widget build(BuildContext context) {
    final ordersCount = summary?.completedWorkOrdersCount ?? 0;
    final appointmentsCount = summary?.totalAppointmentsCount ?? 0;
    final totalFlow = ordersCount + appointmentsCount;
    final ordersRatio = totalFlow > 0 ? ordersCount / totalFlow : 0.5;
    final hasStockAlert = (summary?.lowStockAlertsCount ?? 0) > 0;
    final hasDtcAlert = (summary?.dtcAlertsCount ?? 0) > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ShiftIQColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Focus Row: Revenue (Owner/Admin) or Bay Status (Staff)
          InkWell(
            onTap: isOwnerAdmin ? onOpenBilling : onNavigateToOrders,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOwnerAdmin ? revenueTitle : baysTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOwnerAdmin
                            ? (summary?.formattedRevenue ?? 'S/ 0.00')
                            : baysStatusLabel,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwnerAdmin && networkSummary != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ShiftIQColors.primaryBlue.withAlpha(16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ShiftIQColors.primaryBlue.withAlpha(45),
                      ),
                    ),
                    child: Text(
                      'Red: S/ ${NumberFormat('#,##0.00', 'en_US').format(networkSummary!.totalNetworkRevenue)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Proportional Operational Flow Bar (no numeric counter boxes)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onNavigateToOrders,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ShiftIQColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ordersLabel,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onNavigateToAppointments,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ShiftIQColors.secondaryTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      appointmentsLabel,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: totalFlow == 0
                  ? Container(color: const Color(0xFFF1F5F9))
                  : Row(
                      children: [
                        if (ordersRatio > 0)
                          Expanded(
                            flex: (ordersRatio * 100).round().clamp(1, 99),
                            child: Container(color: ShiftIQColors.primaryBlue),
                          ),
                        if (ordersRatio < 1)
                          Expanded(
                            flex: ((1 - ordersRatio) * 100)
                                .round()
                                .clamp(1, 99),
                            child:
                                Container(color: ShiftIQColors.secondaryTeal),
                          ),
                      ],
                    ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Semantic Health Status Strip
          Row(
            children: [
              Expanded(
                child: _HealthStatusPill(
                  icon: Icons.inventory_2_outlined,
                  label: hasStockAlert ? 'Stock por reponer' : 'Stock saludable',
                  color: hasStockAlert
                      ? ShiftIQColors.severityAmber
                      : ShiftIQColors.preventiveGreen,
                  onTap: onNavigateToInventory,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HealthStatusPill(
                  icon: Icons.sensors_rounded,
                  label: hasDtcAlert ? 'Revisión OBD-II' : 'Telemetría estable',
                  color: hasDtcAlert
                      ? ShiftIQColors.severityCrimson
                      : ShiftIQColors.secondaryTeal,
                  onTap: onNavigateToIot,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthStatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _HealthStatusPill({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(55)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
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

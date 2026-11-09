import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/widgets/dtc_alert_banner.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/widgets/kpi_metric_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/widgets/quick_actions_row.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/billing_dashboard_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final viewModel = _viewModel;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BranchSelectionPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          viewModel.activeBranchName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Panel Ejecutivo del Taller · Castro Motors',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Facturación y Cotizaciones SUNAT',
                icon: const Icon(Icons.receipt_long),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BillingDashboardPage(),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Cambiar de Sede',
                icon: const Icon(Icons.storefront_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BranchSelectionPage(),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Refrescar KPIs',
                icon: const Icon(Icons.refresh),
                onPressed: viewModel.isLoading ? null : viewModel.refresh,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: viewModel.refresh,
            color: ShiftIQColors.primaryBlue,
            child: viewModel.isLoading && viewModel.summary == null
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ShiftIQColors.primaryBlue,
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DTC Telemetry Alerts Banner
                        if (viewModel.summary != null)
                          DtcAlertBanner(
                            alertCount: viewModel.summary!.dtcAlertsCount,
                            onDetailsPressed: widget.onNavigateToIot,
                          ),

                        const SizedBox(height: 12),

                        // Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MÉTRICAS CLAVE (KPIs DE HOY)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ShiftIQColors.preventiveGreen.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
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
                                  const SizedBox(width: 4),
                                  const Text(
                                    'EN VIVO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: ShiftIQColors.preventiveGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // KPI 2x2 Grid
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            KpiMetricCard(
                              title: 'Facturación Mes',
                              value: viewModel.summary?.formattedRevenue ?? 'S/ 0.00',
                              subtitle: '+14% vs mes anterior',
                              icon: Icons.trending_up,
                              accentColor: ShiftIQColors.preventiveGreen,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const BillingDashboardPage(),
                                  ),
                                );
                              },
                            ),
                            KpiMetricCard(
                              title: 'Órdenes Trabajo',
                              value: '${viewModel.summary?.completedWorkOrdersCount ?? 0} OTs',
                              subtitle: '4 en bahía activa',
                              icon: Icons.build_circle_outlined,
                              accentColor: ShiftIQColors.primaryBlue,
                              onTap: widget.onNavigateToOrders,
                            ),
                            KpiMetricCard(
                              title: 'Citas de Hoy',
                              value: '${viewModel.summary?.totalAppointmentsCount ?? 0} Citas',
                              subtitle: '2 citas pendientes',
                              icon: Icons.calendar_today_outlined,
                              accentColor: ShiftIQColors.secondaryTeal,
                              onTap: widget.onNavigateToAppointments,
                            ),
                            KpiMetricCard(
                              title: 'Stock Crítico',
                              value: '${viewModel.summary?.lowStockAlertsCount ?? 0} Lotes',
                              subtitle: 'Reponer hoy',
                              icon: Icons.warning_amber_rounded,
                              accentColor: ShiftIQColors.severityAmber,
                              onTap: widget.onNavigateToInventory,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quick Actions
                        QuickActionsRow(
                          onNewOrder: widget.onNavigateToOrders,
                          onNewAppointment: widget.onNavigateToAppointments,
                          onNewBatch: widget.onNavigateToInventory,
                        ),

                        const SizedBox(height: 20),

                        // Recent Work Orders Card Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ShiftIQColors.borderSlate),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Órdenes de Trabajo Activas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: ShiftIQColors.graphiteText,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: widget.onNavigateToOrders,
                                    child: const Text(
                                      'Ver Todas',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ShiftIQColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 12),
                              _buildOrderPreviewItem(
                                code: 'OT-2026-0042',
                                vehicle: 'Toyota Hilux (BCX-892)',
                                service: 'Mantenimiento 10,000 km',
                                status: 'En Diagnóstico',
                                statusColor: ShiftIQColors.secondaryTeal,
                              ),
                              const Divider(height: 12),
                              _buildOrderPreviewItem(
                                code: 'OT-2026-0041',
                                vehicle: 'Hyundai Tucson (AJ-4421)',
                                service: 'Cambio de Frenos y Sensores',
                                status: 'En Proceso',
                                statusColor: ShiftIQColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildOrderPreviewItem({
    required String code,
    required String vehicle,
    required String service,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$code · $vehicle',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  service,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

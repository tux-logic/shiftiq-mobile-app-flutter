import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_floating_nav_bar.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/dtc_alert_banner.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/logout.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_logout_sheet.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_profile_avatar_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/widgets/customer_analytics_charts.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/views/live_sensors_monitor_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_page.dart';

/// Dedicated mobile portal shell for `ROLE_USER` / `ROLE_CUSTOMER` accounts,
/// reusing the shared ShiftIQ floating nav bar, KPIs, OBD-II telemetry,
/// read-only work orders, and self-service quote approvals/payments.
class CustomerHomePage extends StatefulWidget {
  final CustomerHomeViewModel? viewModel;

  const CustomerHomePage({super.key, this.viewModel});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  CustomerHomeViewModel? _viewModel;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
    } else if (getIt.isRegistered<CustomerHomeViewModel>()) {
      _viewModel = getIt<CustomerHomeViewModel>();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel?.load();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showShiftIQLogoutConfirmationSheet(context);
    if (!confirmed || !context.mounted) return;

    await getIt<LogoutUseCase>().execute();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(viewModel: getIt<LoginViewModel>()),
      ),
      (route) => false,
    );
  }

  void _openWorkOrder(WorkOrder order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkOrderDetailPage(
          workOrderId: order.id,
          readOnly: true,
        ),
      ),
    );
  }

  void _openVehicleObd2(Vehicle vehicle) {
    if (!getIt.isRegistered<TelemetryViewModel>()) {
      ShiftIQToast.show(
        context,
        message: 'Monitor OBD-II no disponible en este contexto.',
        type: ShiftIQToastType.info,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveSensorsMonitorPage(
          vehiclePlate: vehicle.plateNumber,
          vehicleId: vehicle.id,
          viewModel: getIt<TelemetryViewModel>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final email = getIt.isRegistered<SessionStorage>()
        ? (getIt<SessionStorage>().username ?? '')
        : '';

    final headerSubtitle = switch (_selectedTab) {
      1 => 'Tus vehículos y diagnóstico OBD-II',
      2 => 'Seguimiento de órdenes y pagos',
      _ => email.isNotEmpty ? email : null,
    };

    final headerTitle = switch (_selectedTab) {
      1 => 'Mis Vehículos',
      2 => 'Órdenes & Pagos',
      _ => loc.translate('customer_portal_title'),
    };

    return Scaffold(
      extendBody: true,
      backgroundColor: ShiftIQColors.warmNeutral,
      body: ShiftIQCollapsibleHeaderBody(
        header: ShiftIQPageHeader(
          title: headerTitle,
          subtitle: headerSubtitle,
          actions: [
            ShiftIQProfileAvatarButton(
              key: const Key('customer_profile_button'),
              tooltip: loc.translate('tooltip_profile'),
            ),
            ShiftIQLiquidIconButton(
              key: const Key('customer_logout_button'),
              tooltip: loc.translate('logout_dialog_title'),
              icon: Icons.logout_rounded,
              onDarkBackground: true,
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: _viewModel == null
            ? _buildBodyForTab(context, loc, email, null)
            : ListenableBuilder(
                listenable: _viewModel!,
                builder: (context, _) =>
                    _buildBodyForTab(context, loc, email, _viewModel),
              ),
      ),
      bottomNavigationBar: ShiftIQFloatingNavBar(
        key: const Key('customer_navigation_bar'),
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        items: const [
          ShiftIQNavItem(
            key: Key('customer_nav_summary'),
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Resumen',
          ),
          ShiftIQNavItem(
            key: Key('customer_nav_vehicles'),
            icon: Icons.directions_car_outlined,
            selectedIcon: Icons.directions_car_rounded,
            label: 'Vehículos',
          ),
          ShiftIQNavItem(
            key: Key('customer_nav_orders'),
            icon: Icons.build_circle_outlined,
            selectedIcon: Icons.build_circle_rounded,
            label: 'Órdenes',
          ),
        ],
      ),
    );
  }

  Widget _buildBodyForTab(
    BuildContext context,
    AppLocalizations loc,
    String email,
    CustomerHomeViewModel? vm,
  ) {
    final content = switch (_selectedTab) {
      1 => _buildVehiclesTab(vm),
      2 => _buildOrdersAndQuotesTab(context, vm),
      _ => _buildSummaryTab(context, loc, email, vm),
    };

    if (vm == null) return content;

    return ShiftIQPullToRefresh(
      onRefresh: vm.load,
      skeleton: const ShiftIQSkeletonDetail(),
      child: content,
    );
  }

  Widget _buildSummaryTab(
    BuildContext context,
    AppLocalizations loc,
    String email,
    CustomerHomeViewModel? vm,
  ) {
    final summary = vm?.summary;
    final vehiclesCount =
        summary?.activeVehiclesCount ?? vm?.vehicles.length ?? 0;
    final dtcCount = vm?.totalDtcAlertsCount ?? 0;
    final activeOrders =
        vm?.workOrders.where((o) => !o.isCompleted && !o.isPaid).toList() ??
            const <WorkOrder>[];
    final activeOrdersCount =
        summary?.activeWorkOrdersCount ?? activeOrders.length;
    final pendingQuotes =
        vm?.quotes.where((q) => q.status != QuoteStatus.canceled).toList() ??
            const <Quote>[];
    final pendingQuotesCount =
        summary?.pendingQuotesCount ?? pendingQuotes.length;

    final healthRatio = vehiclesCount <= 0
        ? 1.0
        : ((vehiclesCount - dtcCount.clamp(0, vehiclesCount)) / vehiclesCount)
            .clamp(0.0, 1.0);
    final healthPercent = (healthRatio * 100).round();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        _buildWelcomeHero(
          loc,
          email,
          healthPercent: healthPercent,
          healthRatio: healthRatio,
          dtcCount: dtcCount,
        ),
        if (dtcCount > 0) ...[
          const SizedBox(height: 16),
          DtcAlertBanner(
            alertCount: dtcCount,
            onDetailsPressed: () => setState(() => _selectedTab = 1),
          ),
        ],
        const SizedBox(height: 20),
        if (vm != null && vm.isLoading && vm.workOrders.isEmpty && summary == null)
          const ShiftIQSkeletonCardList(itemCount: 2)
        else ...[
          CustomerFleetHealthRingChart(
            activeVehiclesCount: vehiclesCount,
            activeDtcAlertsCount: dtcCount,
            activeWorkOrdersCount: activeOrdersCount,
            pendingQuotesCount: pendingQuotesCount,
          ),
          if (vm != null && vm.workOrders.isNotEmpty) ...[
            const SizedBox(height: 14),
            CustomerWorkOrderSpendingChart(workOrders: vm.workOrders),
          ],
          if (activeOrders.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Text(
              'PROGRESO EN TALLER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            ...activeOrders.take(2).map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CustomerActiveProgressCard(
                      order: order,
                      onTap: () => _openWorkOrder(order),
                    ),
                  ),
                ),
          ],
          if (vm != null &&
              vm.quotes.any(
                (q) => q.status == QuoteStatus.draft || vm.canPayQuote(q),
              )) ...[
            const SizedBox(height: 12),
            const Text(
              'ACCIONES PENDIENTES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            ...vm.quotes
                .where(
                  (q) => q.status == QuoteStatus.draft || vm.canPayQuote(q),
                )
                .map(
                  (quote) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CustomerQuoteCard(
                      quote: quote,
                      canApprove: quote.status == QuoteStatus.draft,
                      isApproving: vm.approvingQuoteId == quote.id,
                      isRejecting: vm.rejectingQuoteId == quote.id,
                      onApprove: () => _handleApproveQuote(context, vm, quote),
                      onReject: () => _handleRejectQuote(context, vm, quote),
                      canPay: vm.canPayQuote(quote),
                      isPaying: vm.payingQuoteId == quote.id,
                      onPay: () => _handlePayQuote(context, vm, quote),
                    ),
                  ),
                ),
          ],
        ],
      ],
    );
  }

  Widget _buildVehiclesTab(CustomerHomeViewModel? vm) {
    final vehicles = vm?.vehicles ?? const <Vehicle>[];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        const Text(
          'MIS VEHÍCULOS Y TELEMETRÍA OBD-II',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        if (vm != null && vm.isLoading && vehicles.isEmpty)
          const ShiftIQSkeletonCardList(itemCount: 2)
        else if (vehicles.isEmpty)
          const _CustomerMessageCard(
            title: 'Sin vehículos registrados',
            subtitle:
                'Cuando registres o vincules un vehículo con el taller verás aquí su estado OBD-II y alertas DTC.',
          )
        else
          ...vehicles.map(
            (vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CustomerVehicleCard(
                vehicle: vehicle,
                alerts: vm?.dtcAlertsForVehicle(vehicle.id) ?? const [],
                onOpenObd2: () => _openVehicleObd2(vehicle),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrdersAndQuotesTab(
    BuildContext context,
    CustomerHomeViewModel? vm,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        const Text(
          'MIS ÓRDENES DE TRABAJO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 12),
        if (vm != null && vm.isLoading && vm.workOrders.isEmpty)
          const ShiftIQSkeletonCardList(itemCount: 2)
        else if (vm != null && vm.error != null && vm.workOrders.isEmpty)
          _CustomerMessageCard(
            title: 'No se pudieron cargar tus órdenes',
            subtitle: vm.error!,
            actionLabel: 'Reintentar',
            onAction: vm.load,
          )
        else if (vm == null || vm.workOrders.isEmpty)
          const _CustomerMessageCard(
            title: 'Sin órdenes de trabajo registradas',
            subtitle:
                'Cuando tu vehículo ingrese al taller podrás seguir aquí su diagnóstico, tareas y evidencias.',
          )
        else
          ...vm.workOrders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CustomerWorkOrderCard(
                order: order,
                onTap: () => _openWorkOrder(order),
              ),
            ),
          ),
        if (vm != null && vm.quotes.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'MIS COTIZACIONES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          ...vm.quotes.map(
            (quote) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CustomerQuoteCard(
                quote: quote,
                canApprove: quote.status == QuoteStatus.draft,
                isApproving: vm.approvingQuoteId == quote.id,
                isRejecting: vm.rejectingQuoteId == quote.id,
                onApprove: () => _handleApproveQuote(context, vm, quote),
                onReject: () => _handleRejectQuote(context, vm, quote),
                canPay: vm.canPayQuote(quote),
                isPaying: vm.payingQuoteId == quote.id,
                onPay: () => _handlePayQuote(context, vm, quote),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleApproveQuote(
    BuildContext context,
    CustomerHomeViewModel vm,
    Quote quote,
  ) async {
    final ok = await vm.approveQuote(quote);
    if (!context.mounted) return;

    ShiftIQToast.show(
      context,
      message: ok
          ? 'Cotización aprobada'
          : (vm.error ?? 'No se pudo aprobar la cotización.'),
      type: ok ? ShiftIQToastType.success : ShiftIQToastType.error,
    );
  }

  Future<void> _handleRejectQuote(
    BuildContext context,
    CustomerHomeViewModel vm,
    Quote quote,
  ) async {
    final ok = await vm.rejectQuote(quote);
    if (!context.mounted) return;

    ShiftIQToast.show(
      context,
      message: ok
          ? 'Cotización rechazada'
          : (vm.error ?? 'No se pudo rechazar la cotización.'),
      type: ok ? ShiftIQToastType.info : ShiftIQToastType.error,
    );
  }

  Future<void> _handlePayQuote(
    BuildContext context,
    CustomerHomeViewModel vm,
    Quote quote,
  ) async {
    final pref = await vm.createMercadoPagoPreference(quote);
    if (!context.mounted) return;

    if (pref == null) {
      ShiftIQToast.show(
        context,
        message: vm.error ?? 'No se pudo generar el enlace de pago.',
        type: ShiftIQToastType.error,
      );
      return;
    }

    final checkoutUrl =
        pref.initPoint.isNotEmpty ? pref.initPoint : pref.sandboxInitPoint;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pago con Mercado Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monto a pagar: ${pref.currency} ${pref.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Copia el enlace oficial de Mercado Pago para completar el pago desde tu navegador.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            if (checkoutUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              SelectableText(
                checkoutUrl,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: ShiftIQColors.primaryBlue,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          if (checkoutUrl.isNotEmpty)
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: checkoutUrl));
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!context.mounted) return;
                ShiftIQToast.show(
                  context,
                  message: 'Enlace de Mercado Pago copiado al portapapeles',
                  type: ShiftIQToastType.success,
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copiar enlace'),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHero(
    AppLocalizations loc,
    String email, {
    required int healthPercent,
    required double healthRatio,
    required int dtcCount,
  }) {
    final healthColor = dtcCount > 0
        ? ShiftIQColors.severityAmber
        : ShiftIQColors.secondaryTeal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ShiftIQColors.secondaryTeal.withAlpha(45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ShiftIQColors.secondaryTeal.withAlpha(120),
                  ),
                ),
                child: Text(
                  loc.translate('role_customer_badge'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Salud $healthPercent%',
                style: TextStyle(
                  color: healthColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            loc.translate('customer_welcome_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: healthRatio,
              minHeight: 7,
              backgroundColor: Colors.white.withAlpha(32),
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dtcCount == 0
                ? 'Tus vehículos operan sin alertas OBD-II activas.'
                : 'Se detectaron $dtcCount alerta(s) DTC. Revisa la pestaña Vehículos.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerActiveProgressCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;

  const _CustomerActiveProgressCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalTasks = order.tasks.length;
    final completedTasks = order.tasks.where((t) => t.isCompleted).length;
    final progress = totalTasks > 0 ? (completedTasks / totalTasks) : 0.15;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ShiftIQColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${order.vehiclePlate} · ${order.formattedNumber}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color.withAlpha(24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: order.status.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    order.status.color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                totalTasks > 0
                    ? '$completedTasks de $totalTasks tareas completadas'
                    : order.diagnosticSummary,
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
      ),
    );
  }
}

class _CustomerVehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final List<DtcAlert> alerts;
  final VoidCallback onOpenObd2;

  const _CustomerVehicleCard({
    required this.vehicle,
    required this.alerts,
    required this.onOpenObd2,
  });

  @override
  Widget build(BuildContext context) {
    final activeAlerts =
        alerts.where((a) => a.status != DtcStatus.resolved).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ShiftIQColors.primaryBlue.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: ShiftIQColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Placa ${vehicle.plateNumber} · VIN ${vehicle.vin.isNotEmpty ? vehicle.vin : "-"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (activeAlerts.isEmpty
                          ? ShiftIQColors.preventiveGreen
                          : ShiftIQColors.severityCrimson)
                      .withAlpha(22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  activeAlerts.isEmpty
                      ? 'Sin alertas'
                      : '${activeAlerts.length} DTC',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: activeAlerts.isEmpty
                        ? ShiftIQColors.preventiveGreen
                        : ShiftIQColors.severityCrimson,
                  ),
                ),
              ),
            ],
          ),
          if (activeAlerts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: activeAlerts.take(3).map((alert) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: alert.severity.color.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: alert.severity.color.withAlpha(55),
                    ),
                  ),
                  child: Text(
                    '${alert.code} · ${alert.severity.label}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: alert.severity.color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 14),
          ShiftIQLiquidButton(
            key: Key('obd2_vehicle_${vehicle.id}'),
            expand: true,
            height: 44,
            borderRadius: 14,
            icon: Icons.sensors_rounded,
            label: 'Ver sensores OBD-II',
            onPressed: onOpenObd2,
          ),
        ],
      ),
    );
  }
}

class _CustomerMessageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CustomerMessageCard({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: Column(
        children: [
          const ShiftIQEmptyStateIcon(),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ShiftIQColors.graphiteText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerQuoteCard extends StatelessWidget {
  final Quote quote;
  final bool canApprove;
  final bool isApproving;
  final bool isRejecting;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool canPay;
  final bool isPaying;
  final VoidCallback onPay;

  const _CustomerQuoteCard({
    required this.quote,
    required this.canApprove,
    required this.isApproving,
    required this.isRejecting,
    required this.onApprove,
    required this.onReject,
    required this.canPay,
    required this.isPaying,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (quote.status) {
      QuoteStatus.approved => ShiftIQColors.preventiveGreen,
      QuoteStatus.canceled => ShiftIQColors.severityCrimson,
      QuoteStatus.draft => const Color(0xFFD97706),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: ShiftIQColors.primaryBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  quote.vehiclePlate.isNotEmpty ? quote.vehiclePlate : 'COT',
                  style: const TextStyle(
                    color: ShiftIQColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quote.vehicleModel.isNotEmpty
                      ? quote.vehicleModel
                      : 'Cotización de servicio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  quote.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${quote.items.length} ítems',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Text(
                'S/ ${quote.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
            ],
          ),
          if (canApprove) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: Key('reject_quote_${quote.id}'),
                    onPressed: (isApproving || isRejecting) ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ShiftIQColors.severityCrimson,
                      side: BorderSide(
                        color: ShiftIQColors.severityCrimson.withAlpha(80),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isRejecting ? 'Rechazando...' : 'Rechazar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    key: Key('approve_quote_${quote.id}'),
                    onPressed: (isApproving || isRejecting) ? null : onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: isApproving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: Text(
                      isApproving ? 'Aprobando...' : 'Aprobar cotización',
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (canPay) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: Key('pay_quote_${quote.id}'),
                onPressed: isPaying ? null : onPay,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF009EE3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: isPaying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.payment_rounded, size: 18),
                label: Text(
                  isPaying ? 'Generando enlace...' : 'Pagar con Mercado Pago',
                ),
              ),
            ),
          ] else if (quote.status == QuoteStatus.approved) ...[
            const SizedBox(height: 8),
            const Text(
              'Aprobada · El pago se habilitará cuando el taller complete la orden.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerWorkOrderCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;

  const _CustomerWorkOrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = order.tasks.where((t) => t.isCompleted).length;
    final totalTasks = order.tasks.length;
    final statusColor = order.status.color;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ShiftIQColors.borderSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ShiftIQColors.graphiteText,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.vehiclePlate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.vehicleModel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(24),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                order.diagnosticSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    order.formattedNumber,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (totalTasks > 0) ...[
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.checklist_rounded,
                      size: 14,
                      color: ShiftIQColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$completedTasks/$totalTasks tareas',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    order.formattedAmount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

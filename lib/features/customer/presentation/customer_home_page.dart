import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_floating_nav_bar.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_navy_banner_fallback.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_tactile_card.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/dtc_alert_banner.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_profile_avatar_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/widgets/customer_analytics_charts.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/widgets/customer_workshop_and_appointments.dart';
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
  int _transitionDirection = 1;

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
      1 => loc.translate('customer_vehicles_header_sub'),
      2 => loc.translate('customer_orders_header_sub'),
      3 => loc.translate('customer_payments_header_sub'),
      _ => email.isNotEmpty ? email : null,
    };

    final headerTitle = switch (_selectedTab) {
      1 => loc.translate('customer_vehicles_title'),
      2 => loc.translate('customer_orders_title'),
      3 => '${loc.translate('quotes')} & ${loc.translate('customer_tab_payments')}',
      _ => loc.translate('customer_portal_title'),
    };

    Widget buildScaffold(BuildContext context) => Scaffold(
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
          ],
        ),
        body: _buildBodyForTab(context, loc, email, _viewModel),
      ),
      floatingActionButton: (_selectedTab == 0 &&
              _viewModel != null &&
              _viewModel!.branches.isNotEmpty)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ShiftIQPrimaryPillButton(
                key: const Key('btn_customer_schedule_appointment'),
                label: loc.translate('customer_schedule_appointment'),
                icon: Icons.calendar_today_rounded,
                onPressed: () =>
                    showCustomerScheduleAppointmentSheet(context, _viewModel!),
              ),
            )
          : (_selectedTab == 1 && _viewModel != null)
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ShiftIQPrimaryPillButton(
                    key: const Key('btn_customer_add_vehicle'),
                    label: loc.translate('add_vehicle'),
                    icon: Icons.add_rounded,
                    onPressed: () => _showAddVehicleSheet(context, _viewModel!),
                  ),
                )
              : null,
      bottomNavigationBar: ShiftIQFloatingNavBar(
        key: const Key('customer_navigation_bar'),
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) {
          if (index == _selectedTab) return;
          setState(() {
            _transitionDirection = index > _selectedTab ? 1 : -1;
            _selectedTab = index;
          });
        },
        items: [
          ShiftIQNavItem(
            key: const Key('customer_nav_summary'),
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: loc.translate('customer_tab_summary'),
          ),
          ShiftIQNavItem(
            key: const Key('customer_nav_vehicles'),
            icon: Icons.directions_car_outlined,
            selectedIcon: Icons.directions_car_rounded,
            label: loc.translate('customer_tab_vehicles'),
          ),
          ShiftIQNavItem(
            key: const Key('customer_nav_orders'),
            icon: Icons.build_circle_outlined,
            selectedIcon: Icons.build_circle_rounded,
            label: loc.translate('customer_tab_orders'),
          ),
          ShiftIQNavItem(
            key: const Key('customer_nav_quotes'),
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: loc.translate('customer_tab_payments'),
          ),
        ],
      ),
    );

    if (_viewModel == null) return buildScaffold(context);
    return ListenableBuilder(
      listenable: _viewModel!,
      builder: (context, _) => buildScaffold(context),
    );
  }

  Widget _buildBodyForTab(
    BuildContext context,
    AppLocalizations loc,
    String email,
    CustomerHomeViewModel? vm,
  ) {
    final content = TweenAnimationBuilder<double>(
      key: ValueKey<int>(_selectedTab),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        final dx = (1.0 - progress) * 0.03 * _transitionDirection;
        return Opacity(
          opacity: 0.55 + (0.45 * progress),
          child: FractionalTranslation(
            translation: Offset(dx, 0),
            child: child,
          ),
        );
      },
      child: switch (_selectedTab) {
        1 => _buildVehiclesTab(context, loc, vm),
        2 => _buildOrdersTab(vm),
        3 => _buildQuotesAndPaymentsTab(context, vm),
        _ => _buildSummaryTab(context, loc, email, vm),
      },
    );

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
    final pendingQuotes = vm?.quotes
            .where(
              (q) =>
                  q.status != QuoteStatus.canceled && !vm.isQuotePaid(q),
            )
            .toList() ??
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
          if (vm != null) ...[
            const SizedBox(height: 22),
            Text(
              loc.translate('customer_my_workshop_section'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            if (vm.branches.isEmpty)
              ShiftIQTactileCard(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store_mall_directory_outlined,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('customer_no_workshop_title'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ShiftIQColors.graphiteText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.translate('customer_no_workshop_subtitle'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...vm.branches.map(
                (branch) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomerWorkshopCard(
                    branch: branch,
                    onScheduleTap: () => showCustomerScheduleAppointmentSheet(
                      context,
                      vm,
                      initialBranchId: branch.branchId,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              loc.translate('customer_upcoming_appointments_section'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            if (summary == null || summary.upcomingAppointments.isEmpty)
              ShiftIQTactileCard(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_note_outlined,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          loc.translate('customer_no_upcoming_appointments'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...summary.upcomingAppointments.map((apt) {
                final branch = vm.branches
                    .where((b) => b.branchId == apt.branchId)
                    .firstOrNull;
                final vehicle = vm.vehicles
                    .where((v) => v.id == apt.vehicleId)
                    .firstOrNull;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CustomerUpcomingAppointmentCard(
                    appointment: apt,
                    branch: branch,
                    vehicle: vehicle,
                  ),
                );
              }),
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
                      isPaid: vm.isQuotePaid(quote),
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

  Widget _buildVehiclesTab(
    BuildContext context,
    AppLocalizations loc,
    CustomerHomeViewModel? vm,
  ) {
    final vehicles = vm?.vehicles ?? const <Vehicle>[];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        if (vm != null && vm.isLoading && vehicles.isEmpty)
          const ShiftIQSkeletonCardList(itemCount: 2)
        else if (vehicles.isEmpty)
          _CustomerMessageCard(
            title: loc.translate('no_vehicles_title'),
            subtitle: loc.translate('no_vehicles_subtitle'),
            actionLabel: vm != null ? loc.translate('add_vehicle') : null,
            onAction:
                vm != null ? () => _showAddVehicleSheet(context, vm) : null,
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

  Future<void> _showAddVehicleSheet(
    BuildContext context,
    CustomerHomeViewModel vm,
  ) async {
    final loc = AppLocalizations.of(context);
    final created = await showModalBottomSheet<Vehicle?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _AddVehicleSheet(vm: vm),
    );

    if (created != null && context.mounted) {
      ShiftIQToast.show(
        context,
        message: loc.translate('vehicle_registered_success'),
        type: ShiftIQToastType.success,
      );
    }
  }

  Widget _buildOrdersTab(CustomerHomeViewModel? vm) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
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
      ],
    );
  }

  Widget _buildQuotesAndPaymentsTab(
    BuildContext context,
    CustomerHomeViewModel? vm,
  ) {
    final quotes = vm?.quotes ?? const <Quote>[];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        if (vm != null && vm.isLoading && quotes.isEmpty)
          const ShiftIQSkeletonCardList(itemCount: 2)
        else if (quotes.isEmpty)
          const _CustomerMessageCard(
            title: 'Sin cotizaciones registradas',
            subtitle:
                'Cuando el taller genere una cotización para tu vehículo podrás aprobarla y pagarla aquí.',
          )
        else
          ...quotes.map(
            (quote) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CustomerQuoteCard(
                quote: quote,
                isPaid: vm!.isQuotePaid(quote),
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

    if (checkoutUrl.isNotEmpty) {
      final uri = Uri.tryParse(checkoutUrl);
      if (uri != null) {
        var launched = false;
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppBrowserView,
          );
          if (!launched) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          }
        } catch (_) {
          launched = false;
        }
        if (launched) {
          if (context.mounted) {
            await vm.load();
          }
          return;
        }
      }
    }

    if (!context.mounted) return;
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

    return ShiftIQTactileCard(
      onTap: onTap,
      child: Container(
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
    final hasPhoto = vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(17)),
            child: SizedBox(
              height: 116,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhoto)
                    Image.network(
                      vehicle.photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const ShiftIQNavyBannerFallback(
                          watermarkIcon: Icons.directions_car_filled_rounded,
                        );
                      },
                      errorBuilder: (_, _, _) =>
                          const ShiftIQNavyBannerFallback(
                        watermarkIcon: Icons.directions_car_filled_rounded,
                      ),
                    )
                  else
                    const ShiftIQNavyBannerFallback(
                      watermarkIcon: Icons.directions_car_filled_rounded,
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0F172A).withValues(alpha: 0.22),
                          const Color(0xFF0F172A).withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            vehicle.plateNumber,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            activeAlerts.isEmpty
                                ? 'Sin alertas'
                                : '${activeAlerts.length} DTC',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: activeAlerts.isEmpty
                                  ? ShiftIQColors.preventiveGreen
                                  : ShiftIQColors.severityCrimson,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
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
  final bool isPaid;
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
    required this.isPaid,
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
    final statusColor = isPaid
        ? ShiftIQColors.primaryBlue
        : switch (quote.status) {
            QuoteStatus.approved => ShiftIQColors.preventiveGreen,
            QuoteStatus.canceled => ShiftIQColors.severityCrimson,
            QuoteStatus.draft => const Color(0xFFD97706),
          };
    final statusLabel = isPaid ? 'Pagado' : quote.status.label;

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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey<String>(statusLabel),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(24),
                    borderRadius: BorderRadius.circular(10),
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
          if (isPaid) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ShiftIQColors.primaryBlue.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ShiftIQColors.primaryBlue.withAlpha(60),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: ShiftIQColors.primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pagado · Comprobante registrado',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ShiftIQColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (canPay) ...[
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

    return ShiftIQTactileCard(
      onTap: onTap,
      child: Container(
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
    );
  }
}

class _AddVehicleSheet extends StatefulWidget {
  final CustomerHomeViewModel vm;

  const _AddVehicleSheet({required this.vm});

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _plateCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  late final TextEditingController _yearCtrl;
  final _vinCtrl = TextEditingController();
  final _picker = ImagePicker();
  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoName;

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedPhotoBytes = bytes;
        _selectedPhotoName = file.name.isNotEmpty ? file.name : 'vehicle.jpg';
      });
    } catch (e) {
      if (!mounted) return;
      ShiftIQToast.show(
        context,
        message: 'No se pudo seleccionar la imagen: $e',
        type: ShiftIQToastType.error,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _yearCtrl = TextEditingController(text: '${DateTime.now().year}');
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _vinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final vm = widget.vm;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.translate('add_vehicle_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_selectedPhotoBytes != null)
                            Image.memory(
                              _selectedPhotoBytes!,
                              fit: BoxFit.cover,
                            )
                          else
                            const ShiftIQNavyBannerFallback(
                              watermarkIcon:
                                  Icons.directions_car_filled_rounded,
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          Center(
                            child: Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  key: const Key('btn_vehicle_photo_gallery'),
                                  onPressed: vm.isUploadingVehiclePhoto
                                      ? null
                                      : () => _pickPhoto(ImageSource.gallery),
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    loc.translate('vehicle_pick_photo_gallery'),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.55),
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  key: const Key('btn_vehicle_photo_camera'),
                                  onPressed: vm.isUploadingVehiclePhoto
                                      ? null
                                      : () => _pickPhoto(ImageSource.camera),
                                  icon: const Icon(
                                    Icons.photo_camera_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    loc.translate('vehicle_pick_photo_camera'),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.55),
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          key: const Key('field_vehicle_plate'),
                          controller: _plateCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: loc.translate('vehicle_plate_label'),
                            hintText: 'ABC-123',
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? loc.translate('plate_required')
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          key: const Key('field_vehicle_year'),
                          controller: _yearCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: loc.translate('vehicle_year_label'),
                          ),
                          validator: (val) {
                            final y = int.tryParse((val ?? '').trim());
                            if (y == null ||
                                y < 1900 ||
                                y > DateTime.now().year + 1) {
                              return loc.translate('vehicle_year_error');
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('field_vehicle_brand'),
                          controller: _brandCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: loc.translate('vehicle_brand_label'),
                            hintText: 'Toyota',
                            prefixIcon:
                                const Icon(Icons.directions_car_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? loc.translate('vehicle_brand_label')
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          key: const Key('field_vehicle_model'),
                          controller: _modelCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: loc.translate('vehicle_model_label'),
                            hintText: 'Corolla',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? loc.translate('vehicle_model_label')
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('field_vehicle_vin'),
                    controller: _vinCtrl,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 17,
                    decoration: InputDecoration(
                      labelText: loc.translate('vehicle_vin_label'),
                      hintText: '9BRBL3HE2P0123456',
                      prefixIcon: const Icon(Icons.qr_code_2_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length != 17) {
                        return loc.translate('vehicle_vin_error');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('btn_submit_add_vehicle'),
                      onPressed: (vm.isRegisteringVehicle ||
                              vm.isUploadingVehiclePhoto)
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              String? uploadedPhotoUrl;
                              if (_selectedPhotoBytes != null &&
                                  _selectedPhotoName != null) {
                                uploadedPhotoUrl = await vm.uploadVehiclePhoto(
                                  fileBytes: _selectedPhotoBytes!,
                                  fileName: _selectedPhotoName!,
                                );
                                if (!context.mounted) return;
                                if (uploadedPhotoUrl == null) {
                                  ShiftIQToast.show(
                                    context,
                                    message: vm.error ??
                                        'No se pudo subir la foto del vehículo',
                                    type: ShiftIQToastType.error,
                                  );
                                  return;
                                }
                              }
                              final vehicle = await vm.addVehicle(
                                plateNumber: _plateCtrl.text,
                                brand: _brandCtrl.text,
                                model: _modelCtrl.text,
                                year: int.parse(_yearCtrl.text.trim()),
                                vin: _vinCtrl.text,
                                photoUrl: uploadedPhotoUrl,
                              );
                              if (!context.mounted) return;
                              if (vehicle != null) {
                                Navigator.of(context).pop(vehicle);
                              } else if (vm.error != null) {
                                ShiftIQToast.show(
                                  context,
                                  message: vm.error!,
                                  type: ShiftIQToastType.error,
                                );
                              }
                            },
                      icon: (vm.isRegisteringVehicle ||
                              vm.isUploadingVehiclePhoto)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        loc.translate('vehicle_save_btn'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: ShiftIQColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/logout.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_profile_avatar_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_page.dart';

/// Dedicated mobile landing shell for `ROLE_USER` / `ROLE_CUSTOMER` accounts.
class CustomerHomePage extends StatefulWidget {
  final CustomerHomeViewModel? viewModel;

  const CustomerHomePage({super.key, this.viewModel});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  CustomerHomeViewModel? _viewModel;

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
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('logout_dialog_title')),
        content: Text(loc.translate('customer_logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ShiftIQColors.severityCrimson,
            ),
            child: Text(loc.translate('logout_upper')),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await getIt<LogoutUseCase>().execute();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(viewModel: getIt<LoginViewModel>()),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final email = getIt.isRegistered<SessionStorage>()
        ? (getIt<SessionStorage>().username ?? '')
        : '';

    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: ShiftIQCollapsibleHeaderBody(
        header: ShiftIQPageHeader(
          title: loc.translate('customer_portal_title'),
          subtitle: email.isNotEmpty ? email : null,
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
            ? _buildBodyContent(context, loc, email, null)
            : ListenableBuilder(
                listenable: _viewModel!,
                builder: (context, _) =>
                    _buildBodyContent(context, loc, email, _viewModel),
              ),
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    AppLocalizations loc,
    String email,
    CustomerHomeViewModel? vm,
  ) {
    final content = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      children: [
        _buildWelcomeHero(loc, email),
        const SizedBox(height: 24),
        Text(
          'MIS ÓRDENES DE TRABAJO',
          style: const TextStyle(
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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkOrderDetailPage(
                        workOrderId: order.id,
                        readOnly: true,
                      ),
                    ),
                  );
                },
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
                canPay: vm.canPayQuote(quote),
                isPaying: vm.payingQuoteId == quote.id,
                onPay: () => _handlePayQuote(context, vm, quote),
              ),
            ),
          ),
        ],
      ],
    );

    if (vm == null) return content;

    return ShiftIQPullToRefresh(
      onRefresh: vm.load,
      skeleton: const ShiftIQSkeletonCardList(itemCount: 2),
      child: content,
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

  Widget _buildWelcomeHero(AppLocalizations loc, String email) {
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
          const SizedBox(height: 14),
          Text(
            loc.translate('customer_welcome_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            loc.translate('customer_welcome_subtitle'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
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
  final bool canPay;
  final bool isPaying;
  final VoidCallback onPay;

  const _CustomerQuoteCard({
    required this.quote,
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
                    Icon(
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

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/controllers/billing_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/checkout_voucher_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/voucher_detail_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/widgets/quote_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/widgets/voucher_card.dart';

/// Minimalist ShiftIQ billing dashboard for SUNAT vouchers and budget quotes.
class BillingDashboardPage extends StatefulWidget {
  final String? branchId;
  final BillingViewModel? viewModel;

  const BillingDashboardPage({
    super.key,
    this.branchId,
    this.viewModel,
  });

  @override
  State<BillingDashboardPage> createState() => _BillingDashboardPageState();
}

class _BillingDashboardPageState extends State<BillingDashboardPage> {
  late final BillingViewModel _viewModel;
  late final String _activeBranchId;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<BillingViewModel>();
    final session =
        getIt.isRegistered<SessionStorage>() ? getIt<SessionStorage>() : null;
    _activeBranchId = widget.branchId ??
        session?.activeBranchId ??
        ApiConstants.defaultBranchId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadBillingData(_activeBranchId);
    });
  }

  void _openCheckout(BillingViewModel viewModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutVoucherPage(
          branchId: _activeBranchId,
          viewModel: viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final viewModel = _viewModel;
        final loc = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          body: Stack(
            children: [
              Column(
                children: [
                  ShiftIQPageHeader(
                    title: loc.translate('billing_title'),
                    subtitle: 'Comprobantes SUNAT y cotizaciones',
                    showBackButton: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: _SegmentedBillingTabs(
                      selectedIndex: _selectedTab,
                      vouchersLabel:
                          '${loc.translate('vouchers')} (${viewModel.vouchers.length})',
                      quotesLabel:
                          '${loc.translate('quotes')} (${viewModel.quotes.length})',
                      onChanged: (index) => setState(() => _selectedTab = index),
                    ),
                  ),
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildVouchersTab(context, viewModel, loc)
                        : _buildQuotesTab(context, viewModel),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 20 + MediaQuery.of(context).padding.bottom,
                child: ShiftIQPrimaryPillButton(
                  icon: Icons.add_rounded,
                  label: loc.translate('emit_voucher_action'),
                  onPressed: () => _openCheckout(viewModel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVouchersTab(
    BuildContext context,
    BillingViewModel viewModel,
    AppLocalizations loc,
  ) {
    return RefreshIndicator(
      color: ShiftIQColors.primaryBlue,
      onRefresh: () => viewModel.loadBillingData(_activeBranchId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
        children: [
          Row(
            children: [
              Expanded(
                child: _BillingKpiCard(
                  icon: Icons.payments_outlined,
                  accentColor: ShiftIQColors.primaryBlue,
                  label: 'Facturación Hoy',
                  value: 'S/ ${viewModel.totalBilledToday.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BillingKpiCard(
                  icon: Icons.pending_actions_outlined,
                  accentColor: ShiftIQColors.severityOrange,
                  label: 'Por Cobrar',
                  value: '${viewModel.pendingPaymentsCount} comprobantes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _BillingFilterPill(
                  label: loc.translate('all'),
                  selected: viewModel.selectedTypeFilter == null,
                  onTap: () => viewModel.filterByType(null, _activeBranchId),
                ),
                const SizedBox(width: 8),
                _BillingFilterPill(
                  label: loc.translate('boletas_filter'),
                  selected:
                      viewModel.selectedTypeFilter == VoucherType.boleta,
                  onTap: () => viewModel.filterByType(
                    VoucherType.boleta,
                    _activeBranchId,
                  ),
                ),
                const SizedBox(width: 8),
                _BillingFilterPill(
                  label: loc.translate('facturas_filter'),
                  selected:
                      viewModel.selectedTypeFilter == VoucherType.factura,
                  onTap: () => viewModel.filterByType(
                    VoucherType.factura,
                    _activeBranchId,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (viewModel.isLoading && viewModel.vouchers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: CircularProgressIndicator(
                  color: ShiftIQColors.primaryBlue,
                ),
              ),
            )
          else if (viewModel.vouchers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 56),
              child: Center(
                child: Column(
                  children: [
                    ShiftIQEmptyStateIcon(),
                    SizedBox(height: 14),
                    Text(
                      'No se encontraron comprobantes emitidos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Desliza hacia abajo para actualizar o emite uno nuevo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...viewModel.vouchers.map(
              (v) => VoucherCard(
                voucher: v,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoucherDetailPage(
                        voucherId: v.id,
                        branchId: _activeBranchId,
                        viewModel: viewModel,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuotesTab(BuildContext context, BillingViewModel viewModel) {
    return RefreshIndicator(
      color: ShiftIQColors.primaryBlue,
      onRefresh: () => viewModel.loadBillingData(_activeBranchId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
        children: [
          if (viewModel.isLoading && viewModel.quotes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(
                child: CircularProgressIndicator(
                  color: ShiftIQColors.primaryBlue,
                ),
              ),
            )
          else if (viewModel.quotes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 56),
              child: Center(
                child: Column(
                  children: [
                    ShiftIQEmptyStateIcon(),
                    SizedBox(height: 14),
                    Text(
                      'No hay cotizaciones registradas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Desliza hacia abajo para actualizar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...viewModel.quotes.map(
              (q) => QuoteCard(
                quote: q,
                onTap: () {
                  ShiftIQToast.show(
                    context,
                    message: 'Cotización ${q.quoteNumber} (${q.status.label})',
                    type: ShiftIQToastType.info,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentedBillingTabs extends StatelessWidget {
  final int selectedIndex;
  final String vouchersLabel;
  final String quotesLabel;
  final ValueChanged<int> onChanged;

  const _SegmentedBillingTabs({
    required this.selectedIndex,
    required this.vouchersLabel,
    required this.quotesLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              icon: Icons.receipt_long_outlined,
              label: vouchersLabel,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SegmentButton(
              icon: Icons.request_quote_outlined,
              label: quotesLabel,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? ShiftIQColors.primaryBlue.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? ShiftIQColors.primaryBlue
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected
                      ? ShiftIQColors.primaryBlue
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingKpiCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String label;
  final String value;

  const _BillingKpiCard({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: ShiftIQColors.graphiteText,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingFilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BillingFilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF0F172A)
                : ShiftIQColors.borderSlate,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_kanban_tab_bar.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton_dummies.dart';
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

class _BillingDashboardPageState extends State<BillingDashboardPage>
    with SingleTickerProviderStateMixin {
  late final BillingViewModel _viewModel;
  late final String _activeBranchId;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              ShiftIQCollapsibleHeaderBody(
                header: ShiftIQPageHeader(
                  title: loc.translate('billing_title'),
                  subtitle: loc.translate('billing_subtitle'),
                  showBackButton: true,
                ),
                body: Column(
                  children: [
                    ShiftIQKanbanTabBar(
                      controller: _tabController,
                      tabs: [
                        ShiftIQKanbanTabItem(
                          label: loc.translate('vouchers'),
                          count: viewModel.vouchers.length,
                        ),
                        ShiftIQKanbanTabItem(
                          label: loc.translate('quotes'),
                          count: viewModel.quotes.length,
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildVouchersTab(context, viewModel, loc),
                          _buildQuotesTab(context, viewModel),
                        ],
                      ),
                    ),
                  ],
                ),
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
    return ShiftIQPullToRefresh(
      onRefresh: () => viewModel.loadBillingData(_activeBranchId),
      skeleton: const ShiftIQSkeletonCardList(itemCount: 3),
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
                  label: loc.translate('today_collections'),
                  value: 'S/ ${viewModel.totalBilledToday.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BillingKpiCard(
                  icon: Icons.pending_actions_outlined,
                  accentColor: ShiftIQColors.severityOrange,
                  label: loc.translate('pending_collections'),
                  value:
                      '${viewModel.pendingPaymentsCount} ${loc.translate('payments_count_suffix')}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (viewModel.isLoading && viewModel.vouchers.isEmpty)
            ShiftIQSkeletonizer(
              enabled: true,
              child: Column(
                children: ShiftIQSkeletonDummies.vouchers()
                    .map((v) => VoucherCard(voucher: v, onTap: () {}))
                    .toList(),
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
    return ShiftIQPullToRefresh(
      onRefresh: () => viewModel.loadBillingData(_activeBranchId),
      skeleton: const ShiftIQSkeletonCardList(itemCount: 3),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
        children: [
          if (viewModel.isLoading && viewModel.quotes.isEmpty)
            ShiftIQSkeletonizer(
              enabled: true,
              child: Column(
                children: ShiftIQSkeletonDummies.quotes()
                    .map((q) => QuoteCard(quote: q, onTap: () {}))
                    .toList(),
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

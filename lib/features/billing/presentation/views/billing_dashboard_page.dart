import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/controllers/billing_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/checkout_voucher_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/voucher_detail_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/widgets/quote_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/widgets/voucher_card.dart';

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
  late final TabController _tabController;
  late final BillingViewModel _viewModel;
  late final String _activeBranchId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = widget.viewModel ?? getIt<BillingViewModel>();
    final session = getIt.isRegistered<SessionStorage>() ? getIt<SessionStorage>() : null;
    _activeBranchId = widget.branchId ?? session?.activeBranchId ?? 'b-01-smp';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadBillingData(_activeBranchId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final viewModel = _viewModel;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Facturación SUNAT y Cotizaciones'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  icon: const Icon(Icons.receipt_long),
                  text: 'Comprobantes (${viewModel.vouchers.length})',
                ),
                Tab(
                  icon: const Icon(Icons.request_quote_outlined),
                  text: 'Cotizaciones (${viewModel.quotes.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Comprobantes Electrónicos SUNAT
              RefreshIndicator(
                onRefresh: () => viewModel.loadBillingData(_activeBranchId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // KPI Banner: Facturación del Día
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Facturación Hoy',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'S/ ${viewModel.totalBilledToday.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warning.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Por Cobrar',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${viewModel.pendingPaymentsCount} comprobantes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Type filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Todos'),
                            selected: viewModel.selectedTypeFilter == null,
                            onSelected: (_) =>
                                viewModel.filterByType(null, _activeBranchId),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Boletas (B001)'),
                            selected:
                                viewModel.selectedTypeFilter == VoucherType.boleta,
                            onSelected: (_) => viewModel.filterByType(
                              VoucherType.boleta,
                              _activeBranchId,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Facturas (F001)'),
                            selected:
                                viewModel.selectedTypeFilter == VoucherType.factura,
                            onSelected: (_) => viewModel.filterByType(
                              VoucherType.factura,
                              _activeBranchId,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (viewModel.isLoading && viewModel.vouchers.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (viewModel.vouchers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_outlined,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No se encontraron comprobantes emitidos',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
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
              ),

              // Tab 2: Cotizaciones Presupuestarias
              RefreshIndicator(
                onRefresh: () => viewModel.loadBillingData(_activeBranchId),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (viewModel.isLoading && viewModel.quotes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (viewModel.quotes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.request_quote_outlined,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No hay cotizaciones registradas',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Cotización ${q.quoteNumber} para ${q.customerName}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutVoucherPage(
                    branchId: _activeBranchId,
                    viewModel: viewModel,
                  ),
                ),
              );
            },
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('EMITIR COMPROBANTE'),
          ),
        );
      },
    );
  }
}

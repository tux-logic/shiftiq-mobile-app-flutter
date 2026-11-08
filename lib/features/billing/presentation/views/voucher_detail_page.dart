import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/controllers/billing_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/widgets/fiscal_summary_card.dart';

class VoucherDetailPage extends StatefulWidget {
  final String voucherId;
  final String branchId;
  final BillingViewModel? viewModel;

  const VoucherDetailPage({
    super.key,
    required this.voucherId,
    required this.branchId,
    this.viewModel,
  });

  @override
  State<VoucherDetailPage> createState() => _VoucherDetailPageState();
}

class _VoucherDetailPageState extends State<VoucherDetailPage> {
  late final BillingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<BillingViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadVoucherDetail(widget.voucherId);
    });
  }

  void _showPaymentModal(BuildContext context) {
    PaymentMethod selected = PaymentMethod.cash;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final vm = _viewModel;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registrar Cobro en Caja',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Seleccione la modalidad de pago para liquidar este comprobante:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PaymentMethod.values.map((method) {
                      return ChoiceChip(
                        label: Text(method.label),
                        selected: selected == method,
                        onSelected: (val) {
                          if (val) setModalState(() => selected = method);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              final scaffold = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(modalCtx);
                              final success = await _viewModel.processPayment(
                                voucherId: widget.voucherId,
                                paymentMethod: selected,
                                branchId: widget.branchId,
                              );
                              if (success && mounted) {
                                navigator.pop();
                                scaffold.showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Cobro registrado exitosamente!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        vm.isLoading ? 'REGISTRANDO...' : 'CONFIRMAR COBRO',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final viewModel = _viewModel;
        final voucher = viewModel.selectedVoucher;

        if (viewModel.isLoading && voucher == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (voucher == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de Comprobante')),
            body: Center(
              child: Text(
                viewModel.errorMessage ?? 'No se encontró el comprobante',
              ),
            ),
          );
        }

        final isPaid = voucher.status == VoucherStatus.paid;

        return Scaffold(
          appBar: AppBar(
            title: Text('${voucher.voucherType.label} ${voucher.fullCode}'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Compartir por WhatsApp',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Enlace de descarga de ${voucher.fullCode} copiado al portapapeles',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and Series Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppColors.success.withValues(alpha: 0.08)
                        : AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle : Icons.pending_actions,
                        color: isPaid ? AppColors.success : AppColors.warning,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher.fullCode,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Estado: ${voucher.status.label}',
                              style: TextStyle(
                                color: isPaid
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isPaid)
                        ElevatedButton(
                          onPressed: () => _showPaymentModal(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('COBRAR'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Emitted client info
                const Text(
                  'DATOS DEL ADQUIRIENTE / CLIENTE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Cliente / Razón Social:', voucher.customerName),
                      const Divider(height: 16),
                      _infoRow(
                        '${voucher.customerDocumentType}:',
                        voucher.customerDocumentNumber,
                      ),
                      if (voucher.customerAddress != null) ...[
                        const Divider(height: 16),
                        _infoRow('Dirección Fiscal:', voucher.customerAddress!),
                      ],
                      const Divider(height: 16),
                      _infoRow(
                        'Fecha de Emisión:',
                        '${voucher.issuedAt.day.toString().padLeft(2, '0')}/${voucher.issuedAt.month.toString().padLeft(2, '0')}/${voucher.issuedAt.year} ${voucher.issuedAt.hour.toString().padLeft(2, '0')}:${voucher.issuedAt.minute.toString().padLeft(2, '0')}',
                      ),
                      const Divider(height: 16),
                      _infoRow('Método de Pago:', voucher.paymentMethod.label),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Items list
                const Text(
                  'DETALLE DE SERVICIOS Y REPUESTOS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: voucher.items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final it = voucher.items[idx];
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          it.itemType == VoucherItemType.service
                              ? Icons.build_circle_outlined
                              : Icons.inventory_2_outlined,
                          color: it.itemType == VoucherItemType.service
                              ? AppColors.primary
                              : AppColors.secondary,
                        ),
                        title: Text(
                          it.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Cant: ${it.quantity} x S/ ${it.unitPrice.toStringAsFixed(2)}',
                        ),
                        trailing: Text(
                          'S/ ${it.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Fiscal totals
                FiscalSummaryCard(
                  subtotal: voucher.subtotal,
                  igv: voucher.igv,
                  total: voucher.total,
                ),
                const SizedBox(height: 24),

                // SUNAT Security block (QR simulation & Hash)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_2,
                            size: 56,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FIRMA ELECTRÓNICA SUNAT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucher.sunatHash,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Representación impresa de la Boleta/Factura Electrónica consultable en www.sunat.gob.pe',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Thermal printer and PDF actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Enviando ticket a impresora térmica Bluetooth...',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.print_outlined),
                        label: const Text('TICKET TÉRMICO'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Descargando PDF oficial SUNAT (${voucher.fullCode}.pdf)...',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('PDF SUNAT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

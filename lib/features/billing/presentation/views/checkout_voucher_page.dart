import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/entities/voucher_item.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/payment_method.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/model/valueobjects/voucher_type.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/controllers/billing_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/voucher_detail_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/widgets/fiscal_summary_card.dart';

class CheckoutVoucherPage extends StatefulWidget {
  final String branchId;
  final String? workOrderId;
  final String? initialCustomerName;
  final String? initialPlate;
  final List<VoucherItem>? initialItems;
  final BillingViewModel? viewModel;

  const CheckoutVoucherPage({
    super.key,
    required this.branchId,
    this.workOrderId,
    this.initialCustomerName,
    this.initialPlate,
    this.initialItems,
    this.viewModel,
  });

  @override
  State<CheckoutVoucherPage> createState() => _CheckoutVoucherPageState();
}

class _CheckoutVoucherPageState extends State<CheckoutVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  late final BillingViewModel _viewModel;
  late VoucherType _selectedType;
  late String _docType;
  late TextEditingController _docNumberController;
  late TextEditingController _customerNameController;
  late TextEditingController _addressController;
  late PaymentMethod _selectedPaymentMethod;
  late List<VoucherItem> _items;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<BillingViewModel>();
    _selectedType = VoucherType.boleta;
    _docType = 'DNI';
    _docNumberController = TextEditingController(text: '45678901');
    _customerNameController = TextEditingController(
      text: widget.initialCustomerName ?? 'Carlos Mendoza',
    );
    _addressController = TextEditingController(
      text: 'Av. Universitaria 1240, San Martín de Porres, Lima',
    );
    _selectedPaymentMethod = PaymentMethod.cash;

    _items = widget.initialItems != null && widget.initialItems!.isNotEmpty
        ? List.from(widget.initialItems!)
        : [
            const VoucherItem(
              id: 'it-1',
              description: 'Diagnóstico y Escaneo Computarizado OBD-II',
              itemType: VoucherItemType.service,
              quantity: 1,
              unitPrice: 80.0,
              totalPrice: 80.0,
            ),
            const VoucherItem(
              id: 'it-2',
              description: 'Cambio de pastillas delanteras',
              itemType: VoucherItemType.service,
              quantity: 1,
              unitPrice: 120.0,
              totalPrice: 120.0,
            ),
            const VoucherItem(
              id: 'it-3',
              description: 'Pastillas Bosch Delanteras (Repuesto)',
              itemType: VoucherItemType.sparePart,
              quantity: 1,
              unitPrice: 100.0,
              totalPrice: 100.0,
            ),
            const VoucherItem(
              id: 'it-4',
              description: 'Rectificado de discos ventilados delanteros',
              itemType: VoucherItemType.service,
              quantity: 1,
              unitPrice: 150.0,
              totalPrice: 150.0,
            ),
          ];
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _customerNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onTypeChanged(VoucherType newType) {
    setState(() {
      _selectedType = newType;
      if (newType == VoucherType.factura) {
        _docType = 'RUC';
        if (_docNumberController.text == '45678901') {
          _docNumberController.text = '20601893451';
          _customerNameController.text = 'Transportes Rápidos Lima S.A.C.';
        }
      } else {
        _docType = 'DNI';
        if (_docNumberController.text == '20601893451') {
          _docNumberController.text = '45678901';
          _customerNameController.text =
              widget.initialCustomerName ?? 'Carlos Mendoza';
        }
      }
    });
  }

  double get _total => _items.fold(0.0, (acc, i) => acc + i.totalPrice);
  double get _subtotal => double.parse((_total / 1.18).toStringAsFixed(2));
  double get _igv => double.parse((_total - _subtotal).toStringAsFixed(2));

  Future<void> _submitEmission() async {
    if (!_formKey.currentState!.validate()) return;

    final emitted = await _viewModel.emitVoucher(
      branchId: widget.branchId,
      workOrderId: widget.workOrderId ?? 'w1w2w3w4-1111-2222-3333-444455556666',
      voucherType: _selectedType,
      customerDocumentType: _docType,
      customerDocumentNumber: _docNumberController.text.trim(),
      customerName: _customerNameController.text.trim(),
      customerAddress: _addressController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      items: _items,
    );

    if (emitted != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Comprobante ${emitted.fullCode} emitido a SUNAT exitosamente!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoucherDetailPage(
            voucherId: emitted.id,
            branchId: widget.branchId,
            viewModel: _viewModel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final viewModel = _viewModel;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Liquidación y Facturación SUNAT'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle / Customer banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.car_repair, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vehículo: ${widget.initialPlate ?? "Toyota Hilux (ABC-123)"}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Orden de Trabajo: #${widget.workOrderId?.substring(0, 8) ?? "1042"}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tipo de Comprobante
                  const Text(
                    'TIPO DE COMPROBANTE FISCAL (SUNAT)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Boleta de Venta (B001)')),
                          selected: _selectedType == VoucherType.boleta,
                          onSelected: (_) => _onTypeChanged(VoucherType.boleta),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Factura (F001)')),
                          selected: _selectedType == VoucherType.factura,
                          onSelected: (_) => _onTypeChanged(VoucherType.factura),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Datos del Cliente y Documento
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: DropdownButtonFormField<String>(
                          initialValue: _docType,
                          decoration: const InputDecoration(
                            labelText: 'Doc.',
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                            DropdownMenuItem(value: 'RUC', child: Text('RUC')),
                            DropdownMenuItem(value: 'CE', child: Text('CE')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _docType = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _docNumberController,
                          decoration: InputDecoration(
                            labelText: 'Número de $_docType',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Requerido';
                            if (_docType == 'DNI' && v.trim().length != 8) {
                              return 'DNI requiere 8 dígitos';
                            }
                            if (_docType == 'RUC' && v.trim().length != 11) {
                              return 'RUC requiere 11 dígitos';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Razón Social / Nombre Completo',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección Fiscal (Lima)',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resumen de Servicios y Repuestos
                  const Text(
                    'DETALLE DE SERVICIOS Y REPUESTOS EN BAHÍA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            item.itemType == VoucherItemType.service
                                ? Icons.build_circle_outlined
                                : Icons.inventory_2_outlined,
                            color: item.itemType == VoucherItemType.service
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                          title: Text(
                            item.description,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Cant: ${item.quantity} x S/ ${item.unitPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            'S/ ${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fiscal Summary (Subtotal, IGV 18%, Total)
                  FiscalSummaryCard(
                    subtotal: _subtotal,
                    igv: _igv,
                    total: _total,
                  ),
                  const SizedBox(height: 20),

                  // Método de Pago
                  const Text(
                    'MÉTODO DE PAGO Y COBRO EN CAJA',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PaymentMethod.values.map((method) {
                      return ChoiceChip(
                        label: Text(method.label),
                        selected: _selectedPaymentMethod == method,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedPaymentMethod = method);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Error display
                  if (viewModel.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: viewModel.isLoading ? null : _submitEmission,
                      icon: viewModel.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.receipt),
                      label: Text(
                        viewModel.isLoading
                            ? 'EMITIENDO A SUNAT...'
                            : 'EMITIR ${_selectedType.label.toUpperCase()} S/ ${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

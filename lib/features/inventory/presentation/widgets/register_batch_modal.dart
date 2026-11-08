import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/commandservices/register_batch_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/controllers/inventory_view_model.dart';

class RegisterBatchModal extends StatefulWidget {
  final Product product;
  final String branchId;
  final InventoryViewModel viewModel;

  const RegisterBatchModal({
    super.key,
    required this.product,
    required this.branchId,
    required this.viewModel,
  });

  @override
  State<RegisterBatchModal> createState() => _RegisterBatchModalState();
}

class _RegisterBatchModalState extends State<RegisterBatchModal> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _batchNumberCtrl;
  late final TextEditingController _supplierNameCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _costPriceCtrl;

  DateTime? _expirationDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _batchNumberCtrl = TextEditingController(
      text: 'LOT-${widget.product.sku.replaceAll('-', '')}-${now.month}${now.day}',
    );
    _supplierNameCtrl = TextEditingController(
      text: widget.product.batches.isNotEmpty
          ? widget.product.batches.first.supplierName
          : 'Distribuidora Automotriz Lima',
    );
    _quantityCtrl = TextEditingController(text: '10');
    _costPriceCtrl = TextEditingController(
      text: widget.product.costPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _batchNumberCtrl.dispose();
    _supplierNameCtrl.dispose();
    _quantityCtrl.dispose();
    _costPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final command = RegisterBatchCommand(
      branchId: widget.branchId,
      productId: widget.product.id,
      batchNumber: _batchNumberCtrl.text,
      supplierName: _supplierNameCtrl.text,
      quantity: int.tryParse(_quantityCtrl.text) ?? 1,
      costPrice: double.tryParse(_costPriceCtrl.text) ?? widget.product.costPrice,
      expirationDate: _expirationDate,
    );

    final success = await widget.viewModel.registerBatch(command, widget.branchId);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lote ingresado correctamente. Nuevo stock: ${widget.product.currentStock + command.quantity} ${widget.product.unitOfMeasure}',
          ),
          backgroundColor: ShiftIQColors.preventiveGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingreso de Lote a Inventario',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.product.sku} · ${widget.product.name}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: ShiftIQColors.borderSlate),

              // Batch Number & Supplier
              TextFormField(
                controller: _batchNumberCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Número de Lote / Factura *',
                  prefixIcon: Icon(Icons.qr_code_outlined),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Ingrese el lote' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _supplierNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Proveedor / Distribuidor *',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Ingrese el proveedor'
                    : null,
              ),
              const SizedBox(height: 12),

              // Quantity & Cost Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cantidad (${widget.product.unitOfMeasure}) *',
                        prefixIcon: const Icon(Icons.inventory_outlined),
                      ),
                      validator: (val) {
                        final n = int.tryParse(val ?? '');
                        if (n == null || n <= 0) return 'Mayor a 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Costo Unit. (S/) *',
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                      ),
                      validator: (val) {
                        final n = double.tryParse(val ?? '');
                        if (n == null || n < 0) return 'Válido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Expiration Date (Optional)
              InkWell(
                onTap: _pickExpirationDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: ShiftIQColors.borderSlate),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: ShiftIQColors.primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _expirationDate == null
                            ? 'Fecha de Vencimiento (Opcional)'
                            : 'Vence: ${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}',
                        style: TextStyle(
                          color: _expirationDate == null
                              ? const Color(0xFF64748B)
                              : ShiftIQColors.graphiteText,
                          fontWeight: _expirationDate == null
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_shopping_cart_outlined),
                  label: Text(
                    _isLoading ? 'Registrando...' : 'Ingresar Lote al Inventario',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
  }
}

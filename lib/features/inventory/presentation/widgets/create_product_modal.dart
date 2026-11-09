import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/controllers/inventory_view_model.dart';

class CreateProductModal extends StatefulWidget {
  final String branchId;
  final InventoryViewModel viewModel;

  const CreateProductModal({
    super.key,
    required this.branchId,
    required this.viewModel,
  });

  @override
  State<CreateProductModal> createState() => _CreateProductModalState();
}

class _CreateProductModalState extends State<CreateProductModal> {
  final _formKey = GlobalKey<FormState>();

  final _skuCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '10');
  final _minStockCtrl = TextEditingController(text: '5');

  String _selectedCategory = 'LUBRICANTES';
  String _selectedUnit = 'UND';
  bool _isLoading = false;

  final List<String> _categories = [
    'LUBRICANTES',
    'FILTROS',
    'FRENOS',
    'SUSPENSION',
    'MOTOR',
    'ILUMINACION',
  ];

  final List<String> _units = [
    'UND',
    'GALON',
    'LITRO',
    'JUEGO',
    'PAR',
    'KIT',
  ];

  @override
  void dispose() {
    _skuCtrl.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _costPriceCtrl.dispose();
    _stockCtrl.dispose();
    _minStockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await widget.viewModel.createProduct(
      branchId: widget.branchId,
      sku: _skuCtrl.text,
      name: _nameCtrl.text,
      category: _selectedCategory,
      unitOfMeasure: _selectedUnit,
      salePrice: double.tryParse(_sellingPriceCtrl.text) ?? 0.0,
      costPrice: double.tryParse(_costPriceCtrl.text) ?? 0.0,
      initialStock: int.tryParse(_stockCtrl.text) ?? 0,
      minimumStock: int.tryParse(_minStockCtrl.text) ?? 5,
      description: _descCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Repuesto registrado exitosamente en el catálogo'),
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
                  const Text(
                    'Nuevo Repuesto en Catálogo',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 20, color: ShiftIQColors.borderSlate),

              // SKU & Category
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _skuCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Código SKU *',
                        hintText: 'Ej. FLT-AIR-22',
                        prefixIcon: Icon(Icons.qr_code_outlined),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Nombre del Repuesto *',
                  hintText: 'Ej. Filtro de Aire Mann C25114',
                  prefixIcon: Icon(Icons.build_outlined),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 12),

              // Selling Price & Cost Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio Venta (S/) *',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                      validator: (val) {
                        final n = double.tryParse(val ?? '');
                        if (n == null || n <= 0) return 'Mayor a 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Costo Compra (S/) *',
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

              // Stock & Min Stock & Unit
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Inicial *',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Alerta Mínima *',
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                      ),
                      items: _units
                          .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Aplicación / Compatibilidad (Opcional)',
                  hintText: 'Ej. Compatible con motores 1.5L Toyota 2NR-FE...',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'Guardar en Catálogo',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/entities/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/controllers/inventory_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/widgets/register_batch_modal.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/widgets/stock_indicator_chip.dart';

class ProductDetailPage extends StatefulWidget {
  final Product initialProduct;
  final String branchId;
  final InventoryViewModel viewModel;

  const ProductDetailPage({
    super.key,
    required this.initialProduct,
    required this.branchId,
    required this.viewModel,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadProductDetail(widget.initialProduct.id);
  }

  void _openAddBatch(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RegisterBatchModal(
        product: product,
        branchId: widget.branchId,
        viewModel: widget.viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final product = widget.viewModel.selectedProduct ?? widget.initialProduct;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.sku,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Kardex y Lotes · ${product.category}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Actualizar',
                icon: const Icon(Icons.refresh),
                onPressed: () => widget.viewModel.loadProductDetail(product.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ShiftIQColors.primaryBlue.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ShiftIQColors.primaryBlue,
                              ),
                            ),
                          ),
                          const Spacer(),
                          StockIndicatorChip(
                            status: product.status,
                            currentStock: product.currentStock,
                            unit: product.unitOfMeasure.toLowerCase(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          product.description,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // KPIs Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBox(
                        title: 'Stock Actual',
                        value: '${product.currentStock} ${product.unitOfMeasure}',
                        subtitle: 'Alerta mín: ${product.minimumStock}',
                        icon: Icons.inventory_2_outlined,
                        color: product.isOptimalStock
                            ? ShiftIQColors.preventiveGreen
                            : ShiftIQColors.severityAmber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricBox(
                        title: 'Valuación',
                        value: product.formattedTotalValue,
                        subtitle: 'Costo total en almacén',
                        icon: Icons.savings_outlined,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBox(
                        title: 'Precio Venta',
                        value: product.formattedUnitPrice,
                        subtitle: 'Por ${product.unitOfMeasure}',
                        icon: Icons.sell_outlined,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricBox(
                        title: 'Margen Bruto',
                        value: '+S/ ${product.profitMargin.toStringAsFixed(2)}',
                        subtitle: '${product.marginPercentage.toStringAsFixed(1)}% retorno',
                        icon: Icons.trending_up,
                        color: ShiftIQColors.preventiveGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Batches Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lotes de Compra & Kardex (${product.batches.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _openAddBatch(product),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ingresar Lote'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ShiftIQColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Batches List
                if (product.batches.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ShiftIQColors.borderSlate),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 40,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No hay lotes registrados para este repuesto',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pulsa "+ Ingresar Lote" para registrar el primer despacho',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                else
                  ...product.batches.map((batch) => _buildBatchCard(batch, product)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(ProductBatch batch, Product product) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: ShiftIQColors.borderSlate),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    batch.batchNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  batch.formattedDate,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: batch.isDepleted
                        ? ShiftIQColors.severityCrimson.withAlpha(20)
                        : ShiftIQColors.preventiveGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    batch.isDepleted
                        ? 'Agotado'
                        : '${batch.quantityRemaining} ${product.unitOfMeasure} restantes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: batch.isDepleted
                          ? ShiftIQColors.severityCrimson
                          : ShiftIQColors.preventiveGreen,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 18, color: ShiftIQColors.borderSlate),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROVEEDOR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      batch.supplierName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'COSTO UNITARIO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      batch.formattedCost,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

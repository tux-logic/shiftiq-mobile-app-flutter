import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/controllers/inventory_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/views/product_detail_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/widgets/create_product_modal.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/widgets/product_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/widgets/register_batch_modal.dart';

class InventoryPage extends StatefulWidget {
  final String? branchId;
  final InventoryViewModel? viewModel;

  const InventoryPage({
    super.key,
    this.branchId,
    this.viewModel,
  });

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late final InventoryViewModel _viewModel;
  late final String _effectiveBranchId;
  String _branchName = 'Sede Principal';

  final _searchController = TextEditingController();

  final List<String> _categories = [
    'TODOS',
    'LUBRICANTES',
    'FILTROS',
    'FRENOS',
    'SUSPENSION',
    'MOTOR',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<InventoryViewModel>();
    final session = getIt.isRegistered<SessionStorage>() ? getIt<SessionStorage>() : null;
    _effectiveBranchId = widget.branchId ?? session?.activeBranchId ?? 'b-01-smp';
    _branchName = session?.activeBranchName ?? 'Sede San Martín de Porres';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProducts(_effectiveBranchId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateProductModal(
        branchId: _effectiveBranchId,
        viewModel: _viewModel,
      ),
    );
  }

  void _openRegisterBatch(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => RegisterBatchModal(
        product: product,
        branchId: _effectiveBranchId,
        viewModel: _viewModel,
      ),
    );
  }

  void _openProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          initialProduct: product,
          branchId: _effectiveBranchId,
          viewModel: _viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventario & Lotes B2B',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Catálogo de Repuestos · $_branchName',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.loadProducts(_effectiveBranchId),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final products = _viewModel.products;
          final isLoading = _viewModel.isLoading;
          final error = _viewModel.errorMessage;

          return Column(
            children: [
              // Search Bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => _viewModel.search(val, _effectiveBranchId),
                  decoration: InputDecoration(
                    hintText: 'Buscar por SKU, nombre o categoría...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _viewModel.search('', _effectiveBranchId);
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: ShiftIQColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // KPI Summary Metrics Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: ShiftIQColors.borderSlate),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSummaryPill(
                        label: 'Total: ${_viewModel.totalProductsCount} repuestos',
                        color: ShiftIQColors.primaryBlue,
                        isSelected: _viewModel.selectedStatusFilter == null,
                        onTap: () => _viewModel.filterByStatus(null, _effectiveBranchId),
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryPill(
                        label: 'Crítico: ${_viewModel.lowStockCount}',
                        color: ShiftIQColors.severityAmber,
                        isSelected: _viewModel.selectedStatusFilter == StockStatus.lowStock,
                        onTap: () => _viewModel.filterByStatus(StockStatus.lowStock, _effectiveBranchId),
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryPill(
                        label: 'Agotado: ${_viewModel.outOfStockCount}',
                        color: ShiftIQColors.severityCrimson,
                        isSelected: _viewModel.selectedStatusFilter == StockStatus.outOfStock,
                        onTap: () => _viewModel.filterByStatus(StockStatus.outOfStock, _effectiveBranchId),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ShiftIQColors.preventiveGreen.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Valuación: ${_viewModel.formattedTotalValuation}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ShiftIQColors.preventiveGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Filter Chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _viewModel.selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: ShiftIQColors.primaryBlue.withAlpha(30),
                          checkmarkColor: ShiftIQColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? ShiftIQColors.primaryBlue
                                : ShiftIQColors.graphiteText,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11,
                          ),
                          onSelected: (_) =>
                              _viewModel.selectCategory(cat, _effectiveBranchId),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              if (error != null)
                Container(
                  color: ShiftIQColors.severityCrimson.withAlpha(20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: ShiftIQColors.severityCrimson, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                              color: ShiftIQColors.severityCrimson, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Products List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No se encontraron repuestos',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Prueba con otra categoría o añade uno nuevo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: _openCreateProduct,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Registrar Nuevo Repuesto'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: ShiftIQColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                product: product,
                                onTap: () => _openProductDetail(product),
                                onAddBatch: () => _openRegisterBatch(product),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateProduct,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Repuesto'),
        backgroundColor: ShiftIQColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummaryPill({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

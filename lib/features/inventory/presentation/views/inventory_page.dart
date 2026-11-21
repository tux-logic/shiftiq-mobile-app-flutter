import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_kanban_tab_bar.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton_dummies.dart';
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

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  static const List<StockStatus?> _tabStatuses = [
    null,
    StockStatus.lowStock,
    StockStatus.outOfStock,
  ];

  late final InventoryViewModel _viewModel;
  late final TabController _tabController;
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
    _tabController = TabController(length: _tabStatuses.length, vsync: this);
    _tabController.addListener(_handleTabChanged);
    final session = getIt.isRegistered<SessionStorage>() ? getIt<SessionStorage>() : null;
    _effectiveBranchId = widget.branchId ?? session?.activeBranchId ?? ApiConstants.defaultBranchId;
    _branchName = session?.activeBranchName ?? ApiConstants.defaultBranchName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProducts(_effectiveBranchId);
    });
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    _viewModel.filterByStatus(
      _tabStatuses[_tabController.index],
      _effectiveBranchId,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
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

  void _openCategoryFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ShiftIQColors.borderSlate,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Filtrar por categoría',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: _categories.map((cat) {
                    final isSelected = _viewModel.selectedCategory == cat;
                    return _buildFilterPill(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _viewModel.selectCategory(cat, _effectiveBranchId);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: Column(
        children: [
          ShiftIQPageHeader(
            title: 'Inventario & Lotes B2B',
            subtitle: 'Catálogo de Repuestos · $_branchName',
          ),
          Expanded(
            child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final isLoading = _viewModel.isLoading;
          final error = _viewModel.errorMessage;

          return Column(
            children: [
              // Search + Category Filter Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            _viewModel.search(val, _effectiveBranchId),
                        decoration: InputDecoration(
                          hintText: loc.translate('search_product_hint'),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    _viewModel.search('', _effectiveBranchId);
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: ShiftIQColors.borderSlate,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: ShiftIQColors.borderSlate,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: _viewModel.selectedCategory != 'TODOS'
                          ? const Color(0xFF0F172A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: _openCategoryFilterSheet,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _viewModel.selectedCategory != 'TODOS'
                                  ? const Color(0xFF0F172A)
                                  : ShiftIQColors.borderSlate,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: _viewModel.selectedCategory != 'TODOS'
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Minimalist Kanban TabBar for Stock Status
              ShiftIQKanbanTabBar(
                controller: _tabController,
                tabs: [
                  ShiftIQKanbanTabItem(
                    label: 'Todos',
                    count: _viewModel.productsForStatus(null).length,
                  ),
                  ShiftIQKanbanTabItem(
                    label: 'Stock Crítico',
                    count: _viewModel
                        .productsForStatus(StockStatus.lowStock)
                        .length,
                  ),
                  ShiftIQKanbanTabItem(
                    label: 'Agotado',
                    count: _viewModel
                        .productsForStatus(StockStatus.outOfStock)
                        .length,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quiet Summary Line (Active Category + Total Valuation)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Row(
                  children: [
                    if (_viewModel.selectedCategory != 'TODOS')
                      GestureDetector(
                        onTap: () => _viewModel.selectCategory(
                          'TODOS',
                          _effectiveBranchId,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ShiftIQColors.primaryBlue.withAlpha(18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _viewModel.selectedCategory,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: ShiftIQColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: ShiftIQColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      'Valuación total: ${_viewModel.formattedTotalValuation}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
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

              // Swipeable Kanban TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabStatuses
                      .map((status) => _buildProductsTab(loc, isLoading, status))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.products.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 84),
            child: ShiftIQPrimaryPillButton(
              label: loc.translate('new_product'),
              icon: Icons.add_rounded,
              onPressed: _openCreateProduct,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsTab(
    AppLocalizations loc,
    bool isLoading,
    StockStatus? status,
  ) {
    final tabProducts = _viewModel.productsForStatus(status);
    return ShiftIQPullToRefresh(
      onRefresh: () => _viewModel.loadProducts(_effectiveBranchId),
      skeleton: _buildProductSkeletonList(),
      child: ShiftIQContentTransition(
        child: isLoading && tabProducts.isEmpty
            ? _buildProductSkeletonList()
            : tabProducts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(32, 64, 32, 120),
                    children: [
                      const Center(child: ShiftIQEmptyStateIcon()),
                      const SizedBox(height: 16),
                      const Text(
                        'No se encontraron repuestos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Prueba con otra categoría o añade uno nuevo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ShiftIQPrimaryPillButton(
                          label: loc.translate('register_new_product'),
                          icon: Icons.add_rounded,
                          onPressed: _openCreateProduct,
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: tabProducts.length,
                    itemBuilder: (context, index) {
                      final product = tabProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _openProductDetail(product),
                        onAddBatch: () => _openRegisterBatch(product),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildProductSkeletonList() {
    final dummies = ShiftIQSkeletonDummies.products();
    return ShiftIQSkeletonizer(
      key: const ValueKey('inv_loading'),
      enabled: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        itemCount: dummies.length,
        itemBuilder: (_, index) => ProductCard(
          product: dummies[index],
          onTap: () {},
          onAddBatch: () {},
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool subtle = false,
  }) {
    final activeBg =
        subtle ? ShiftIQColors.primaryBlue : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: subtle ? 12 : 14,
          vertical: subtle ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeBg : ShiftIQColors.borderSlate,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBg.withAlpha(28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: subtle ? 12 : 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

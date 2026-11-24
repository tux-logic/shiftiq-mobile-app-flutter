import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/spare_part_thumbnail.dart';

/// Modal bottom sheet allowing workshop staff to select a real inventory
/// spare part from the active branch and dispatch a stock-bounded quantity.
class SparePartPickerSheet extends StatefulWidget {
  final Future<List<Product>> Function() loadProducts;
  final Future<String?> Function(Product product, int quantity) onDispatch;
  final Set<String> attachedProductIds;

  const SparePartPickerSheet({
    super.key,
    required this.loadProducts,
    required this.onDispatch,
    this.attachedProductIds = const {},
  });

  @override
  State<SparePartPickerSheet> createState() => _SparePartPickerSheetState();
}

class _SparePartPickerSheetState extends State<SparePartPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _loadError;
  String? _submitError;
  List<Product> _products = const [];
  Product? _selectedProduct;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final items = await widget.loadProducts();
      if (!mounted) return;
      setState(() {
        _products = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
    }).toList();
  }

  bool _isSelectable(Product product) {
    return product.currentStock > 0 &&
        !widget.attachedProductIds.contains(product.id);
  }

  void _selectProduct(Product product) {
    if (!_isSelectable(product)) return;
    setState(() {
      _selectedProduct = product;
      _quantity = 1;
      _submitError = null;
    });
  }

  Future<void> _handleDispatch() async {
    final selected = _selectedProduct;
    if (selected == null || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    final error = await widget.onDispatch(selected, _quantity);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _submitError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final filtered = _filteredProducts;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.78,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ShiftIQColors.primaryBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: ShiftIQColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('dispatch_part_stock'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                          const Text(
                            'Catálogo real de inventario de la sede',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, SKU o categoría...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear_rounded, size: 18),
                          )
                        : null,
                    filled: true,
                    fillColor: ShiftIQColors.warmNeutral,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: ShiftIQColors.borderSlate,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: ShiftIQColors.borderSlate,
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: ShiftIQColors.borderSlate),
              Expanded(
                child: _buildBody(filtered),
              ),
              if (_selectedProduct != null) _buildDispatchBar(loc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<Product> filtered) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: ShiftIQSkeletonCardList(itemCount: 4),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: ShiftIQColors.severityCrimson,
              ),
              const SizedBox(height: 12),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ShiftIQEmptyStateIcon(),
              const SizedBox(height: 14),
              Text(
                _products.isEmpty
                    ? 'No hay repuestos registrados en esta sede.'
                    : 'No se encontraron repuestos con ese filtro.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = filtered[index];
        final alreadyAttached =
            widget.attachedProductIds.contains(product.id);
        final outOfStock = product.currentStock <= 0;
        final selectable = _isSelectable(product);
        final isSelected = _selectedProduct?.id == product.id;

        return InkWell(
          onTap: selectable ? () => _selectProduct(product) : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? ShiftIQColors.primaryBlue.withAlpha(14)
                  : selectable
                      ? Colors.white
                      : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ShiftIQColors.primaryBlue
                    : ShiftIQColors.borderSlate,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                SparePartThumbnail(
                  imageUrl: product.imageUrl,
                  size: 46,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selectable
                              ? ShiftIQColors.graphiteText
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.sku} · ${product.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStockBadge(
                        product: product,
                        alreadyAttached: alreadyAttached,
                        outOfStock: outOfStock,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'S/ ${product.salePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: selectable
                            ? ShiftIQColors.primaryBlue
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: isSelected
                          ? ShiftIQColors.primaryBlue
                          : const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockBadge({
    required Product product,
    required bool alreadyAttached,
    required bool outOfStock,
  }) {
    late final Color bg;
    late final Color fg;
    late final String label;

    if (alreadyAttached) {
      bg = const Color(0xFFE2E8F0);
      fg = const Color(0xFF475569);
      label = 'Ya en tarea';
    } else if (outOfStock) {
      bg = ShiftIQColors.severityCrimson.withAlpha(24);
      fg = ShiftIQColors.severityCrimson;
      label = 'Sin stock';
    } else if (product.lowStockAlert) {
      bg = ShiftIQColors.severityAmber.withAlpha(28);
      fg = const Color(0xFFB45309);
      label = 'Stock bajo: ${product.currentStock}';
    } else {
      bg = ShiftIQColors.preventiveGreen.withAlpha(24);
      fg = ShiftIQColors.preventiveGreen;
      label = 'Stock: ${product.currentStock}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildDispatchBar(AppLocalizations loc) {
    final selected = _selectedProduct!;
    final total = selected.salePrice * _quantity;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ShiftIQColors.borderSlate)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_submitError != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ShiftIQColors.severityCrimson.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _submitError!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ShiftIQColors.severityCrimson,
                ),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    Text(
                      'Unitario: S/ ${selected.salePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ShiftIQColors.warmNeutral,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ShiftIQColors.borderSlate),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _quantity > 1 && !_isSubmitting
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: const Icon(Icons.remove_rounded, size: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed:
                          _quantity < selected.currentStock && !_isSubmitting
                              ? () => setState(() => _quantity++)
                              : null,
                      icon: const Icon(Icons.add_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleDispatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: ShiftIQColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _isSubmitting
                  ? 'Despachando...'
                  : '${loc.translate('dispatch')} · S/ ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/inventory_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/inventory_domain.dart';

/// ViewModel managing state, search, category filtering, and product lifecycle for workshop inventory.
class InventoryViewModel extends ChangeNotifier {
  final ManageProducts manageProducts;
  final ManageBatches manageBatches;

  InventoryViewModel({
    required this.manageProducts,
    required this.manageBatches,
  });

  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];
  String _selectedCategory = 'TODOS';
  StockStatus? _selectedStatusFilter;
  String _searchQuery = '';
  Product? _selectedProduct;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get products => _products;
  String get selectedCategory => _selectedCategory;
  StockStatus? get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;
  Product? get selectedProduct => _selectedProduct;

  int get totalProductsCount => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  double get totalValuation =>
      _products.fold(0.0, (acc, p) => acc + p.totalInventoryValue);
  String get formattedTotalValuation => 'S/ ${totalValuation.toStringAsFixed(2)}';

  Future<void> loadProducts(String branchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await manageProducts.getProducts(
        branchId: branchId,
        category: _selectedCategory == 'TODOS' ? null : _selectedCategory,
        query: _searchQuery,
        status: _selectedStatusFilter,
      );
    } catch (e) {
      _errorMessage = 'Error al cargar inventario: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String category, String branchId) async {
    _selectedCategory = category;
    await loadProducts(branchId);
  }

  Future<void> filterByStatus(StockStatus? status, String branchId) async {
    _selectedStatusFilter = status;
    await loadProducts(branchId);
  }

  Future<void> search(String query, String branchId) async {
    _searchQuery = query;
    await loadProducts(branchId);
  }

  Future<void> loadProductDetail(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await manageProducts.getProductById(productId);
    } catch (e) {
      _errorMessage = 'Error al cargar detalle del repuesto: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required String branchId,
    required String sku,
    required String name,
    required String category,
    required double salePrice,
    double? unitPrice,
    double costPrice = 0.0,
    int initialStock = 0,
    int minimumStock = 5,
    String unitOfMeasure = 'UND',
    String description = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await manageProducts.createProduct(
        branchId: branchId,
        sku: sku,
        name: name,
        category: category,
        salePrice: salePrice > 0 ? salePrice : (unitPrice ?? 0.0),
        costPrice: costPrice,
        initialStock: initialStock,
        minimumStock: minimumStock,
        unitOfMeasure: unitOfMeasure,
        description: description,
      );
      await loadProducts(branchId);
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerBatch({
    required String branchId,
    required String productId,
    required int quantity,
    double acquisitionCost = 0.0,
    String? batchNumber,
    String? supplierName,
    DateTime? expirationDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await manageBatches.registerBatch(
        branchId: branchId,
        productId: productId,
        quantity: quantity,
        acquisitionCost: acquisitionCost,
        batchNumber: batchNumber,
        supplierName: supplierName,
        expirationDate: expirationDate,
      );
      if (_selectedProduct != null && _selectedProduct!.id == productId) {
        await loadProductDetail(productId);
      }
      await loadProducts(branchId);
      return true;
    } catch (e) {
      _errorMessage = 'Error al registrar lote: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct({
    required String productId,
    required String branchId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await manageProducts.deleteProduct(productId);
      await loadProducts(branchId);
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

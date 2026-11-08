import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/commandservices/create_product_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/commandservices/register_batch_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_product_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_products_by_branch_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';

class InventoryViewModel extends ChangeNotifier {
  final GetProductsByBranchQueryService getProductsQuery;
  final GetProductDetailQueryService getProductDetailQuery;
  final CreateProductCommandService createProductCommand;
  final RegisterBatchCommandService registerBatchCommand;

  InventoryViewModel({
    required this.getProductsQuery,
    required this.getProductDetailQuery,
    required this.createProductCommand,
    required this.registerBatchCommand,
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
      _products = await getProductsQuery.execute(
        branchId: branchId,
        category: _selectedCategory == 'TODOS' ? null : _selectedCategory,
        searchQuery: _searchQuery,
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
      _selectedProduct = await getProductDetailQuery.execute(productId);
    } catch (e) {
      _errorMessage = 'Error al cargar detalle del repuesto: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct(
    CreateProductCommand command,
    String branchId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await createProductCommand.execute(command);
      await loadProducts(branchId);
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear producto: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerBatch(
    RegisterBatchCommand command,
    String branchId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await registerBatchCommand.execute(command);
      if (_selectedProduct != null && _selectedProduct!.id == command.productId) {
        await loadProductDetail(command.productId);
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
}

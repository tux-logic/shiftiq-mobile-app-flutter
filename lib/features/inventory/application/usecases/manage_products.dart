import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/inventory_domain.dart';

/// Application use case coordinating product catalog operations for workshop spare parts.
class ManageProducts {
  final InventoryRepository repository;

  const ManageProducts({required this.repository});

  /// Registers a new product in the branch catalog with business validations.
  Future<Product> createProduct({
    required String branchId,
    required String category,
    required String name,
    required String sku,
    String description = '',
    required double salePrice,
    required int minimumStock,
    double? unitPrice,
    double? costPrice,
    int? initialStock,
    String unitOfMeasure = 'UND',
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId cannot be empty');
    }
    if (category.trim().isEmpty) {
      throw ArgumentError('category cannot be empty');
    }
    if (name.trim().isEmpty || name.trim().length < 2) {
      throw ArgumentError('name must be at least 2 characters');
    }
    if (sku.trim().isEmpty) {
      throw ArgumentError('sku cannot be empty');
    }
    final effectivePrice = salePrice > 0 ? salePrice : (unitPrice ?? 0.0);
    if (effectivePrice <= 0) {
      throw ArgumentError('salePrice must be greater than zero');
    }
    if (minimumStock < 0) {
      throw ArgumentError('minimumStock cannot be negative');
    }

    return repository.createProduct(
      branchId: branchId.trim(),
      category: category.trim(),
      name: name.trim(),
      sku: sku.trim().toUpperCase(),
      description: description.trim(),
      salePrice: effectivePrice,
      minimumStock: minimumStock,
      unitPrice: effectivePrice,
      costPrice: costPrice ?? 0.0,
      initialStock: initialStock ?? 0,
      unitOfMeasure: unitOfMeasure,
    );
  }

  /// Queries products in a branch with optional category, name, or low stock filters.
  Future<List<Product>> getProducts({
    required String branchId,
    String? name,
    String? category,
    bool? lowStockOnly,
    String? query,
    StockStatus? status,
  }) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId cannot be empty');
    }
    return repository.getProducts(
      branchId: branchId.trim(),
      name: name?.trim(),
      category: category?.trim(),
      lowStockOnly: lowStockOnly,
      query: query?.trim(),
      status: status,
    );
  }

  /// Queries dropdown catalog for branch.
  Future<List<Product>> getBranchCatalog(String branchId) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId cannot be empty');
    }
    return repository.getBranchCatalog(branchId.trim());
  }

  /// Retrieves complete product details and associated stock batches.
  Future<Product> getProductById(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('productId cannot be empty');
    }
    return repository.getProductById(id.trim());
  }

  /// Updates product catalog metadata.
  Future<Product> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String sku,
    String description = '',
    required double salePrice,
    required int minimumStock,
  }) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('productId cannot be empty');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('name cannot be empty');
    }
    if (category.trim().isEmpty) {
      throw ArgumentError('category cannot be empty');
    }
    if (sku.trim().isEmpty) {
      throw ArgumentError('sku cannot be empty');
    }
    if (salePrice <= 0) {
      throw ArgumentError('salePrice must be greater than zero');
    }
    if (minimumStock < 0) {
      throw ArgumentError('minimumStock cannot be negative');
    }

    return repository.updateProduct(
      productId: productId.trim(),
      name: name.trim(),
      category: category.trim(),
      sku: sku.trim().toUpperCase(),
      description: description.trim(),
      salePrice: salePrice,
      minimumStock: minimumStock,
    );
  }

  /// Deletes a product if no active work orders reference it.
  Future<void> deleteProduct(String productId) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('productId cannot be empty');
    }
    return repository.deleteProduct(productId.trim());
  }

  /// Queries all low stock alert items for a branch.
  Future<List<Product>> getLowStockAlerts(String branchId) async {
    if (branchId.trim().isEmpty) {
      throw ArgumentError('branchId cannot be empty');
    }
    return repository.getLowStockAlerts(branchId.trim());
  }
}

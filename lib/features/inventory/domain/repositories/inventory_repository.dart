import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/stock_status.dart';

/// Domain contract specifying inventory operations for workshop spare parts and stock batches.
abstract class InventoryRepository {
  /// Fetches products for a branch with optional filters.
  Future<List<Product>> getProducts({
    required String branchId,
    String? category,
    String? query,
    StockStatus? status,
    String? name,
    bool? lowStockOnly,
  });

  /// Fetches simplified product catalog for dropdowns and pickers.
  Future<List<Product>> getBranchCatalog(String branchId);

  /// Fetches complete product details including historical batches.
  Future<Product> getProductById(String id);

  /// Creates a new product/spare part in the branch catalog.
  Future<Product> createProduct({
    required String branchId,
    required String sku,
    required String name,
    required String category,
    double? salePrice,
    double? unitPrice,
    double costPrice = 0.0,
    int initialStock = 0,
    int minimumStock = 5,
    String unitOfMeasure = 'UND',
    String description = '',
  });

  /// Updates product details and stock alert thresholds.
  Future<Product> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String sku,
    String description = '',
    required double salePrice,
    required int minimumStock,
  });

  /// Deletes a product and its batches if no active work orders reference it.
  Future<void> deleteProduct(String productId);

  /// Registers an inventory batch or performs a manual stock adjustment.
  Future<ProductBatch> registerBatch({
    required String productId,
    required int quantity,
    String? branchId,
    String? batchNumber,
    String? supplierName,
    double? costPrice,
    double? acquisitionCost,
    DateTime? expirationDate,
  });

  /// Adjusts stock for a product (positive for intake, negative for adjustment) and returns new total.
  Future<int> adjustStock({
    required String productId,
    required int quantity,
    double acquisitionCost = 0.0,
  });

  /// Queries all low stock alert items for a branch.
  Future<List<Product>> getLowStockAlerts(String branchId);
}

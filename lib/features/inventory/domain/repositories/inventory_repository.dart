import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/entities/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';

abstract class InventoryRepository {
  Future<List<Product>> getProducts({
    required String branchId,
    String? category,
    String? query,
    StockStatus? status,
  });

  Future<Product> getProductById(String id);

  Future<Product> createProduct({
    required String branchId,
    required String sku,
    required String name,
    required String category,
    required double unitPrice,
    required double costPrice,
    required int initialStock,
    int minimumStock = 5,
    String unitOfMeasure = 'UND',
    String description = '',
  });

  Future<ProductBatch> registerBatch({
    required String branchId,
    required String productId,
    required String batchNumber,
    required String supplierName,
    required int quantity,
    required double costPrice,
    DateTime? expirationDate,
  });

  Future<List<Product>> getLowStockAlerts(String branchId);
}

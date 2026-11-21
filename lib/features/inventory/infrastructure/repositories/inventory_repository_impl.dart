import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/inventory_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/dtos/inventory_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/inventory_api.dart';

/// Implementation of [InventoryRepository] coordinating remote HTTP calls via [InventoryApi]
/// and mapping to pure immutable domain aggregates.
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryApi inventoryApi;

  InventoryRepositoryImpl({required this.inventoryApi});

  @override
  Future<List<Product>> getProducts({
    required String branchId,
    String? category,
    String? query,
    String? name,
    StockStatus? status,
    bool? lowStockOnly,
  }) async {
    final rawList = await inventoryApi.getProductsRaw(
      branchId: branchId,
      category: category != null && category != 'TODOS' ? category : null,
      name: query ?? name,
      lowStockOnly: lowStockOnly,
    );

    var list = rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => ProductDto.fromJson(item).toDomain())
        .toList();

    if (status != null) {
      list = list.where((p) => p.status == status).toList();
    }
    return list;
  }

  @override
  Future<List<Product>> getBranchCatalog(String branchId) async {
    final rawList = await inventoryApi.getBranchCatalogRaw(branchId);
    return rawList
        .whereType<Map<String, dynamic>>()
        .map((item) => ProductDto.fromJson(item).toDomain())
        .toList();
  }

  @override
  Future<Product> getProductById(String id) async {
    final raw = await inventoryApi.getProductByIdRaw(id);
    return ProductDto.fromJson(raw).toDomain();
  }

  @override
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
  }) async {
    final effectivePrice = salePrice ?? unitPrice ?? 0.0;
    final raw = await inventoryApi.createProductRaw(
      branchId: branchId,
      category: category,
      name: name,
      sku: sku,
      description: description,
      salePrice: effectivePrice,
      minimumStock: minimumStock,
    );
    return ProductDto.fromJson(raw).toDomain();
  }

  @override
  Future<Product> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String sku,
    String description = '',
    required double salePrice,
    required int minimumStock,
  }) async {
    final raw = await inventoryApi.updateProductRaw(
      productId: productId,
      name: name,
      category: category,
      sku: sku,
      description: description,
      salePrice: salePrice,
      minimumStock: minimumStock,
    );
    return ProductDto.fromJson(raw).toDomain();
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await inventoryApi.deleteProduct(productId);
  }

  @override
  Future<ProductBatch> registerBatch({
    required String productId,
    required int quantity,
    String? branchId,
    String? batchNumber,
    String? supplierName,
    double? costPrice,
    double? acquisitionCost,
    DateTime? expirationDate,
  }) async {
    final effectiveCost = acquisitionCost ?? costPrice ?? 0.0;
    final raw = await inventoryApi.registerBatchRaw(
      productId: productId,
      quantity: quantity,
      acquisitionCost: effectiveCost,
    );
    return ProductBatchDto.fromJson(raw).toDomain();
  }

  @override
  Future<int> adjustStock({
    required String productId,
    required int quantity,
    double acquisitionCost = 0.0,
  }) async {
    final raw = await inventoryApi.registerBatchRaw(
      productId: productId,
      quantity: quantity,
      acquisitionCost: acquisitionCost,
    );
    final res = StockAdjustmentResponseDto.fromJson(raw);
    return res.currentStock;
  }

  @override
  Future<List<Product>> getLowStockAlerts(String branchId) async {
    return getProducts(branchId: branchId, lowStockOnly: true);
  }
}

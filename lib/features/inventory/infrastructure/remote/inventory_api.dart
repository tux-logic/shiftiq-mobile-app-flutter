import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/dtos/product_batch_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/dtos/product_dto.dart';

/// Remote HTTP client consuming backend Inventory endpoints (`/api/v1/inventory/products`).
class InventoryApi {
  final ApiClient apiClient;

  const InventoryApi({required this.apiClient});

  /// POST /api/v1/inventory/products
  Future<Map<String, dynamic>> createProductRaw({
    required String branchId,
    required String category,
    required String name,
    required String sku,
    String description = '',
    required double salePrice,
    required int minimumStock,
  }) async {
    final response = await apiClient.post(
      ApiConstants.inventoryProducts,
      body: {
        'branchId': branchId,
        'category': category,
        'name': name,
        'sku': sku,
        if (description.isNotEmpty) 'description': description,
        'salePrice': salePrice,
        'minimumStock': minimumStock,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// GET /api/v1/inventory/products?branchId={branchId}
  Future<List<dynamic>> getProductsRaw({
    required String branchId,
    String? name,
    String? category,
    bool? lowStockOnly,
  }) async {
    var url = '${ApiConstants.inventoryProducts}?branchId=$branchId';
    if (name != null && name.isNotEmpty) {
      url += '&name=${Uri.encodeComponent(name)}';
    }
    if (category != null && category.isNotEmpty && category != 'TODOS') {
      url += '&category=${Uri.encodeComponent(category)}';
    }
    if (lowStockOnly == true) {
      url += '&lowStockOnly=true';
    }

    final response = await apiClient.get(url);
    if (response is List) {
      return response;
    }
    return [];
  }

  /// GET /api/v1/inventory/products/branch/{branchId}
  Future<List<dynamic>> getBranchCatalogRaw(String branchId) async {
    final response = await apiClient.get(ApiConstants.inventoryBranchCatalog(branchId));
    if (response is List) {
      return response;
    }
    return [];
  }

  /// GET /api/v1/inventory/products/{productId}
  Future<Map<String, dynamic>> getProductByIdRaw(String productId) async {
    final response = await apiClient.get(ApiConstants.inventoryProductById(productId));
    return response as Map<String, dynamic>;
  }

  /// PUT /api/v1/inventory/products/{productId}
  Future<Map<String, dynamic>> updateProductRaw({
    required String productId,
    required String name,
    required String category,
    required String sku,
    String description = '',
    required double salePrice,
    required int minimumStock,
  }) async {
    final response = await apiClient.put(
      ApiConstants.inventoryProductById(productId),
      body: {
        'name': name,
        'category': category,
        'sku': sku,
        if (description.isNotEmpty) 'description': description,
        'salePrice': salePrice,
        'minimumStock': minimumStock,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// POST /api/v1/inventory/products/{productId}/batches
  Future<Map<String, dynamic>> registerBatchRaw({
    required String productId,
    required int quantity,
    required double acquisitionCost,
  }) async {
    final response = await apiClient.post(
      ApiConstants.inventoryProductBatches(productId),
      body: {
        'quantity': quantity,
        'acquisitionCost': acquisitionCost,
      },
    );
    return response as Map<String, dynamic>;
  }

  /// DELETE /api/v1/inventory/products/{productId}
  Future<void> deleteProduct(String productId) async {
    await apiClient.delete(ApiConstants.inventoryProductById(productId));
  }

  // Backward compatibility methods for existing callers
  Future<List<ProductDto>> getProducts({
    required String branchId,
    String? category,
    String? query,
    bool? lowStockOnly,
  }) async {
    final rawList = await getProductsRaw(
      branchId: branchId,
      name: query,
      category: category,
      lowStockOnly: lowStockOnly,
    );
    return rawList
        .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProductDto> getProductById(String id) async {
    final raw = await getProductByIdRaw(id);
    return ProductDto.fromJson(raw);
  }

  Future<ProductDto> createProduct({
    required String branchId,
    required String sku,
    required String name,
    required String category,
    double? unitPrice,
    double? salePrice,
    double costPrice = 0.0,
    int initialStock = 0,
    int minimumStock = 5,
    String unitOfMeasure = 'UND',
    String description = '',
  }) async {
    final effectivePrice = salePrice ?? unitPrice ?? 0.0;
    final raw = await createProductRaw(
      branchId: branchId,
      category: category,
      name: name,
      sku: sku,
      description: description,
      salePrice: effectivePrice,
      minimumStock: minimumStock,
    );
    return ProductDto.fromJson(raw);
  }

  /// Registers a product inventory batch.
  /// Note: The backend contract for POST /api/v1/inventory/products/{id}/batches
  /// expects quantity and acquisitionCost; metadata fields (batchNumber, supplierName, expirationDate)
  /// are preserved for offline traceability.
  Future<ProductBatchDto> registerBatch({
    required String branchId,
    required String productId,
    required String batchNumber,
    required String supplierName,
    required int quantity,
    double? costPrice,
    double? acquisitionCost,
    DateTime? expirationDate,
  }) async {
    final effectiveCost = acquisitionCost ?? costPrice ?? 0.0;
    final raw = await registerBatchRaw(
      productId: productId,
      quantity: quantity,
      acquisitionCost: effectiveCost,
    );
    return ProductBatchDto.fromJson(raw);
  }
}

import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/dtos/product_batch_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/dtos/product_dto.dart';

class InventoryApi {
  final ApiClient apiClient;

  InventoryApi({required this.apiClient});

  Future<List<ProductDto>> getProducts({
    required String branchId,
    String? category,
    String? query,
  }) async {
    var url = '/api/v1/products?branchId=$branchId';
    if (category != null && category.isNotEmpty && category != 'TODOS') {
      url += '&category=$category';
    }
    if (query != null && query.isNotEmpty) {
      url += '&query=$query';
    }

    final response = await apiClient.get(url);
    if (response is List) {
      return response
          .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<ProductDto> getProductById(String id) async {
    final response = await apiClient.get('/api/v1/products/$id');
    return ProductDto.fromJson(response as Map<String, dynamic>);
  }

  Future<ProductDto> createProduct({
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
  }) async {
    final response = await apiClient.post(
      '/api/v1/products',
      body: {
        'branchId': branchId,
        'sku': sku,
        'name': name,
        'category': category,
        'unitPrice': unitPrice,
        'costPrice': costPrice,
        'currentStock': initialStock,
        'minimumStock': minimumStock,
        'unitOfMeasure': unitOfMeasure,
        'description': description,
      },
    );
    return ProductDto.fromJson(response as Map<String, dynamic>);
  }

  Future<ProductBatchDto> registerBatch({
    required String branchId,
    required String productId,
    required String batchNumber,
    required String supplierName,
    required int quantity,
    required double costPrice,
    DateTime? expirationDate,
  }) async {
    final response = await apiClient.post(
      '/api/v1/inventory/batches',
      body: {
        'branchId': branchId,
        'productId': productId,
        'batchNumber': batchNumber,
        'supplierName': supplierName,
        'quantity': quantity,
        'costPrice': costPrice,
        if (expirationDate != null)
          'expirationDate': expirationDate.toIso8601String(),
      },
    );
    return ProductBatchDto.fromJson(response as Map<String, dynamic>);
  }
}

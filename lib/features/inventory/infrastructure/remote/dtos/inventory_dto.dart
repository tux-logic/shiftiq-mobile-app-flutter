import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/inventory_domain.dart';

/// Data Transfer Object representing an inventory batch from `/api/v1/inventory/products/{id}/batches`.
class ProductBatchDto {
  final String batchId;
  final int initialQuantity;
  final int availableQuantity;
  final double acquisitionCost;
  final DateTime createdAt;
  final String supplierName;
  final DateTime? expirationDate;

  const ProductBatchDto({
    required this.batchId,
    required this.initialQuantity,
    required this.availableQuantity,
    required this.acquisitionCost,
    required this.createdAt,
    this.supplierName = 'Distribuidora Mayorista Lima',
    this.expirationDate,
  });

  // Backward compatibility getters
  String get id => batchId;
  String get batchNumber => batchId;
  int get quantityReceived => initialQuantity;
  int get quantityRemaining => availableQuantity;
  double get costPrice => acquisitionCost;
  DateTime get receptionDate => createdAt;

  factory ProductBatchDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'batchId': final dynamic bId,
        'initialQuantity': final dynamic initQty,
        'availableQuantity': final dynamic availQty,
        'acquisitionCost': final dynamic cost,
        'createdAt': final dynamic created,
      } =>
        ProductBatchDto(
          batchId: bId.toString(),
          initialQuantity: (initQty as num).toInt(),
          availableQuantity: (availQty as num).toInt(),
          acquisitionCost: (cost as num).toDouble(),
          createdAt: DateTime.tryParse(created.toString()) ?? DateTime.now(),
          supplierName: json['supplierName']?.toString() ?? 'Distribuidora Mayorista Lima',
          expirationDate: json['expirationDate'] != null
              ? DateTime.tryParse(json['expirationDate'].toString())
              : null,
        ),
      _ => ProductBatchDto(
          batchId: (json['batchId'] ?? json['batchNumber'] ?? json['id'] ?? '').toString(),
          initialQuantity: ((json['initialQuantity'] ?? json['quantityReceived'] ?? json['quantity'] ?? 0) as num).toInt(),
          availableQuantity: ((json['availableQuantity'] ?? json['quantityRemaining'] ?? json['quantity'] ?? 0) as num).toInt(),
          acquisitionCost: ((json['acquisitionCost'] ?? json['costPrice'] ?? json['cost'] ?? 0.0) as num).toDouble(),
          createdAt: json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : (json['receptionDate'] != null
                  ? DateTime.tryParse(json['receptionDate'].toString()) ?? DateTime.now()
                  : DateTime.now()),
          supplierName: json['supplierName']?.toString() ?? 'Distribuidora Mayorista Lima',
          expirationDate: json['expirationDate'] != null
              ? DateTime.tryParse(json['expirationDate'].toString())
              : null,
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        'batchId': batchId,
        'initialQuantity': initialQuantity,
        'availableQuantity': availableQuantity,
        'acquisitionCost': acquisitionCost,
        'createdAt': createdAt.toIso8601String(),
        'supplierName': supplierName,
        if (expirationDate != null)
          'expirationDate': expirationDate!.toIso8601String(),
      };

  ProductBatch toDomain() {
    return ProductBatch(
      batchId: batchId,
      initialQuantity: initialQuantity,
      availableQuantity: availableQuantity,
      acquisitionCost: acquisitionCost,
      createdAt: createdAt,
      supplierName: supplierName,
      expirationDate: expirationDate,
    );
  }
}

/// Data Transfer Object representing an inventory product from `/api/v1/inventory/products`.
class ProductDto {
  final String id;
  final String branchId;
  final String category;
  final String name;
  final String sku;
  final String description;
  final double salePrice;
  final int minimumStock;
  final int currentStock;
  final bool lowStockAlert;
  final List<ProductBatchDto> batches;
  final String? createdAt;
  final String unitOfMeasure;
  final double costPrice;

  const ProductDto({
    required this.id,
    required this.branchId,
    required this.category,
    required this.name,
    required this.sku,
    this.description = '',
    required this.salePrice,
    required this.minimumStock,
    this.currentStock = 0,
    this.lowStockAlert = false,
    this.batches = const [],
    this.createdAt,
    this.unitOfMeasure = 'UND',
    this.costPrice = 0.0,
  });

  // Backward compatibility getter
  double get unitPrice => salePrice;

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final rawBatches = json['batches'] ?? json['product_batches'];
    List<ProductBatchDto> parsedBatches = [];
    if (rawBatches is List) {
      parsedBatches = rawBatches
          .whereType<Map<String, dynamic>>()
          .map(ProductBatchDto.fromJson)
          .toList();
    }

    return switch (json) {
      {
        'id': final dynamic id,
        'branchId': final dynamic branchId,
        'category': final dynamic category,
        'name': final dynamic name,
        'sku': final dynamic sku,
        'salePrice': final dynamic price,
        'minimumStock': final dynamic minStock,
      } =>
        ProductDto(
          id: id.toString(),
          branchId: branchId.toString(),
          category: category.toString(),
          name: name.toString(),
          sku: sku.toString(),
          description: json['description']?.toString() ?? '',
          salePrice: (price as num).toDouble(),
          minimumStock: (minStock as num).toInt(),
          currentStock: ((json['currentStock'] ?? json['current_stock'] ?? 0) as num).toInt(),
          lowStockAlert: json['lowStockAlert'] == true ||
              (((json['currentStock'] ?? 0) as num).toInt() <= minStock.toInt()),
          batches: parsedBatches,
          createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
          unitOfMeasure: json['unitOfMeasure']?.toString() ?? json['unit_of_measure']?.toString() ?? 'UND',
          costPrice: parsedBatches.isNotEmpty
              ? parsedBatches.first.acquisitionCost
              : ((json['costPrice'] ?? json['cost_price'] ?? 0) as num).toDouble(),
        ),
      _ => ProductDto(
          id: (json['id'] ?? '').toString(),
          branchId: (json['branchId'] ?? json['branch_id'] ?? '').toString(),
          category: (json['category'] ?? 'LUBRICANTES').toString(),
          name: (json['name'] ?? 'Repuesto').toString(),
          sku: (json['sku'] ?? 'SKU-GEN').toString(),
          description: json['description']?.toString() ?? '',
          salePrice: ((json['salePrice'] ?? json['unitPrice'] ?? json['unit_price'] ?? 0) as num).toDouble(),
          minimumStock: ((json['minimumStock'] ?? json['minimum_stock'] ?? 5) as num).toInt(),
          currentStock: ((json['currentStock'] ?? json['current_stock'] ?? 0) as num).toInt(),
          lowStockAlert: json['lowStockAlert'] as bool? ?? false,
          batches: parsedBatches,
          createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
          unitOfMeasure: json['unitOfMeasure']?.toString() ?? json['unit_of_measure']?.toString() ?? 'UND',
          costPrice: ((json['costPrice'] ?? json['cost_price'] ?? 0) as num).toDouble(),
        ),
    };
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'branchId': branchId,
        'category': category,
        'name': name,
        'sku': sku,
        'description': description,
        'salePrice': salePrice,
        'minimumStock': minimumStock,
        'currentStock': currentStock,
        'lowStockAlert': lowStockAlert,
        'batches': batches.map((b) => b.toJson()).toList(),
        if (createdAt != null) 'createdAt': createdAt,
        'unitOfMeasure': unitOfMeasure,
        'costPrice': costPrice,
      };

  Product toDomain() {
    return Product(
      id: id,
      branchId: branchId,
      sku: sku,
      name: name,
      description: description,
      category: category,
      unitOfMeasure: unitOfMeasure,
      salePrice: salePrice,
      costPrice: costPrice > 0
          ? costPrice
          : (batches.isNotEmpty ? batches.first.acquisitionCost : 0.0),
      currentStock: currentStock,
      minimumStock: minimumStock,
      lowStockAlert: lowStockAlert,
      batches: batches.map((b) => b.toDomain()).toList(),
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}

/// Data Transfer Object for batch adjustment responses (`/api/v1/inventory/products/{productId}/batches`).
class StockAdjustmentResponseDto {
  final String message;
  final int currentStock;

  const StockAdjustmentResponseDto({
    required this.message,
    required this.currentStock,
  });

  factory StockAdjustmentResponseDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'currentStock': final dynamic stock,
      } =>
        StockAdjustmentResponseDto(
          message: json['message']?.toString() ?? 'Stock batch updated successfully',
          currentStock: (stock as num).toInt(),
        ),
      _ => StockAdjustmentResponseDto(
          message: json['message']?.toString() ?? '',
          currentStock: ((json['currentStock'] ?? json['current_stock'] ?? 0) as num).toInt(),
        ),
    };
  }
}

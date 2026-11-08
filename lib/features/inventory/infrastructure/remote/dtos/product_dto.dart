import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/dtos/product_batch_dto.dart';

class ProductDto {
  final String id;
  final String branchId;
  final String sku;
  final String name;
  final String description;
  final String category;
  final String unitOfMeasure;
  final double unitPrice;
  final double costPrice;
  final int currentStock;
  final int minimumStock;
  final List<ProductBatchDto> batches;
  final String? createdAt;

  const ProductDto({
    required this.id,
    required this.branchId,
    required this.sku,
    required this.name,
    required this.description,
    required this.category,
    required this.unitOfMeasure,
    required this.unitPrice,
    required this.costPrice,
    required this.currentStock,
    required this.minimumStock,
    this.batches = const [],
    this.createdAt,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    var rawBatches = json['batches'] ?? json['product_batches'];
    List<ProductBatchDto> batchesList = [];
    if (rawBatches is List) {
      batchesList = rawBatches
          .map((b) => ProductBatchDto.fromJson(b as Map<String, dynamic>))
          .toList();
    }

    return ProductDto(
      id: json['id']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? json['branch_id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? 'SKU-GEN',
      name: json['name']?.toString() ?? 'Repuesto',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'LUBRICANTES',
      unitOfMeasure: json['unitOfMeasure']?.toString() ?? json['unit_of_measure']?.toString() ?? 'UND',
      unitPrice: ((json['unitPrice'] ?? json['unit_price'] ?? 0) as num).toDouble(),
      costPrice: ((json['costPrice'] ?? json['cost_price'] ?? 0) as num).toDouble(),
      currentStock: (json['currentStock'] ?? json['current_stock'] ?? 0) as int,
      minimumStock: (json['minimumStock'] ?? json['minimum_stock'] ?? 5) as int,
      batches: batchesList,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    );
  }

  Product toDomain() {
    return Product(
      id: id,
      branchId: branchId,
      sku: sku,
      name: name,
      description: description,
      category: category,
      unitOfMeasure: unitOfMeasure,
      unitPrice: unitPrice,
      costPrice: costPrice,
      currentStock: currentStock,
      minimumStock: minimumStock,
      batches: batches.map((b) => b.toDomain()).toList(),
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}

import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/entities/product_batch.dart';

class ProductBatchDto {
  final String id;
  final String batchNumber;
  final String productId;
  final String supplierName;
  final int quantityReceived;
  final int quantityRemaining;
  final double costPrice;
  final String receptionDate;
  final String? expirationDate;

  const ProductBatchDto({
    required this.id,
    required this.batchNumber,
    required this.productId,
    required this.supplierName,
    required this.quantityReceived,
    required this.quantityRemaining,
    required this.costPrice,
    required this.receptionDate,
    this.expirationDate,
  });

  factory ProductBatchDto.fromJson(Map<String, dynamic> json) {
    return ProductBatchDto(
      id: json['id']?.toString() ?? '',
      batchNumber: json['batchNumber']?.toString() ?? json['batch_number']?.toString() ?? 'LOTE-S/N',
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? json['supplier_name']?.toString() ?? 'Distribuidora Lima',
      quantityReceived: (json['quantityReceived'] ?? json['quantity_received'] ?? 0) as int,
      quantityRemaining: (json['quantityRemaining'] ?? json['quantity_remaining'] ?? 0) as int,
      costPrice: ((json['costPrice'] ?? json['cost_price'] ?? 0) as num).toDouble(),
      receptionDate: json['receptionDate']?.toString() ?? json['reception_date']?.toString() ?? DateTime.now().toIso8601String(),
      expirationDate: json['expirationDate']?.toString() ?? json['expiration_date']?.toString(),
    );
  }

  ProductBatch toDomain() {
    return ProductBatch(
      id: id,
      batchNumber: batchNumber,
      productId: productId,
      supplierName: supplierName,
      quantityReceived: quantityReceived,
      quantityRemaining: quantityRemaining,
      costPrice: costPrice,
      receptionDate: DateTime.tryParse(receptionDate) ?? DateTime.now(),
      expirationDate: expirationDate != null ? DateTime.tryParse(expirationDate!) : null,
    );
  }
}


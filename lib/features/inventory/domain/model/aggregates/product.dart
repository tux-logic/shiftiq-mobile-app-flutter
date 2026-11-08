import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/entities/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';

class Product {
  final String id;
  final String branchId;
  final String sku;
  final String name;
  final String description;
  final String category; // LUBRICANTES, FILTROS, FRENOS, SUSPENSION, MOTOR, ILUMINACION
  final String unitOfMeasure; // UND, LITRO, JUEGO, GALON
  final double unitPrice; // Workshop selling price to vehicle owner (S/)
  final double costPrice; // Purchase cost price (S/)
  final int currentStock;
  final int minimumStock;
  final List<ProductBatch> batches;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.branchId,
    required this.sku,
    required this.name,
    this.description = '',
    required this.category,
    this.unitOfMeasure = 'UND',
    required this.unitPrice,
    required this.costPrice,
    required this.currentStock,
    this.minimumStock = 5,
    this.batches = const [],
    this.createdAt,
  });

  bool get isLowStock => currentStock <= minimumStock && currentStock > 0;
  bool get isOutOfStock => currentStock <= 0;
  bool get isOptimalStock => currentStock > minimumStock;

  StockStatus get status {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    return StockStatus.normal;
  }

  double get totalInventoryValue => currentStock * costPrice;
  double get profitMargin => unitPrice - costPrice;
  double get marginPercentage =>
      costPrice > 0 ? (profitMargin / costPrice) * 100 : 0.0;

  String get formattedUnitPrice => 'S/ ${unitPrice.toStringAsFixed(2)}';
  String get formattedCostPrice => 'S/ ${costPrice.toStringAsFixed(2)}';
  String get formattedTotalValue =>
      'S/ ${totalInventoryValue.toStringAsFixed(2)}';

  Product copyWith({
    String? id,
    String? branchId,
    String? sku,
    String? name,
    String? description,
    String? category,
    String? unitOfMeasure,
    double? unitPrice,
    double? costPrice,
    int? currentStock,
    int? minimumStock,
    List<ProductBatch>? batches,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      batches: batches ?? this.batches,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


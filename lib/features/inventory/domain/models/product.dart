import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/stock_status.dart';

/// Aggregate root representing a spare part or inventory item in a workshop branch.
class Product {
  final String id;
  final String branchId;
  final String sku;
  final String name;
  final String description;
  final String category;
  final String unitOfMeasure;
  final double salePrice;
  final double costPrice;
  final int currentStock;
  final int minimumStock;
  final bool lowStockAlert;
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
    double? salePrice,
    double? unitPrice,
    this.costPrice = 0.0,
    this.currentStock = 0,
    this.minimumStock = 5,
    bool? lowStockAlert,
    this.batches = const [],
    this.createdAt,
  })  : salePrice = salePrice ?? unitPrice ?? 0.0,
        lowStockAlert = lowStockAlert ?? (currentStock <= minimumStock);

  // Backward compatibility getters
  double get unitPrice => salePrice;

  bool get isLowStock => currentStock > 0 && (lowStockAlert || currentStock <= minimumStock);
  bool get isOutOfStock => currentStock <= 0;
  bool get isOptimalStock => currentStock > minimumStock;

  StockStatus get status {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    return StockStatus.normal;
  }

  double get totalInventoryValue => currentStock * (batches.isNotEmpty ? batches.first.acquisitionCost : costPrice);
  double get profitMargin => salePrice - costPrice;
  double get marginPercentage =>
      costPrice > 0 ? (profitMargin / costPrice) * 100 : 0.0;

  String get formattedSalePrice => 'S/ ${salePrice.toStringAsFixed(2)}';
  String get formattedUnitPrice => formattedSalePrice;
  String get formattedCostPrice => 'S/ ${costPrice.toStringAsFixed(2)}';
  String get formattedTotalValue =>
      'S/ ${(currentStock * salePrice).toStringAsFixed(2)}';

  Product copyWith({
    String? id,
    String? branchId,
    String? sku,
    String? name,
    String? description,
    String? category,
    String? unitOfMeasure,
    double? salePrice,
    double? unitPrice,
    double? costPrice,
    int? currentStock,
    int? minimumStock,
    bool? lowStockAlert,
    List<ProductBatch>? batches,
    DateTime? createdAt,
  }) {
    final effectiveStock = currentStock ?? this.currentStock;
    final effectiveMin = minimumStock ?? this.minimumStock;
    final bool computedLowStock = lowStockAlert ?? (effectiveStock <= effectiveMin);

    return Product(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      salePrice: salePrice ?? unitPrice ?? this.salePrice,
      costPrice: costPrice ?? this.costPrice,
      currentStock: effectiveStock,
      minimumStock: effectiveMin,
      lowStockAlert: computedLowStock,
      batches: batches ?? this.batches,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          branchId == other.branchId &&
          category == other.category &&
          name == other.name &&
          sku == other.sku &&
          description == other.description &&
          salePrice == other.salePrice &&
          minimumStock == other.minimumStock &&
          currentStock == other.currentStock &&
          lowStockAlert == other.lowStockAlert &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      branchId.hashCode ^
      category.hashCode ^
      name.hashCode ^
      sku.hashCode ^
      description.hashCode ^
      salePrice.hashCode ^
      minimumStock.hashCode ^
      currentStock.hashCode ^
      lowStockAlert.hashCode ^
      createdAt.hashCode;
}

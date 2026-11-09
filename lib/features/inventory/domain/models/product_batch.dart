/// Represents an inventory batch tracking acquisition cost and FIFO stock availability.
class ProductBatch {
  final String batchId;
  final String productId;
  final int initialQuantity;
  final int availableQuantity;
  final double acquisitionCost;
  final DateTime? createdAt;
  final String supplierName;
  final DateTime? expirationDate;

  const ProductBatch({
    String? batchId,
    String? batchNumber,
    String? id,
    this.productId = '',
    int? initialQuantity,
    int? quantityReceived,
    int? availableQuantity,
    int? quantityRemaining,
    double? acquisitionCost,
    double? costPrice,
    DateTime? createdAt,
    DateTime? receptionDate,
    this.supplierName = 'Distribuidora Mayorista Lima',
    this.expirationDate,
  })  : batchId = batchId ?? batchNumber ?? id ?? '',
        initialQuantity = initialQuantity ?? quantityReceived ?? 0,
        availableQuantity = availableQuantity ?? quantityRemaining ?? 0,
        acquisitionCost = acquisitionCost ?? costPrice ?? 0.0,
        createdAt = createdAt ?? receptionDate;

  // Backward compatibility getters
  String get id => batchId;
  String get batchNumber => batchId;
  int get quantityReceived => initialQuantity;
  int get quantityRemaining => availableQuantity;
  double get costPrice => acquisitionCost;
  DateTime get receptionDate => createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  bool get isDepleted => availableQuantity <= 0;
  String get formattedCost => 'S/ ${acquisitionCost.toStringAsFixed(2)}';
  String get formattedDate {
    if (createdAt == null) return '-';
    final d = createdAt!.day.toString().padLeft(2, '0');
    final m = createdAt!.month.toString().padLeft(2, '0');
    final y = createdAt!.year;
    return '$d/$m/$y';
  }

  ProductBatch copyWith({
    String? batchId,
    String? productId,
    int? initialQuantity,
    int? availableQuantity,
    double? acquisitionCost,
    DateTime? createdAt,
    String? supplierName,
    DateTime? expirationDate,
  }) {
    return ProductBatch(
      batchId: batchId ?? this.batchId,
      productId: productId ?? this.productId,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      acquisitionCost: acquisitionCost ?? this.acquisitionCost,
      createdAt: createdAt ?? this.createdAt,
      supplierName: supplierName ?? this.supplierName,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductBatch &&
          runtimeType == other.runtimeType &&
          batchId == other.batchId &&
          productId == other.productId &&
          initialQuantity == other.initialQuantity &&
          availableQuantity == other.availableQuantity &&
          acquisitionCost == other.acquisitionCost &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      batchId.hashCode ^
      productId.hashCode ^
      initialQuantity.hashCode ^
      availableQuantity.hashCode ^
      acquisitionCost.hashCode ^
      createdAt.hashCode;
}

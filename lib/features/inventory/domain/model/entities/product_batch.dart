class ProductBatch {
  final String id;
  final String batchNumber;
  final String productId;
  final String supplierName;
  final int quantityReceived;
  final int quantityRemaining;
  final double costPrice;
  final DateTime receptionDate;
  final DateTime? expirationDate;

  const ProductBatch({
    required this.id,
    required this.batchNumber,
    required this.productId,
    this.supplierName = 'Distribuidora Mayorista Lima',
    required this.quantityReceived,
    required this.quantityRemaining,
    required this.costPrice,
    required this.receptionDate,
    this.expirationDate,
  });

  bool get isDepleted => quantityRemaining <= 0;
  String get formattedCost => 'S/ ${costPrice.toStringAsFixed(2)}';
  String get formattedDate {
    final d = receptionDate.day.toString().padLeft(2, '0');
    final m = receptionDate.month.toString().padLeft(2, '0');
    final y = receptionDate.year;
    return '$d/$m/$y';
  }

  ProductBatch copyWith({
    String? id,
    String? batchNumber,
    String? productId,
    String? supplierName,
    int? quantityReceived,
    int? quantityRemaining,
    double? costPrice,
    DateTime? receptionDate,
    DateTime? expirationDate,
  }) {
    return ProductBatch(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      productId: productId ?? this.productId,
      supplierName: supplierName ?? this.supplierName,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      quantityRemaining: quantityRemaining ?? this.quantityRemaining,
      costPrice: costPrice ?? this.costPrice,
      receptionDate: receptionDate ?? this.receptionDate,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }
}


/// Value object representing an inventory spare part product attached to a work order task.
class WorkOrderTaskProduct {
  final String id;
  final String productId;
  final String productName;
  final String branchId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime? createdAt;

  const WorkOrderTaskProduct({
    required this.id,
    required this.productId,
    this.productName = 'Repuesto',
    required this.branchId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.createdAt,
  });

  String get formattedUnitPrice => 'S/ ${unitPrice.toStringAsFixed(2)}';
  String get formattedTotal => 'S/ ${totalAmount.toStringAsFixed(2)}';

  WorkOrderTaskProduct copyWith({
    String? id,
    String? productId,
    String? productName,
    String? branchId,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    DateTime? createdAt,
  }) {
    return WorkOrderTaskProduct(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      branchId: branchId ?? this.branchId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkOrderTaskProduct &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice;

  @override
  int get hashCode => id.hashCode ^ productId.hashCode ^ quantity.hashCode ^ unitPrice.hashCode;
}

/// Backward compatibility alias.
typedef TaskProduct = WorkOrderTaskProduct;

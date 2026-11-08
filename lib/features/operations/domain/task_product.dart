class TaskProduct {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;

  const TaskProduct({
    required this.id,
    required this.productId,
    this.productName = 'Repuesto de Taller',
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  String get formattedUnitPrice => 'S/ ${unitPrice.toStringAsFixed(2)}';
  String get formattedTotal => 'S/ ${totalAmount.toStringAsFixed(2)}';
}


import 'package:shiftiq_mobile_app_flutter/features/operations/domain/task_product.dart';

class WorkOrderTask {
  final String id;
  final String? serviceId;
  final String description;
  final double price;
  final String status;
  final String? assignedMechanicId;
  final String assignedMechanicName;
  final List<TaskProduct> products;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const WorkOrderTask({
    required this.id,
    this.serviceId,
    required this.description,
    required this.price,
    this.status = 'PENDING',
    this.assignedMechanicId,
    this.assignedMechanicName = 'Sin asignar',
    this.products = const [],
    this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';
  bool get isPending => !isCompleted && !isInProgress;

  String get formattedPrice => 'S/ ${price.toStringAsFixed(2)}';

  double get productsTotal =>
      products.fold(0.0, (sum, p) => sum + p.totalAmount);

  double get grandTotal => price + productsTotal;
}


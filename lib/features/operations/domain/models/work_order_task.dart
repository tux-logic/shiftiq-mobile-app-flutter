import 'package:shiftiq_mobile_app_flutter/features/operations/domain/models/task_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/models/work_order_task_product.dart';

/// Entity representing a specific labor repair task assigned to a technician within a work order.
class WorkOrderTask {
  final String id;
  final String serviceId;
  final String branchId;
  final String assignedMechanicId;
  final TaskStatus status;
  final String description;
  final double price;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<WorkOrderTaskProduct> products;
  final List<String> evidenceImages;
  final DateTime? createdAt;

  const WorkOrderTask({
    required this.id,
    required this.serviceId,
    required this.branchId,
    required this.assignedMechanicId,
    this.status = TaskStatus.pending,
    required this.description,
    required this.price,
    this.startedAt,
    this.completedAt,
    this.products = const [],
    this.evidenceImages = const [],
    this.createdAt,
  });

  bool get isCompleted => status == TaskStatus.completed;
  bool get isDoing => status == TaskStatus.doing;
  bool get isPending => status == TaskStatus.pending;

  double get productsTotalAmount =>
      products.fold(0.0, (sum, item) => sum + item.totalAmount);

  double get combinedTaskTotal => price + productsTotalAmount;

  WorkOrderTask copyWith({
    String? id,
    String? serviceId,
    String? branchId,
    String? assignedMechanicId,
    TaskStatus? status,
    String? description,
    double? price,
    DateTime? startedAt,
    DateTime? completedAt,
    List<WorkOrderTaskProduct>? products,
    List<String>? evidenceImages,
    DateTime? createdAt,
  }) {
    return WorkOrderTask(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      branchId: branchId ?? this.branchId,
      assignedMechanicId: assignedMechanicId ?? this.assignedMechanicId,
      status: status ?? this.status,
      description: description ?? this.description,
      price: price ?? this.price,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      products: products ?? this.products,
      evidenceImages: evidenceImages ?? this.evidenceImages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkOrderTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serviceId == other.serviceId &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ serviceId.hashCode ^ status.hashCode;
}

import 'package:shiftiq_mobile_app_flutter/features/operations/domain/models/work_order_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/models/work_order_task.dart';

/// Aggregate root representing an automotive repair Work Order (OT) from check-in to invoicing.
class WorkOrder {
  final String id;
  final String appointmentId;
  final String branchId;
  final String vehicleId;
  final String vehiclePlate;
  final String vehicleModel;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final int internalNumber;
  final String formattedNumber;
  final WorkOrderStatus status;
  final String diagnosticSummary;
  final int mileageIn;
  final double totalAmount;
  final List<WorkOrderTask> tasks;
  final List<String> entryInspectionImages;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WorkOrder({
    required this.id,
    required this.appointmentId,
    required this.branchId,
    required this.vehicleId,
    this.vehiclePlate = 'S/P',
    this.vehicleModel = 'Vehículo General',
    required this.customerId,
    this.customerName = 'Cliente General',
    this.customerPhone = '',
    required this.internalNumber,
    required this.formattedNumber,
    this.status = WorkOrderStatus.pending,
    required this.diagnosticSummary,
    required this.mileageIn,
    required this.totalAmount,
    this.tasks = const [],
    this.entryInspectionImages = const [],
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == WorkOrderStatus.pending;
  bool get isInProgress => status == WorkOrderStatus.inProgress;
  bool get isCompleted =>
      status == WorkOrderStatus.completed || status == WorkOrderStatus.paid;
  bool get isPaid => status == WorkOrderStatus.paid;
  bool get isDeleted =>
      status == WorkOrderStatus.deleted || status == WorkOrderStatus.cancelled;

  int get totalTasksCount => tasks.length;
  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;

  /// Invariant: All mechanical tasks must be finished to transition the order to COMPLETED.
  bool get allTasksCompleted =>
      tasks.isNotEmpty && completedTasksCount == totalTasksCount;

  bool get canBeCompleted =>
      allTasksCompleted && status != WorkOrderStatus.completed;

  String get formattedAmount => 'S/ ${totalAmount.toStringAsFixed(2)}';
  String get formattedMileage => '$mileageIn km';

  WorkOrder copyWith({
    String? id,
    String? appointmentId,
    String? branchId,
    String? vehicleId,
    String? vehiclePlate,
    String? vehicleModel,
    String? customerId,
    String? customerName,
    String? customerPhone,
    int? internalNumber,
    String? formattedNumber,
    WorkOrderStatus? status,
    String? diagnosticSummary,
    int? mileageIn,
    double? totalAmount,
    List<WorkOrderTask>? tasks,
    List<String>? entryInspectionImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkOrder(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      branchId: branchId ?? this.branchId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      internalNumber: internalNumber ?? this.internalNumber,
      formattedNumber: formattedNumber ?? this.formattedNumber,
      status: status ?? this.status,
      diagnosticSummary: diagnosticSummary ?? this.diagnosticSummary,
      mileageIn: mileageIn ?? this.mileageIn,
      totalAmount: totalAmount ?? this.totalAmount,
      tasks: tasks ?? this.tasks,
      entryInspectionImages: entryInspectionImages ?? this.entryInspectionImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          formattedNumber == other.formattedNumber &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ formattedNumber.hashCode ^ status.hashCode;
}

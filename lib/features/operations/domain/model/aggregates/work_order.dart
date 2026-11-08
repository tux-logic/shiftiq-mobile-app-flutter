import 'package:shiftiq_mobile_app_flutter/features/operations/domain/model/entities/work_order_task.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/model/valueobjects/work_order_status.dart';

class WorkOrder {
  final String id;
  final String? appointmentId;
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
  final DateTime? createdAt;

  const WorkOrder({
    required this.id,
    this.appointmentId,
    required this.branchId,
    required this.vehicleId,
    this.vehiclePlate = 'S/P',
    this.vehicleModel = 'Vehículo General',
    required this.customerId,
    this.customerName = 'Cliente General',
    this.customerPhone = '',
    required this.internalNumber,
    required this.formattedNumber,
    required this.status,
    required this.diagnosticSummary,
    required this.mileageIn,
    required this.totalAmount,
    this.tasks = const [],
    this.entryInspectionImages = const [],
    this.createdAt,
  });

  bool get isCompleted =>
      status == WorkOrderStatus.completed || status == WorkOrderStatus.paid;
  bool get isInProgress => status == WorkOrderStatus.inProgress;
  bool get isPending => status == WorkOrderStatus.pending;

  int get totalTasksCount => tasks.length;
  int get completedTasksCount => tasks.where((t) => t.isCompleted).length;
  bool get allTasksCompleted =>
      tasks.isNotEmpty && completedTasksCount == totalTasksCount;

  String get formattedAmount => 'S/ ${totalAmount.toStringAsFixed(2)}';
  String get formattedMileage => '${mileageIn.toString()} km';

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
      entryInspectionImages:
          entryInspectionImages ?? this.entryInspectionImages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:shiftiq_mobile_app_flutter/features/operations/domain/task_product.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_task.dart';

class TaskProductDto {
  final String id;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;

  TaskProductDto({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
  });

  factory TaskProductDto.fromJson(Map<String, dynamic> json) {
    return TaskProductDto(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  TaskProduct toDomain({String productName = 'Repuesto de Taller'}) {
    return TaskProduct(
      id: id,
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
    );
  }
}

class WorkOrderTaskDto {
  final String id;
  final String? serviceId;
  final String description;
  final double price;
  final String status;
  final String? assignedMechanicId;
  final List<TaskProductDto> products;
  final DateTime? startedAt;
  final DateTime? completedAt;

  WorkOrderTaskDto({
    required this.id,
    this.serviceId,
    required this.description,
    required this.price,
    required this.status,
    this.assignedMechanicId,
    this.products = const [],
    this.startedAt,
    this.completedAt,
  });

  factory WorkOrderTaskDto.fromJson(Map<String, dynamic> json) {
    var rawProducts = json['products'];
    List<TaskProductDto> parsedProducts = [];
    if (rawProducts is List) {
      parsedProducts = rawProducts
          .map((p) => TaskProductDto.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    return WorkOrderTaskDto(
      id: json['id'] as String? ?? '',
      serviceId: json['serviceId'] as String?,
      description: json['description'] as String? ?? 'Tarea Mecánica',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'PENDING',
      assignedMechanicId: json['assignedMechanicId'] as String?,
      products: parsedProducts,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }

  WorkOrderTask toDomain({String mechanicName = 'Sin asignar'}) {
    return WorkOrderTask(
      id: id,
      serviceId: serviceId,
      description: description,
      price: price,
      status: status,
      assignedMechanicId: assignedMechanicId,
      assignedMechanicName: mechanicName,
      products: products.map((p) => p.toDomain()).toList(),
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }
}

class WorkOrderDto {
  final String id;
  final String? appointmentId;
  final String branchId;
  final String vehicleId;
  final String customerId;
  final int internalNumber;
  final String formattedNumber;
  final String status;
  final String diagnosticSummary;
  final int mileageIn;
  final double totalAmount;
  final List<WorkOrderTaskDto> tasks;
  final List<String> entryInspectionImages;
  final DateTime? createdAt;

  WorkOrderDto({
    required this.id,
    this.appointmentId,
    required this.branchId,
    required this.vehicleId,
    required this.customerId,
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

  factory WorkOrderDto.fromJson(Map<String, dynamic> json) {
    var rawTasks = json['tasks'];
    List<WorkOrderTaskDto> parsedTasks = [];
    if (rawTasks is List) {
      parsedTasks = rawTasks
          .map((t) => WorkOrderTaskDto.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    var rawImages = json['entryInspectionImages'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((img) => img.toString()).toList();
    }

    return WorkOrderDto(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String?,
      branchId: json['branchId'] as String? ?? '',
      vehicleId: json['vehicleId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      internalNumber: (json['internalNumber'] as num?)?.toInt() ?? 0,
      formattedNumber: json['formattedNumber'] as String? ??
          'OT-${json['internalNumber'] ?? 1000}',
      status: json['status'] as String? ?? 'PENDING',
      diagnosticSummary: json['diagnosticSummary'] as String? ?? '',
      mileageIn: (json['mileageIn'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      tasks: parsedTasks,
      entryInspectionImages: parsedImages,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  WorkOrder toDomain({
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    String customerName = 'Cliente General',
    String customerPhone = '',
  }) {
    return WorkOrder(
      id: id,
      appointmentId: appointmentId,
      branchId: branchId,
      vehicleId: vehicleId,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      internalNumber: internalNumber,
      formattedNumber: formattedNumber,
      status: WorkOrderStatus.fromString(status),
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      totalAmount: totalAmount,
      tasks: tasks.map((t) => t.toDomain()).toList(),
      entryInspectionImages: entryInspectionImages,
      createdAt: createdAt,
    );
  }
}

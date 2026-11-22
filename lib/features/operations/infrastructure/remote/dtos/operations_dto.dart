import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Serialization and deserialization utilities for the Operations Bounded Context data transfer objects.
class OperationsDto {
  OperationsDto._();

  /// Deserializes a [WorkshopService] entity using Dart 3 pattern matching.
  static WorkshopService workshopServiceFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'branchId': final String branchId,
        'name': final String name,
        'price': final num price,
      } =>
        WorkshopService(
          id: id,
          branchId: branchId,
          name: name,
          price: price.toDouble(),
        ),
      _ => throw const FormatException(
          'Invalid WorkshopService JSON payload: missing required fields',
        ),
    };
  }

  /// Deserializes a list of [WorkshopService] entities.
  static List<WorkshopService> workshopServiceListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(workshopServiceFromJson)
        .toList();
  }

  /// Deserializes a [WorkOrderTaskProduct] value object using Dart 3 pattern matching.
  static WorkOrderTaskProduct workOrderTaskProductFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'productId': final String productId,
        'branchId': final String branchId,
        'quantity': final num qty,
        'unitPrice': final num unitPrice,
        'totalAmount': final num totalAmount,
      } =>
        WorkOrderTaskProduct(
          id: id,
          productId: productId,
          productName: _resolveProductName(json),
          branchId: branchId,
          quantity: qty.toInt(),
          unitPrice: unitPrice.toDouble(),
          totalAmount: totalAmount.toDouble(),
          createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        ),
      _ => throw const FormatException(
          'Invalid WorkOrderTaskProduct JSON payload: missing required fields',
        ),
    };
  }

  /// Deserializes a list of [WorkOrderTaskProduct] objects.
  static List<WorkOrderTaskProduct> workOrderTaskProductListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(workOrderTaskProductFromJson)
        .toList();
  }

  /// Deserializes a [WorkOrderTask] entity using Dart 3 pattern matching.
  static WorkOrderTask workOrderTaskFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'serviceId': final String serviceId,
        'branchId': final String branchId,
        'assignedMechanicId': final String mechanicId,
        'description': final String description,
        'price': final num price,
      } =>
        WorkOrderTask(
          id: id,
          serviceId: serviceId,
          branchId: branchId,
          assignedMechanicId: mechanicId,
          assignedMechanicName: _resolveMechanicName(json),
          status: TaskStatus.fromString(json['status']?.toString()),
          description: description,
          price: price.toDouble(),
          startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
          completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
          products: json['products'] is List
              ? workOrderTaskProductListFromJson(json['products'] as List)
              : const [],
          evidenceImages: json['evidenceImages'] is List
              ? (json['evidenceImages'] as List).cast<String>()
              : const [],
          createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        ),
      _ => throw const FormatException(
          'Invalid WorkOrderTask JSON payload: missing required fields',
        ),
    };
  }

  /// Deserializes a list of [WorkOrderTask] entities.
  static List<WorkOrderTask> workOrderTaskListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(workOrderTaskFromJson)
        .toList();
  }

  /// Deserializes a [WorkOrder] aggregate root using Dart 3 pattern matching.
  static WorkOrder workOrderFromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final String id,
        'appointmentId': final String appointmentId,
        'branchId': final String branchId,
        'vehicleId': final String vehicleId,
        'customerId': final String customerId,
        'internalNumber': final num internalNumber,
        'formattedNumber': final String formattedNumber,
        'diagnosticSummary': final String diagnosticSummary,
        'mileageIn': final num mileageIn,
        'totalAmount': final num totalAmount,
      } =>
        WorkOrder(
          id: id,
          appointmentId: appointmentId,
          branchId: branchId,
          vehicleId: vehicleId,
          vehiclePlate: _resolveVehiclePlate(json),
          vehicleModel: _resolveVehicleDisplay(json),
          customerId: customerId,
          customerName: json['customerName']?.toString() ?? 'Cliente General',
          customerPhone: json['customerPhone']?.toString() ?? '',
          internalNumber: internalNumber.toInt(),
          formattedNumber: formattedNumber,
          status: WorkOrderStatus.fromString(json['status']?.toString()),
          diagnosticSummary: diagnosticSummary,
          mileageIn: mileageIn.toInt(),
          totalAmount: totalAmount.toDouble(),
          tasks: json['tasks'] is List
              ? workOrderTaskListFromJson(json['tasks'] as List)
              : const [],
          entryInspectionImages: json['entryInspectionImages'] is List
              ? (json['entryInspectionImages'] as List).cast<String>()
              : const [],
          createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
          updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
        ),
      _ => throw const FormatException(
          'Invalid WorkOrder JSON payload: missing required fields',
        ),
    };
  }

  static String _resolveMechanicName(Map<String, dynamic> json) {
    final raw =
        (json['assignedMechanicName'] ?? json['mechanicName'])?.toString().trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return 'Sin asignar';
  }

  static String _resolveProductName(Map<String, dynamic> json) {
    final raw = (json['productName'] ?? json['name'])?.toString().trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return 'Repuesto';
  }

  static String _resolveVehiclePlate(Map<String, dynamic> json) {
    final raw = (json['vehiclePlateNumber'] ?? json['vehiclePlate'])
        ?.toString()
        .trim();
    if (raw != null && raw.isNotEmpty) return raw;
    return 'S/P';
  }

  static String _resolveVehicleDisplay(Map<String, dynamic> json) {
    final brand = json['vehicleBrand']?.toString().trim() ?? '';
    final model = json['vehicleModel']?.toString().trim() ?? '';
    final year = json['vehicleYear']?.toString().trim() ?? '';

    final base = [brand, model].where((part) => part.isNotEmpty).join(' ');
    if (base.isEmpty) return 'Vehículo General';
    if (year.isNotEmpty && !base.contains(year)) {
      return '$base $year';
    }
    return base;
  }

  /// Deserializes a list of [WorkOrder] entities.
  static List<WorkOrder> workOrderListFromJson(List<dynamic> list) {
    return list
        .whereType<Map<String, dynamic>>()
        .map(workOrderFromJson)
        .toList();
  }
}

import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Application use case to open, inspect, update, and complete automotive repair work orders.
class ManageWorkOrders {
  final OperationsRepository repository;

  const ManageWorkOrders({required this.repository});

  /// Opens a new work order from an existing appointment.
  Future<WorkOrder> createWorkOrder({
    required String appointmentId,
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    List<String> entryInspectionImages = const [],
  }) async {
    final trimmedApptId = appointmentId.trim();
    final trimmedBranchId = branchId.trim();
    final trimmedVehicleId = vehicleId.trim();
    final trimmedCustomerId = customerId.trim();
    final trimmedDiag = diagnosticSummary.trim();

    if (trimmedApptId.isEmpty) {
      throw ArgumentError('Appointment ID cannot be empty.');
    }
    if (trimmedBranchId.isEmpty) {
      throw ArgumentError('Branch ID cannot be empty.');
    }
    if (trimmedVehicleId.isEmpty) {
      throw ArgumentError('Vehicle ID cannot be empty.');
    }
    if (trimmedCustomerId.isEmpty) {
      throw ArgumentError('Customer ID cannot be empty.');
    }
    if (trimmedDiag.length < 5) {
      throw ArgumentError('Diagnostic summary must be at least 5 characters long.');
    }
    if (mileageIn < 0) {
      throw ArgumentError('Intake mileage cannot be negative.');
    }

    return repository.createWorkOrder(
      appointmentId: trimmedApptId,
      branchId: trimmedBranchId,
      vehicleId: trimmedVehicleId,
      customerId: trimmedCustomerId,
      diagnosticSummary: trimmedDiag,
      mileageIn: mileageIn,
      entryInspectionImages: entryInspectionImages,
    );
  }

  /// Queries work orders filtered by branch or vehicle.
  Future<List<WorkOrder>> getWorkOrders({
    String? branchId,
    String? vehicleId,
  }) async {
    final trimmedBranchId = branchId?.trim();
    final trimmedVehicleId = vehicleId?.trim();

    if ((trimmedBranchId == null || trimmedBranchId.isEmpty) &&
        (trimmedVehicleId == null || trimmedVehicleId.isEmpty)) {
      throw ArgumentError('Either branchId or vehicleId must be provided.');
    }

    return repository.getWorkOrders(
      branchId: trimmedBranchId,
      vehicleId: trimmedVehicleId,
    );
  }

  /// Retrieves detailed information for a specific work order.
  Future<WorkOrder> getWorkOrderById(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Work Order ID cannot be empty.');
    }

    return repository.getWorkOrderById(trimmedId);
  }

  /// Updates intake diagnostic summary and odometer reading.
  Future<WorkOrder> updateWorkOrderIntake({
    required String id,
    required String diagnosticSummary,
    required int mileageIn,
    List<String>? entryInspectionImages,
  }) async {
    final trimmedId = id.trim();
    final trimmedDiag = diagnosticSummary.trim();

    if (trimmedId.isEmpty) {
      throw ArgumentError('Work Order ID cannot be empty.');
    }
    if (trimmedDiag.length < 5) {
      throw ArgumentError('Diagnostic summary must be at least 5 characters long.');
    }
    if (mileageIn < 0) {
      throw ArgumentError('Intake mileage cannot be negative.');
    }

    return repository.updateWorkOrderIntake(
      id: trimmedId,
      diagnosticSummary: trimmedDiag,
      mileageIn: mileageIn,
      entryInspectionImages: entryInspectionImages,
    );
  }

  /// Completes a work order once all mechanical tasks are finished.
  Future<WorkOrder> completeWorkOrder(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Work Order ID cannot be empty.');
    }

    return repository.completeWorkOrder(trimmedId);
  }

  /// Cancels and deletes an active work order, releasing all reserved stock.
  Future<void> deleteWorkOrder(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw ArgumentError('Work Order ID cannot be empty.');
    }

    return repository.deleteWorkOrder(trimmedId);
  }
}

import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';

class CreateWorkOrderUseCase {
  final WorkOrderRepository repository;

  CreateWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute({
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    String? appointmentId,
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    String customerName = 'Cliente General',
  }) {
    return repository.createWorkOrder(
      branchId: branchId,
      vehicleId: vehicleId,
      customerId: customerId,
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      appointmentId: appointmentId,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      customerName: customerName,
    );
  }
}


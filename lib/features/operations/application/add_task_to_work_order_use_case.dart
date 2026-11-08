import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';

class AddTaskToWorkOrderUseCase {
  final WorkOrderRepository repository;

  AddTaskToWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute({
    required String workOrderId,
    required String description,
    required double price,
    String? serviceId,
    String? mechanicId,
    String mechanicName = 'Sin asignar',
  }) {
    return repository.addTask(
      workOrderId: workOrderId,
      description: description,
      price: price,
      serviceId: serviceId,
      mechanicId: mechanicId,
      mechanicName: mechanicName,
    );
  }
}


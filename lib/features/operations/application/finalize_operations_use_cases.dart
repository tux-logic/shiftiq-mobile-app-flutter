import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';

class AddProductToTaskUseCase {
  final WorkOrderRepository repository;

  AddProductToTaskUseCase({required this.repository});

  Future<WorkOrder> execute({
    required String taskId,
    required String productId,
    required int quantity,
    required double unitPrice,
    String productName = 'Repuesto de Taller',
  }) {
    return repository.addProductToTask(
      taskId: taskId,
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      productName: productName,
    );
  }
}

class CompleteWorkOrderUseCase {
  final WorkOrderRepository repository;

  CompleteWorkOrderUseCase({required this.repository});

  Future<WorkOrder> execute(String workOrderId) {
    return repository.completeWorkOrder(workOrderId);
  }
}


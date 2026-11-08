import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';

class StartTaskUseCase {
  final WorkOrderRepository repository;

  StartTaskUseCase({required this.repository});

  Future<WorkOrder> execute(String taskId) {
    return repository.startTask(taskId);
  }
}

class CompleteTaskUseCase {
  final WorkOrderRepository repository;

  CompleteTaskUseCase({required this.repository});

  Future<WorkOrder> execute(String taskId) {
    return repository.completeTask(taskId);
  }
}


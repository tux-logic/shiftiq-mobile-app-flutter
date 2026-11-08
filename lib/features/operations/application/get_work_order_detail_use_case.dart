import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';

class GetWorkOrderDetailUseCase {
  final WorkOrderRepository repository;

  GetWorkOrderDetailUseCase({required this.repository});

  Future<WorkOrder> execute(String id) {
    return repository.getWorkOrderById(id);
  }
}

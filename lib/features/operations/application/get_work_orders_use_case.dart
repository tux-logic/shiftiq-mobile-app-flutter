import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_status.dart';

class GetWorkOrdersUseCase {
  final WorkOrderRepository repository;

  GetWorkOrdersUseCase({required this.repository});

  Future<List<WorkOrder>> execute({
    required String branchId,
    WorkOrderStatus? status,
  }) {
    return repository.getWorkOrders(branchId: branchId, status: status);
  }
}

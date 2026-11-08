import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/create_work_order_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/finalize_operations_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/get_work_order_detail_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/get_work_orders_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/manage_task_status_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/task_product.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_task.dart';

class MockWorkOrderRepository implements WorkOrderRepository {
  final List<WorkOrder> _orders = [
    WorkOrder(
      id: 'wo-01',
      branchId: 'b-01-smp',
      vehicleId: 'veh-01',
      vehiclePlate: 'BCX-892',
      vehicleModel: 'Toyota Hilux 2021',
      customerId: 'cust-01',
      customerName: 'Carlos Mendoza',
      internalNumber: 1042,
      formattedNumber: 'OT-2026-0042',
      status: WorkOrderStatus.inProgress,
      diagnosticSummary: 'Mantenimiento correctivo frenos',
      mileageIn: 48500,
      totalAmount: 450.00,
      tasks: [
        const WorkOrderTask(
          id: 'task-01-1',
          description: 'Diagnóstico frenos',
          price: 80.00,
          status: 'COMPLETED',
        ),
        const WorkOrderTask(
          id: 'task-01-2',
          description: 'Cambio pastillas',
          price: 120.00,
          status: 'IN_PROGRESS',
          products: [
            TaskProduct(
              id: 'tp-01',
              productId: 'prod-01',
              productName: 'Pastillas Bosch',
              quantity: 2,
              unitPrice: 50.00,
              totalAmount: 100.00,
            ),
          ],
        ),
      ],
    ),
    WorkOrder(
      id: 'wo-02',
      branchId: 'b-01-smp',
      vehicleId: 'veh-02',
      vehiclePlate: 'F1X-902',
      vehicleModel: 'Nissan Frontier 2019',
      customerId: 'cust-02',
      customerName: 'Jorge Castro',
      internalNumber: 1040,
      formattedNumber: 'OT-2026-0040',
      status: WorkOrderStatus.pending,
      diagnosticSummary: 'Cambio de aceite',
      mileageIn: 50200,
      totalAmount: 120.00,
    ),
  ];

  @override
  Future<List<WorkOrder>> getWorkOrders({
    required String branchId,
    WorkOrderStatus? status,
  }) async {
    var result = _orders.where((wo) => wo.branchId == branchId).toList();
    if (status != null) {
      result = result.where((wo) => wo.status == status).toList();
    }
    return result;
  }

  @override
  Future<WorkOrder> getWorkOrderById(String id) async {
    return _orders.firstWhere((wo) => wo.id == id);
  }

  @override
  Future<WorkOrder> createWorkOrder({
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    String? appointmentId,
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    String customerName = 'Cliente General',
  }) async {
    final order = WorkOrder(
      id: 'wo-created',
      branchId: branchId,
      vehicleId: vehicleId,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      customerId: customerId,
      customerName: customerName,
      internalNumber: 1043,
      formattedNumber: 'OT-2026-1043',
      status: WorkOrderStatus.pending,
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      totalAmount: 0.0,
    );
    _orders.add(order);
    return order;
  }

  @override
  Future<WorkOrder> addTask({
    required String workOrderId,
    required String description,
    required double price,
    String? serviceId,
    String? mechanicId,
    String mechanicName = 'Sin asignar',
  }) async {
    final order = await getWorkOrderById(workOrderId);
    final updatedTasks = List<WorkOrderTask>.from(order.tasks)
      ..add(
        WorkOrderTask(
          id: 'task-new',
          description: description,
          price: price,
        ),
      );
    return WorkOrder(
      id: order.id,
      branchId: order.branchId,
      vehicleId: order.vehicleId,
      customerId: order.customerId,
      internalNumber: order.internalNumber,
      formattedNumber: order.formattedNumber,
      status: order.status,
      diagnosticSummary: order.diagnosticSummary,
      mileageIn: order.mileageIn,
      totalAmount: order.totalAmount + price,
      tasks: updatedTasks,
    );
  }

  @override
  Future<WorkOrder> startTask(String taskId) async {
    final order = _orders.first;
    final updatedTasks = order.tasks.map((t) {
      if (t.id == taskId) {
        return WorkOrderTask(
          id: t.id,
          description: t.description,
          price: t.price,
          status: 'IN_PROGRESS',
        );
      }
      return t;
    }).toList();
    return WorkOrder(
      id: order.id,
      branchId: order.branchId,
      vehicleId: order.vehicleId,
      customerId: order.customerId,
      internalNumber: order.internalNumber,
      formattedNumber: order.formattedNumber,
      status: order.status,
      diagnosticSummary: order.diagnosticSummary,
      mileageIn: order.mileageIn,
      totalAmount: order.totalAmount,
      tasks: updatedTasks,
    );
  }

  @override
  Future<WorkOrder> completeTask(String taskId) async {
    final order = _orders.first;
    final updatedTasks = order.tasks.map((t) {
      if (t.id == taskId) {
        return WorkOrderTask(
          id: t.id,
          description: t.description,
          price: t.price,
          status: 'COMPLETED',
        );
      }
      return t;
    }).toList();
    return WorkOrder(
      id: order.id,
      branchId: order.branchId,
      vehicleId: order.vehicleId,
      customerId: order.customerId,
      internalNumber: order.internalNumber,
      formattedNumber: order.formattedNumber,
      status: order.status,
      diagnosticSummary: order.diagnosticSummary,
      mileageIn: order.mileageIn,
      totalAmount: order.totalAmount,
      tasks: updatedTasks,
    );
  }

  @override
  Future<WorkOrder> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
    required double unitPrice,
    String productName = 'Repuesto',
  }) async {
    final order = _orders.first;
    return WorkOrder(
      id: order.id,
      branchId: order.branchId,
      vehicleId: order.vehicleId,
      customerId: order.customerId,
      internalNumber: order.internalNumber,
      formattedNumber: order.formattedNumber,
      status: order.status,
      diagnosticSummary: order.diagnosticSummary,
      mileageIn: order.mileageIn,
      totalAmount: order.totalAmount + (unitPrice * quantity),
      tasks: order.tasks,
    );
  }

  @override
  Future<WorkOrder> completeWorkOrder(String workOrderId) async {
    final order = await getWorkOrderById(workOrderId);
    return WorkOrder(
      id: order.id,
      branchId: order.branchId,
      vehicleId: order.vehicleId,
      customerId: order.customerId,
      internalNumber: order.internalNumber,
      formattedNumber: order.formattedNumber,
      status: WorkOrderStatus.completed,
      diagnosticSummary: order.diagnosticSummary,
      mileageIn: order.mileageIn,
      totalAmount: order.totalAmount,
      tasks: order.tasks,
    );
  }
}

void main() {
  group('Operations Work Orders Use Cases', () {
    late MockWorkOrderRepository repository;

    setUp(() {
      repository = MockWorkOrderRepository();
    });

    test('GetWorkOrdersUseCase should filter by branch and status', () async {
      final useCase = GetWorkOrdersUseCase(repository: repository);

      final allOrders = await useCase.execute(branchId: 'b-01-smp');
      expect(allOrders.length, equals(2));

      final inProgressOrders = await useCase.execute(
        branchId: 'b-01-smp',
        status: WorkOrderStatus.inProgress,
      );
      expect(inProgressOrders.length, equals(1));
      expect(inProgressOrders.first.formattedNumber, equals('OT-2026-0042'));
    });

    test('GetWorkOrderDetailUseCase should return full order aggregate', () async {
      final useCase = GetWorkOrderDetailUseCase(repository: repository);
      final order = await useCase.execute('wo-01');

      expect(order.formattedNumber, equals('OT-2026-0042'));
      expect(order.vehiclePlate, equals('BCX-892'));
      expect(order.tasks.length, equals(2));
      expect(order.completedTasksCount, equals(1));
      expect(order.allTasksCompleted, isFalse);
      expect(order.formattedAmount, equals('S/ 450.00'));
    });

    test('CreateWorkOrderUseCase should add a new pending order', () async {
      final useCase = CreateWorkOrderUseCase(repository: repository);
      final created = await useCase.execute(
        branchId: 'b-01-smp',
        vehicleId: 'veh-99',
        customerId: 'cust-99',
        vehiclePlate: 'M3X-100',
        vehicleModel: 'Honda Civic 2020',
        customerName: 'Laura Díaz',
        diagnosticSummary: 'Revisión técnica periódica',
        mileageIn: 32000,
      );

      expect(created.status, equals(WorkOrderStatus.pending));
      expect(created.vehiclePlate, equals('M3X-100'));
      expect(created.customerName, equals('Laura Díaz'));
    });

    test('StartTask and CompleteTask should transition task status', () async {
      final startUseCase = StartTaskUseCase(repository: repository);
      final completeUseCase = CompleteTaskUseCase(repository: repository);

      final afterStart = await startUseCase.execute('task-01-1');
      expect(afterStart.tasks.first.status, equals('IN_PROGRESS'));

      final afterComplete = await completeUseCase.execute('task-01-1');
      expect(afterComplete.tasks.first.status, equals('COMPLETED'));
    });

    test('AddProductToTaskUseCase should recalculate order total amount', () async {
      final useCase = AddProductToTaskUseCase(repository: repository);
      final updated = await useCase.execute(
        taskId: 'task-01-2',
        productId: 'prod-99',
        quantity: 2,
        unitPrice: 50.00,
      );

      expect(updated.totalAmount, equals(550.00));
    });

    test('CompleteWorkOrderUseCase should mark order as completed', () async {
      final useCase = CompleteWorkOrderUseCase(repository: repository);
      final completed = await useCase.execute('wo-01');

      expect(completed.status, equals(WorkOrderStatus.completed));
      expect(completed.isCompleted, isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_view_model.dart';

class FakeOperationsRepository implements OperationsRepository {
  final List<WorkshopService> services = [
    const WorkshopService(
      id: 'srv-01',
      branchId: 'b-01',
      name: 'Brake Disc Rectification',
      price: 80.0,
    ),
    const WorkshopService(
      id: 'srv-02',
      branchId: 'b-01',
      name: 'Computerized Wheel Alignment',
      price: 95.0,
    ),
  ];

  final List<WorkOrder> workOrders = [
    WorkOrder(
      id: 'wo-01',
      appointmentId: 'appt-01',
      branchId: 'b-01',
      vehicleId: 'veh-01',
      vehiclePlate: 'BCX-892',
      vehicleModel: 'Toyota Hilux 2021',
      customerId: 'cust-01',
      customerName: 'Carlos Mendoza',
      internalNumber: 1,
      formattedNumber: 'MOL-01-000001',
      status: WorkOrderStatus.inProgress,
      diagnosticSummary: 'Vibration when braking at high speed',
      mileageIn: 45200,
      totalAmount: 180.0,
      tasks: [
        const WorkOrderTask(
          id: 'task-01',
          serviceId: 'srv-01',
          branchId: 'b-01',
          assignedMechanicId: 'ereg-01',
          assignedMechanicName: 'Juan Perez',
          status: TaskStatus.doing,
          description: 'Front disc pads replacement',
          price: 80.0,
          products: [
            WorkOrderTaskProduct(
              id: 'tp-01',
              productId: 'prod-01',
              productName: 'Ceramic Brake Pads',
              branchId: 'b-01',
              quantity: 1,
              unitPrice: 100.0,
              totalAmount: 100.0,
            ),
          ],
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // --- Services ---
  @override
  Future<WorkshopService> createService({
    required String branchId,
    required String name,
    required double price,
  }) async {
    final newService = WorkshopService(
      id: 'srv-${services.length + 1}',
      branchId: branchId,
      name: name,
      price: price,
    );
    services.add(newService);
    return newService;
  }

  @override
  Future<List<WorkshopService>> getBranchServices(String branchId) async {
    return services.where((s) => s.branchId == branchId).toList();
  }

  @override
  Future<WorkshopService> updateService({
    required String serviceId,
    required String name,
    required double price,
  }) async {
    final idx = services.indexWhere((s) => s.id == serviceId);
    if (idx == -1) throw Exception('Service not found');
    final updated = WorkshopService(
      id: serviceId,
      branchId: services[idx].branchId,
      name: name,
      price: price,
    );
    services[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteService(String serviceId) async {
    services.removeWhere((s) => s.id == serviceId);
  }

  // --- Work Orders ---
  @override
  Future<WorkOrder> createWorkOrder({
    required String appointmentId,
    required String branchId,
    required String vehicleId,
    required String customerId,
    required String diagnosticSummary,
    required int mileageIn,
    List<String> entryInspectionImages = const [],
  }) async {
    final newOrder = WorkOrder(
      id: 'wo-${workOrders.length + 1}',
      appointmentId: appointmentId,
      branchId: branchId,
      vehicleId: vehicleId,
      customerId: customerId,
      internalNumber: workOrders.length + 1,
      formattedNumber: 'MOL-01-00000${workOrders.length + 1}',
      status: WorkOrderStatus.pending,
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      totalAmount: 0.0,
      entryInspectionImages: entryInspectionImages,
      createdAt: DateTime.now(),
    );
    workOrders.add(newOrder);
    return newOrder;
  }

  @override
  Future<List<WorkOrder>> getWorkOrders({
    String? branchId,
    String? vehicleId,
  }) async {
    Iterable<WorkOrder> result = workOrders;
    if (branchId != null && branchId.isNotEmpty) {
      result = result.where((o) => o.branchId == branchId);
    }
    if (vehicleId != null && vehicleId.isNotEmpty) {
      result = result.where((o) => o.vehicleId == vehicleId);
    }
    return result.toList();
  }

  @override
  Future<WorkOrder> getWorkOrderById(String id) async {
    return workOrders.firstWhere((o) => o.id == id);
  }

  @override
  Future<WorkOrder> updateWorkOrderIntake({
    required String id,
    required String diagnosticSummary,
    required int mileageIn,
    List<String>? entryInspectionImages,
  }) async {
    final idx = workOrders.indexWhere((o) => o.id == id);
    if (idx == -1) throw Exception('Work order not found');
    final updated = workOrders[idx].copyWith(
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      entryInspectionImages: entryInspectionImages ?? workOrders[idx].entryInspectionImages,
    );
    workOrders[idx] = updated;
    return updated;
  }

  @override
  Future<WorkOrder> completeWorkOrder(String id) async {
    final idx = workOrders.indexWhere((o) => o.id == id);
    if (idx == -1) throw Exception('Work order not found');
    final updated = workOrders[idx].copyWith(
      status: WorkOrderStatus.completed,
      updatedAt: DateTime.now(),
    );
    workOrders[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteWorkOrder(String id) async {
    workOrders.removeWhere((o) => o.id == id);
  }

  // --- Work Order Tasks ---
  @override
  Future<WorkOrder> addTaskToWorkOrder({
    required String workOrderId,
    required String serviceId,
    required String assignedMechanicId,
    required String description,
    List<String> evidenceImages = const [],
  }) async {
    final idx = workOrders.indexWhere((o) => o.id == workOrderId);
    if (idx == -1) throw Exception('Work order not found');
    final newTask = WorkOrderTask(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      serviceId: serviceId,
      branchId: workOrders[idx].branchId,
      assignedMechanicId: assignedMechanicId,
      description: description,
      price: 50.0,
      evidenceImages: evidenceImages,
      status: TaskStatus.pending,
    );
    final updatedTasks = [...workOrders[idx].tasks, newTask];
    final updated = workOrders[idx].copyWith(
      tasks: updatedTasks,
      status: WorkOrderStatus.inProgress,
      totalAmount: workOrders[idx].totalAmount + newTask.price,
    );
    workOrders[idx] = updated;
    return updated;
  }

  @override
  Future<WorkOrderTask> updateTaskDetails({
    required String workOrderId,
    required String taskId,
    String? serviceId,
    String? assignedMechanicId,
    String? description,
    List<String>? evidenceImages,
  }) async {
    final orderIdx = workOrders.indexWhere((o) => o.id == workOrderId);
    if (orderIdx == -1) throw Exception('Work order not found');
    final taskIdx = workOrders[orderIdx].tasks.indexWhere((t) => t.id == taskId);
    if (taskIdx == -1) throw Exception('Task not found');

    final updated = workOrders[orderIdx].tasks[taskIdx].copyWith(
      serviceId: serviceId,
      assignedMechanicId: assignedMechanicId,
      description: description,
      evidenceImages: evidenceImages,
    );
    final tasksList = [...workOrders[orderIdx].tasks];
    tasksList[taskIdx] = updated;
    workOrders[orderIdx] = workOrders[orderIdx].copyWith(tasks: tasksList);
    return updated;
  }

  @override
  Future<void> deleteTask({
    required String workOrderId,
    required String taskId,
  }) async {
    final orderIdx = workOrders.indexWhere((o) => o.id == workOrderId);
    if (orderIdx == -1) throw Exception('Work order not found');
    final tasksList = [...workOrders[orderIdx].tasks]..removeWhere((t) => t.id == taskId);
    workOrders[orderIdx] = workOrders[orderIdx].copyWith(tasks: tasksList);
  }

  @override
  Future<WorkOrder> assignMechanicToTask({
    required String taskId,
    required String mechanicId,
  }) async {
    for (int i = 0; i < workOrders.length; i++) {
      final taskIdx = workOrders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final updatedTask = workOrders[i].tasks[taskIdx].copyWith(
          assignedMechanicId: mechanicId,
        );
        final tasks = [...workOrders[i].tasks];
        tasks[taskIdx] = updatedTask;
        workOrders[i] = workOrders[i].copyWith(tasks: tasks);
        return workOrders[i];
      }
    }
    throw Exception('Task not found');
  }

  @override
  Future<WorkOrder> startTask(String taskId) async {
    for (int i = 0; i < workOrders.length; i++) {
      final taskIdx = workOrders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final updatedTask = workOrders[i].tasks[taskIdx].copyWith(
          status: TaskStatus.doing,
          startedAt: DateTime.now(),
        );
        final tasks = [...workOrders[i].tasks];
        tasks[taskIdx] = updatedTask;
        workOrders[i] = workOrders[i].copyWith(
          tasks: tasks,
          status: WorkOrderStatus.inProgress,
        );
        return workOrders[i];
      }
    }
    throw Exception('Task not found');
  }

  @override
  Future<WorkOrder> completeTask(String taskId) async {
    for (int i = 0; i < workOrders.length; i++) {
      final taskIdx = workOrders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final updatedTask = workOrders[i].tasks[taskIdx].copyWith(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
        );
        final tasks = [...workOrders[i].tasks];
        tasks[taskIdx] = updatedTask;
        workOrders[i] = workOrders[i].copyWith(tasks: tasks);
        return workOrders[i];
      }
    }
    throw Exception('Task not found');
  }

  @override
  Future<WorkOrder> reopenTask(String taskId) async {
    for (int i = 0; i < workOrders.length; i++) {
      final taskIdx = workOrders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final updatedTask = workOrders[i].tasks[taskIdx].copyWith(
          status: TaskStatus.doing,
          completedAt: null,
        );
        final tasks = [...workOrders[i].tasks];
        tasks[taskIdx] = updatedTask;
        workOrders[i] = workOrders[i].copyWith(
          tasks: tasks,
          status: WorkOrderStatus.inProgress,
        );
        return workOrders[i];
      }
    }
    throw Exception('Task not found');
  }

  // --- Task Products ---
  @override
  Future<WorkOrder> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    for (int i = 0; i < workOrders.length; i++) {
      final taskIdx = workOrders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final newProduct = WorkOrderTaskProduct(
          id: 'tp-${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          branchId: workOrders[i].branchId,
          quantity: quantity,
          unitPrice: 40.0,
          totalAmount: 40.0 * quantity,
        );
        final updatedProducts = [...workOrders[i].tasks[taskIdx].products, newProduct];
        final updatedTask = workOrders[i].tasks[taskIdx].copyWith(products: updatedProducts);
        final tasks = [...workOrders[i].tasks];
        tasks[taskIdx] = updatedTask;
        workOrders[i] = workOrders[i].copyWith(
          tasks: tasks,
          totalAmount: workOrders[i].totalAmount + newProduct.totalAmount,
        );
        return workOrders[i];
      }
    }
    throw Exception('Task not found');
  }

  @override
  Future<WorkOrder> updateTaskProductQuantity({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    for (int i = 0; i < workOrders.length; i++) {
      final taskIdx = workOrders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final prodIdx = workOrders[i].tasks[taskIdx].products.indexWhere((p) => p.productId == productId);
        if (prodIdx != -1) {
          final oldProduct = workOrders[i].tasks[taskIdx].products[prodIdx];
          final updatedProduct = oldProduct.copyWith(
            quantity: quantity,
            totalAmount: oldProduct.unitPrice * quantity,
          );
          final products = [...workOrders[i].tasks[taskIdx].products];
          products[prodIdx] = updatedProduct;
          final updatedTask = workOrders[i].tasks[taskIdx].copyWith(products: products);
          final tasks = [...workOrders[i].tasks];
          tasks[taskIdx] = updatedTask;
          workOrders[i] = workOrders[i].copyWith(tasks: tasks);
          return workOrders[i];
        }
      }
    }
    throw Exception('Product or task not found');
  }

  @override
  Future<void> removeProductFromTask({
    required String taskId,
    required String productId,
  }) async {
    for (int i = 0; i < workOrders.length; i++) {
      final taskIdx = workOrders[i].tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final products = [...workOrders[i].tasks[taskIdx].products]
          ..removeWhere((p) => p.productId == productId);
        final updatedTask = workOrders[i].tasks[taskIdx].copyWith(products: products);
        final tasks = [...workOrders[i].tasks];
        tasks[taskIdx] = updatedTask;
        workOrders[i] = workOrders[i].copyWith(tasks: tasks);
        return;
      }
    }
  }
}

class FakeSessionStorage implements SessionStorage {
  String? _branchId = 'b-01';
  String? _branchName = 'Sede Principal';

  @override
  String? get activeBranchId => _branchId;

  @override
  String? get activeBranchName => _branchName;

  @override
  Future<String?> getActiveBranchId() async => _branchId;

  @override
  Future<String?> getActiveBranchName() async => _branchName;

  @override
  Future<void> setActiveBranch({
    required String branchId,
    required String branchName,
  }) async {
    _branchId = branchId;
    _branchName = branchName;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeOperationsRepository repository;

  setUp(() {
    repository = FakeOperationsRepository();
  });

  group('ManageServices Use Case', () {
    test('enforces validation invariants and manages branch services catalog', () async {
      final manageServices = ManageServices(repository: repository);

      expect(
        () => manageServices.createService(
          branchId: '',
          name: 'Oil Change',
          price: 50.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageServices.createService(
          branchId: 'b-01',
          name: '',
          price: 50.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageServices.createService(
          branchId: 'b-01',
          name: 'Oil Change',
          price: 0.0,
        ),
        throwsArgumentError,
      );

      final created = await manageServices.createService(
        branchId: 'b-01',
        name: 'Oil Change and Filter Replacement',
        price: 75.0,
      );

      expect(created.id, isNotEmpty);
      expect(created.name, 'Oil Change and Filter Replacement');
      expect(created.price, 75.0);
      expect(repository.services.length, 3);

      final branchServices = await manageServices.getBranchServices('b-01');
      expect(branchServices.length, 3);

      final updated = await manageServices.updateService(
        serviceId: created.id,
        name: 'Synthetic Oil Change',
        price: 90.0,
      );
      expect(updated.name, 'Synthetic Oil Change');
      expect(updated.price, 90.0);

      await manageServices.deleteService(created.id);
      expect(repository.services.any((s) => s.id == created.id), isFalse);
    });
  });

  group('ManageWorkOrders Use Case', () {
    test('enforces validation and handles complete work order lifecycle', () async {
      final manageWorkOrders = ManageWorkOrders(repository: repository);

      expect(
        () => manageWorkOrders.createWorkOrder(
          appointmentId: '',
          branchId: 'b-01',
          vehicleId: 'veh-01',
          customerId: 'cust-01',
          diagnosticSummary: 'Engine issue',
          mileageIn: 50000,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageWorkOrders.createWorkOrder(
          appointmentId: 'appt-01',
          branchId: 'b-01',
          vehicleId: 'veh-01',
          customerId: 'cust-01',
          diagnosticSummary: 'Bad', // too short (< 5)
          mileageIn: 50000,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageWorkOrders.createWorkOrder(
          appointmentId: 'appt-01',
          branchId: 'b-01',
          vehicleId: 'veh-01',
          customerId: 'cust-01',
          diagnosticSummary: 'Routine maintenance check',
          mileageIn: -10, // negative mileage
        ),
        throwsArgumentError,
      );

      final order = await manageWorkOrders.createWorkOrder(
        appointmentId: 'appt-02',
        branchId: 'b-01',
        vehicleId: 'veh-02',
        customerId: 'cust-02',
        diagnosticSummary: 'Front suspension squeaking sound',
        mileageIn: 32000,
      );

      expect(order.id, isNotEmpty);
      expect(order.status, WorkOrderStatus.pending);
      expect(order.formattedNumber, startsWith('MOL-01-'));

      final queried = await manageWorkOrders.getWorkOrders(branchId: 'b-01');
      expect(queried.length, 2);

      final detail = await manageWorkOrders.getWorkOrderById(order.id);
      expect(detail.mileageIn, 32000);

      final updated = await manageWorkOrders.updateWorkOrderIntake(
        id: order.id,
        diagnosticSummary: 'Updated: Front shocks leaking oil',
        mileageIn: 32050,
      );
      expect(updated.diagnosticSummary, contains('Front shocks'));
      expect(updated.mileageIn, 32050);

      final completed = await manageWorkOrders.completeWorkOrder(order.id);
      expect(completed.status, WorkOrderStatus.completed);

      await manageWorkOrders.deleteWorkOrder(order.id);
      expect(repository.workOrders.any((o) => o.id == order.id), isFalse);
    });
  });

  group('ManageWorkOrderTasks & ManageTaskProducts Use Cases', () {
    test('manages task execution, mechanic assignments, and product stock reservations', () async {
      final manageTasks = ManageWorkOrderTasks(repository: repository);
      final manageProducts = ManageTaskProducts(repository: repository);

      final updatedOrder = await manageTasks.addTask(
        workOrderId: 'wo-01',
        serviceId: 'srv-02',
        assignedMechanicId: 'ereg-02',
        description: 'Complete dynamic 3D alignment',
      );

      expect(updatedOrder.tasks.length, 2);
      final newTask = updatedOrder.tasks.last;
      expect(newTask.description, 'Complete dynamic 3D alignment');

      await manageTasks.assignMechanic(
        taskId: newTask.id,
        mechanicId: 'ereg-03',
      );
      final assignedOrder = repository.workOrders.firstWhere((o) => o.id == 'wo-01');
      expect(
        assignedOrder.tasks.firstWhere((t) => t.id == newTask.id).assignedMechanicId,
        'ereg-03',
      );

      await manageTasks.startTask(newTask.id);
      final startedOrder = repository.workOrders.firstWhere((o) => o.id == 'wo-01');
      expect(
        startedOrder.tasks.firstWhere((t) => t.id == newTask.id).status,
        TaskStatus.doing,
      );

      await manageTasks.completeTask(newTask.id);
      final completedOrder = repository.workOrders.firstWhere((o) => o.id == 'wo-01');
      expect(
        completedOrder.tasks.firstWhere((t) => t.id == newTask.id).status,
        TaskStatus.completed,
      );

      await manageTasks.reopenTask(newTask.id);
      final reopenedOrder = repository.workOrders.firstWhere((o) => o.id == 'wo-01');
      expect(
        reopenedOrder.tasks.firstWhere((t) => t.id == newTask.id).status,
        TaskStatus.doing,
      );

      final withProduct = await manageProducts.addProductToTask(
        taskId: newTask.id,
        productId: 'prod-02',
        quantity: 2,
      );
      final productTask = withProduct.tasks.firstWhere((t) => t.id == newTask.id);
      expect(productTask.products.length, 1);
      expect(productTask.products.first.quantity, 2);

      await manageProducts.updateProductQuantity(
        taskId: newTask.id,
        productId: 'prod-02',
        quantity: 4,
      );
      final updatedProdTask = repository.workOrders
          .firstWhere((o) => o.id == 'wo-01')
          .tasks
          .firstWhere((t) => t.id == newTask.id);
      expect(updatedProdTask.products.first.quantity, 4);

      await manageProducts.removeProductFromTask(
        taskId: newTask.id,
        productId: 'prod-02',
      );
      final removedProdTask = repository.workOrders
          .firstWhere((o) => o.id == 'wo-01')
          .tasks
          .firstWhere((t) => t.id == newTask.id);
      expect(removedProdTask.products.isEmpty, isTrue);

      await manageTasks.deleteTask(workOrderId: 'wo-01', taskId: newTask.id);
      expect(
        repository.workOrders.firstWhere((o) => o.id == 'wo-01').tasks.any((t) => t.id == newTask.id),
        isFalse,
      );
    });
  });

  group('Operations ViewModels Integration', () {
    test('WorkOrdersViewModel loads orders, filters, and refreshes', () async {
      final sessionStorage = FakeSessionStorage();
      final viewModel = WorkOrdersViewModel(
        manageWorkOrders: ManageWorkOrders(repository: repository),
        sessionStorage: sessionStorage,
      );

      await viewModel.init();
      expect(viewModel.orders.length, 1);
      expect(viewModel.activeBranchId, 'b-01');

      await viewModel.setFilter(WorkOrderStatus.completed);
      expect(viewModel.orders.isEmpty, isTrue);

      await viewModel.setFilter(WorkOrderStatus.inProgress);
      expect(viewModel.orders.length, 1);
    });

    test('WorkOrderDetailViewModel loads detail, executes task steps, and completes order', () async {
      final viewModel = WorkOrderDetailViewModel(
        manageWorkOrders: ManageWorkOrders(repository: repository),
        manageWorkOrderTasks: ManageWorkOrderTasks(repository: repository),
        manageTaskProducts: ManageTaskProducts(repository: repository),
      );

      await viewModel.loadOrder('wo-01');
      expect(viewModel.order?.formattedNumber, 'MOL-01-000001');

      final taskStarted = await viewModel.startTask('task-01');
      expect(taskStarted, isTrue);

      final productAdded = await viewModel.addProduct(
        taskId: 'task-01',
        productId: 'prod-99',
        productName: 'Brake Fluid DOT 4',
        quantity: 1,
        unitPrice: 30.0,
      );
      expect(productAdded, isTrue);

      final taskCompleted = await viewModel.completeTask('task-01');
      expect(taskCompleted, isTrue);

      final orderCompleted = await viewModel.completeOrder();
      expect(orderCompleted, isTrue);
      expect(viewModel.order?.status, WorkOrderStatus.completed);
    });
  });
}

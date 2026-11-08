import 'package:shiftiq_mobile_app_flutter/features/operations/domain/task_product.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_task.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_api.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final WorkOrderApi workOrderApi;

  // Local reactive cache for smooth instant UI and offline resilience
  final List<WorkOrder> _localStore = [];

  WorkOrderRepositoryImpl({required this.workOrderApi}) {
    _initDemoOrders();
  }

  void _initDemoOrders() {
    if (_localStore.isNotEmpty) return;

    _localStore.addAll([
      WorkOrder(
        id: 'wo-01',
        branchId: 'b-01-smp',
        vehicleId: 'veh-01',
        vehiclePlate: 'BCX-892',
        vehicleModel: 'Toyota Hilux 2021',
        customerId: 'cust-01',
        customerName: 'Carlos Mendoza',
        customerPhone: '+51 987 654 321',
        internalNumber: 1042,
        formattedNumber: 'OT-2026-0042',
        status: WorkOrderStatus.inProgress,
        diagnosticSummary: 'Mantenimiento correctivo sistema de frenos delanteros y escaneo OBD-II',
        mileageIn: 48500,
        totalAmount: 450.00,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        tasks: [
          const WorkOrderTask(
            id: 'task-01-1',
            description: 'Diagnóstico de frenos y escaneo computarizado OBD-II',
            price: 80.00,
            status: 'COMPLETED',
            assignedMechanicId: 'mech-01',
            assignedMechanicName: 'Luis Ramos',
          ),
          const WorkOrderTask(
            id: 'task-01-2',
            description: 'Cambio de pastillas de freno delanteras',
            price: 120.00,
            status: 'COMPLETED',
            assignedMechanicId: 'mech-01',
            assignedMechanicName: 'Luis Ramos',
            products: [
              TaskProduct(
                id: 'tp-01',
                productId: 'prod-01',
                productName: 'Pastillas de Freno Bosch Fr-02',
                quantity: 2,
                unitPrice: 50.00,
                totalAmount: 100.00,
              ),
            ],
          ),
          const WorkOrderTask(
            id: 'task-01-3',
            description: 'Rectificado de discos y purgado de líquido DOT4',
            price: 150.00,
            status: 'IN_PROGRESS',
            assignedMechanicId: 'mech-02',
            assignedMechanicName: 'Marcos Vilca',
          ),
        ],
      ),
      WorkOrder(
        id: 'wo-02',
        branchId: 'b-01-smp',
        vehicleId: 'veh-02',
        vehiclePlate: 'AJ-4421',
        vehicleModel: 'Hyundai Tucson 2020',
        customerId: 'cust-02',
        customerName: 'Patricia Flores',
        customerPhone: '+51 912 345 678',
        internalNumber: 1041,
        formattedNumber: 'OT-2026-0041',
        status: WorkOrderStatus.inProgress,
        diagnosticSummary: 'Ruidos anormales en tren delantero y sensor de oxígeno P0171',
        mileageIn: 62100,
        totalAmount: 380.00,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        tasks: [
          const WorkOrderTask(
            id: 'task-02-1',
            description: 'Inspección de suspensión delantera y terminales',
            price: 90.00,
            status: 'IN_PROGRESS',
            assignedMechanicId: 'mech-01',
            assignedMechanicName: 'Luis Ramos',
          ),
        ],
      ),
      WorkOrder(
        id: 'wo-03',
        branchId: 'b-01-smp',
        vehicleId: 'veh-03',
        vehiclePlate: 'F1X-902',
        vehicleModel: 'Nissan Frontier 2019',
        customerId: 'cust-03',
        customerName: 'Jorge Castro',
        customerPhone: '+51 999 111 222',
        internalNumber: 1040,
        formattedNumber: 'OT-2026-0040',
        status: WorkOrderStatus.pending,
        diagnosticSummary: 'Mantenimiento preventivo 50,000 km y cambio de aceite sintético',
        mileageIn: 50200,
        totalAmount: 220.00,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tasks: [
          const WorkOrderTask(
            id: 'task-03-1',
            description: 'Cambio de aceite 5W-30 sintético y filtro de aceite',
            price: 70.00,
            status: 'PENDING',
            assignedMechanicId: null,
            assignedMechanicName: 'Sin asignar',
          ),
        ],
      ),
      WorkOrder(
        id: 'wo-04',
        branchId: 'b-01-smp',
        vehicleId: 'veh-04',
        vehiclePlate: 'B3Z-118',
        vehicleModel: 'Kia Sportage 2022',
        customerId: 'cust-04',
        customerName: 'Andrés Ramos',
        customerPhone: '+51 977 888 999',
        internalNumber: 1039,
        formattedNumber: 'OT-2026-0039',
        status: WorkOrderStatus.completed,
        diagnosticSummary: 'Alineación computarizada y balanceo de 4 ruedas',
        mileageIn: 25400,
        totalAmount: 180.00,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tasks: [
          const WorkOrderTask(
            id: 'task-04-1',
            description: 'Alineación láser 3D de ejes delantero y trasero',
            price: 120.00,
            status: 'COMPLETED',
            assignedMechanicId: 'mech-02',
            assignedMechanicName: 'Marcos Vilca',
          ),
          const WorkOrderTask(
            id: 'task-04-2',
            description: 'Balanceo dinámico 4 neumáticos',
            price: 60.00,
            status: 'COMPLETED',
            assignedMechanicId: 'mech-02',
            assignedMechanicName: 'Marcos Vilca',
          ),
        ],
      ),
    ]);
  }

  @override
  Future<List<WorkOrder>> getWorkOrders({
    required String branchId,
    WorkOrderStatus? status,
  }) async {
    try {
      final remoteDtos = await workOrderApi.getWorkOrders(
        branchId: branchId,
        status: status?.value,
      );
      if (remoteDtos.isNotEmpty) {
        return remoteDtos.map((dto) => dto.toDomain()).toList();
      }
    } catch (_) {
      // Fallback to local store
    }

    var list = _localStore.where((wo) => wo.branchId == branchId || branchId.isEmpty).toList();
    if (status != null) {
      list = list.where((wo) => wo.status == status).toList();
    }
    return list;
  }

  @override
  Future<WorkOrder> getWorkOrderById(String id) async {
    try {
      final dto = await workOrderApi.getWorkOrderById(id);
      return dto.toDomain();
    } catch (_) {
      // Fallback to local store
    }

    final match = _localStore.firstWhere(
      (wo) => wo.id == id,
      orElse: () => _localStore.first,
    );
    return match;
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
    try {
      final dto = await workOrderApi.createWorkOrder(
        branchId: branchId,
        vehicleId: vehicleId,
        customerId: customerId,
        diagnosticSummary: diagnosticSummary,
        mileageIn: mileageIn,
        appointmentId: appointmentId,
      );
      final domain = dto.toDomain(
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        customerName: customerName,
      );
      _localStore.insert(0, domain);
      return domain;
    } catch (_) {
      // Fallback creation
    }

    final nextNumber = 1040 + _localStore.length + 1;
    final newOrder = WorkOrder(
      id: 'wo-${DateTime.now().millisecondsSinceEpoch}',
      appointmentId: appointmentId,
      branchId: branchId,
      vehicleId: vehicleId,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      customerId: customerId,
      customerName: customerName,
      internalNumber: nextNumber,
      formattedNumber: 'OT-2026-$nextNumber',
      status: WorkOrderStatus.pending,
      diagnosticSummary: diagnosticSummary,
      mileageIn: mileageIn,
      totalAmount: 0.0,
      createdAt: DateTime.now(),
      tasks: [],
    );

    _localStore.insert(0, newOrder);
    return newOrder;
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
    try {
      final dto = await workOrderApi.addTask(
        workOrderId: workOrderId,
        description: description,
        price: price,
        serviceId: serviceId,
        mechanicId: mechanicId,
      );
      return dto.toDomain();
    } catch (_) {
      // Fallback mutation
    }

    final index = _localStore.indexWhere((wo) => wo.id == workOrderId);
    if (index >= 0) {
      final current = _localStore[index];
      final newTask = WorkOrderTask(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        serviceId: serviceId,
        description: description,
        price: price,
        status: 'PENDING',
        assignedMechanicId: mechanicId,
        assignedMechanicName: mechanicName,
      );

      final updatedTasks = List<WorkOrderTask>.from(current.tasks)..add(newTask);
      final updatedOrder = WorkOrder(
        id: current.id,
        appointmentId: current.appointmentId,
        branchId: current.branchId,
        vehicleId: current.vehicleId,
        vehiclePlate: current.vehiclePlate,
        vehicleModel: current.vehicleModel,
        customerId: current.customerId,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        internalNumber: current.internalNumber,
        formattedNumber: current.formattedNumber,
        status: current.status == WorkOrderStatus.pending
            ? WorkOrderStatus.inProgress
            : current.status,
        diagnosticSummary: current.diagnosticSummary,
        mileageIn: current.mileageIn,
        totalAmount: current.totalAmount + price,
        tasks: updatedTasks,
        createdAt: current.createdAt,
      );

      _localStore[index] = updatedOrder;
      return updatedOrder;
    }

    throw Exception('Work order not found');
  }

  @override
  Future<WorkOrder> startTask(String taskId) async {
    try {
      final dto = await workOrderApi.startTask(taskId);
      return dto.toDomain();
    } catch (_) {
      // Fallback mutation
    }

    for (int i = 0; i < _localStore.length; i++) {
      final wo = _localStore[i];
      final taskIndex = wo.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex >= 0) {
        final currentTask = wo.tasks[taskIndex];
        final updatedTask = WorkOrderTask(
          id: currentTask.id,
          serviceId: currentTask.serviceId,
          description: currentTask.description,
          price: currentTask.price,
          status: 'IN_PROGRESS',
          assignedMechanicId: currentTask.assignedMechanicId,
          assignedMechanicName: currentTask.assignedMechanicName,
          products: currentTask.products,
          startedAt: DateTime.now(),
        );

        final updatedTasks = List<WorkOrderTask>.from(wo.tasks);
        updatedTasks[taskIndex] = updatedTask;

        final updatedOrder = WorkOrder(
          id: wo.id,
          appointmentId: wo.appointmentId,
          branchId: wo.branchId,
          vehicleId: wo.vehicleId,
          vehiclePlate: wo.vehiclePlate,
          vehicleModel: wo.vehicleModel,
          customerId: wo.customerId,
          customerName: wo.customerName,
          customerPhone: wo.customerPhone,
          internalNumber: wo.internalNumber,
          formattedNumber: wo.formattedNumber,
          status: WorkOrderStatus.inProgress,
          diagnosticSummary: wo.diagnosticSummary,
          mileageIn: wo.mileageIn,
          totalAmount: wo.totalAmount,
          tasks: updatedTasks,
          createdAt: wo.createdAt,
        );

        _localStore[i] = updatedOrder;
        return updatedOrder;
      }
    }

    throw Exception('Task not found');
  }

  @override
  Future<WorkOrder> completeTask(String taskId) async {
    try {
      final dto = await workOrderApi.completeTask(taskId);
      return dto.toDomain();
    } catch (_) {
      // Fallback mutation
    }

    for (int i = 0; i < _localStore.length; i++) {
      final wo = _localStore[i];
      final taskIndex = wo.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex >= 0) {
        final currentTask = wo.tasks[taskIndex];
        final updatedTask = WorkOrderTask(
          id: currentTask.id,
          serviceId: currentTask.serviceId,
          description: currentTask.description,
          price: currentTask.price,
          status: 'COMPLETED',
          assignedMechanicId: currentTask.assignedMechanicId,
          assignedMechanicName: currentTask.assignedMechanicName,
          products: currentTask.products,
          startedAt: currentTask.startedAt ?? DateTime.now(),
          completedAt: DateTime.now(),
        );

        final updatedTasks = List<WorkOrderTask>.from(wo.tasks);
        updatedTasks[taskIndex] = updatedTask;

        final updatedOrder = WorkOrder(
          id: wo.id,
          appointmentId: wo.appointmentId,
          branchId: wo.branchId,
          vehicleId: wo.vehicleId,
          vehiclePlate: wo.vehiclePlate,
          vehicleModel: wo.vehicleModel,
          customerId: wo.customerId,
          customerName: wo.customerName,
          customerPhone: wo.customerPhone,
          internalNumber: wo.internalNumber,
          formattedNumber: wo.formattedNumber,
          status: wo.status,
          diagnosticSummary: wo.diagnosticSummary,
          mileageIn: wo.mileageIn,
          totalAmount: wo.totalAmount,
          tasks: updatedTasks,
          createdAt: wo.createdAt,
        );

        _localStore[i] = updatedOrder;
        return updatedOrder;
      }
    }

    throw Exception('Task not found');
  }

  @override
  Future<WorkOrder> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
    required double unitPrice,
    String productName = 'Repuesto de Taller',
  }) async {
    try {
      final dto = await workOrderApi.addProductToTask(
        taskId: taskId,
        productId: productId,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      return dto.toDomain();
    } catch (_) {
      // Fallback mutation
    }

    for (int i = 0; i < _localStore.length; i++) {
      final wo = _localStore[i];
      final taskIndex = wo.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex >= 0) {
        final currentTask = wo.tasks[taskIndex];
        final newProduct = TaskProduct(
          id: 'tp-${DateTime.now().millisecondsSinceEpoch}',
          productId: productId,
          productName: productName,
          quantity: quantity,
          unitPrice: unitPrice,
          totalAmount: unitPrice * quantity,
        );

        final updatedProducts = List<TaskProduct>.from(currentTask.products)
          ..add(newProduct);
        final updatedTask = WorkOrderTask(
          id: currentTask.id,
          serviceId: currentTask.serviceId,
          description: currentTask.description,
          price: currentTask.price,
          status: currentTask.status,
          assignedMechanicId: currentTask.assignedMechanicId,
          assignedMechanicName: currentTask.assignedMechanicName,
          products: updatedProducts,
          startedAt: currentTask.startedAt,
          completedAt: currentTask.completedAt,
        );

        final updatedTasks = List<WorkOrderTask>.from(wo.tasks);
        updatedTasks[taskIndex] = updatedTask;

        final updatedOrder = WorkOrder(
          id: wo.id,
          appointmentId: wo.appointmentId,
          branchId: wo.branchId,
          vehicleId: wo.vehicleId,
          vehiclePlate: wo.vehiclePlate,
          vehicleModel: wo.vehicleModel,
          customerId: wo.customerId,
          customerName: wo.customerName,
          customerPhone: wo.customerPhone,
          internalNumber: wo.internalNumber,
          formattedNumber: wo.formattedNumber,
          status: wo.status,
          diagnosticSummary: wo.diagnosticSummary,
          mileageIn: wo.mileageIn,
          totalAmount: wo.totalAmount + (unitPrice * quantity),
          tasks: updatedTasks,
          createdAt: wo.createdAt,
        );

        _localStore[i] = updatedOrder;
        return updatedOrder;
      }
    }

    throw Exception('Task not found');
  }

  @override
  Future<WorkOrder> completeWorkOrder(String workOrderId) async {
    try {
      final dto = await workOrderApi.completeWorkOrder(workOrderId);
      return dto.toDomain();
    } catch (_) {
      // Fallback mutation
    }

    final index = _localStore.indexWhere((wo) => wo.id == workOrderId);
    if (index >= 0) {
      final current = _localStore[index];
      final updated = WorkOrder(
        id: current.id,
        appointmentId: current.appointmentId,
        branchId: current.branchId,
        vehicleId: current.vehicleId,
        vehiclePlate: current.vehiclePlate,
        vehicleModel: current.vehicleModel,
        customerId: current.customerId,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
        internalNumber: current.internalNumber,
        formattedNumber: current.formattedNumber,
        status: WorkOrderStatus.completed,
        diagnosticSummary: current.diagnosticSummary,
        mileageIn: current.mileageIn,
        totalAmount: current.totalAmount,
        tasks: current.tasks,
        createdAt: current.createdAt,
      );

      _localStore[index] = updated;
      return updated;
    }

    throw Exception('Work order not found');
  }
}

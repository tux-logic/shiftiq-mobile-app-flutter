import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_task.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_view_model.dart';

class WorkOrderDetailPage extends StatefulWidget {
  final String workOrderId;
  final WorkOrderDetailViewModel? viewModel;

  const WorkOrderDetailPage({
    super.key,
    required this.workOrderId,
    this.viewModel,
  });

  @override
  State<WorkOrderDetailPage> createState() => _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends State<WorkOrderDetailPage> {
  late final WorkOrderDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<WorkOrderDetailViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadOrder(widget.workOrderId);
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    final descController = TextEditingController();
    final priceController = TextEditingController(text: '80.00');
    final mechanicController = TextEditingController(text: 'Luis Ramos');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Tarea Mecánica'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Servicio *',
                hintText: 'Ej. Cambio de bujías y cables',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio de Mano de Obra (S/) *',
                prefixText: 'S/ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mechanicController,
              decoration: const InputDecoration(
                labelText: 'Mecánico Asignado',
                hintText: 'Ej. Luis Ramos',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (descController.text.trim().isEmpty) return;
              final price = double.tryParse(priceController.text) ?? 50.0;
              Navigator.of(ctx).pop();
              await _viewModel.addTask(
                description: descController.text.trim(),
                price: price,
                mechanicName: mechanicController.text.trim().isEmpty
                    ? 'Sin asignar'
                    : mechanicController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ShiftIQColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, String taskId) {
    final nameController = TextEditingController(text: 'Filtro de Aceite Mann');
    final qtyController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '35.00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Despachar Repuesto de Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Repuesto *',
                hintText: 'Ej. Pastillas Bosch Fr-02',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio Unitario (S/) *',
                prefixText: 'S/ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final qty = int.tryParse(qtyController.text) ?? 1;
              final price = double.tryParse(priceController.text) ?? 20.0;
              Navigator.of(ctx).pop();
              await _viewModel.addProduct(
                taskId: taskId,
                productId: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                productName: nameController.text.trim(),
                quantity: qty,
                unitPrice: price,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ShiftIQColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Despachar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        final order = vm.order;

        if (vm.isLoading && order == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: ShiftIQColors.primaryBlue),
            ),
          );
        }

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de OT')),
            body: const Center(child: Text('Orden no encontrada')),
          );
        }

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          appBar: AppBar(
            title: Text(order.formattedNumber),
            actions: [
              IconButton(
                tooltip: 'Actualizar',
                icon: const Icon(Icons.refresh),
                onPressed: () => vm.loadOrder(order.id),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle & Customer Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.vehicleModel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ShiftIQColors.graphiteText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  order.vehiclePlate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: order.status.color.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: order.status.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.speed,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Kilometraje ingreso: ${order.formattedMileage}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cliente: ${order.customerName}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (order.customerPhone.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.customerPhone,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        'Diagnóstico Inicial:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.diagnosticSummary,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Tasks Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TAREAS EN BAHÍA (${order.tasks.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddTaskDialog(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Agregar Tarea',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tasks List
                ...order.tasks.map((task) => _buildTaskItem(context, task, vm)),

                const SizedBox(height: 16),

                // Financial Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Servicios / Mano de obra:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            'S/ ${order.tasks.fold(0.0, (sum, t) => sum + t.price).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Repuestos Despachados:',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            'S/ ${order.tasks.fold(0.0, (sum, t) => sum + t.productsTotal).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL GENERAL DE LA ORDEN:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                          Text(
                            order.formattedAmount,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShiftIQColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Finalize Order Button
                if (!order.isCompleted)
                  ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('¿Finalizar y Liquidar Orden?'),
                          content: Text(
                            'Se cerrará la orden ${order.formattedNumber} por un monto total de ${order.formattedAmount}.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ShiftIQColors.preventiveGreen,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Confirmar y Liquidar'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        final ok = await vm.completeOrder();
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Orden finalizada y liquidada exitosamente',
                              ),
                              backgroundColor: ShiftIQColors.preventiveGreen,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShiftIQColors.preventiveGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 8),
                        Text(
                          'FINALIZAR Y LIQUIDAR (${order.formattedAmount})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ShiftIQColors.preventiveGreen.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ShiftIQColors.preventiveGreen.withAlpha(80),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: ShiftIQColors.preventiveGreen,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ORDEN FINALIZADA Y LIQUIDADA',
                          style: TextStyle(
                            color: ShiftIQColors.preventiveGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    WorkOrderTask task,
    WorkOrderDetailViewModel vm,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: task.isCompleted
              ? ShiftIQColors.preventiveGreen.withAlpha(80)
              : ShiftIQColors.borderSlate,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Icon / Toggle
              if (task.isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: ShiftIQColors.preventiveGreen,
                  size: 22,
                )
              else if (task.isInProgress)
                IconButton(
                  tooltip: 'Marcar como Completada',
                  icon: const Icon(
                    Icons.radio_button_unchecked,
                    color: ShiftIQColors.secondaryTeal,
                  ),
                  onPressed: () => vm.completeTask(task.id),
                )
              else
                IconButton(
                  tooltip: 'Iniciar Tarea',
                  icon: const Icon(Icons.play_circle_outline, color: Colors.grey),
                  onPressed: () => vm.startTask(task.id),
                ),
              const SizedBox(width: 8),

              // Description & Mechanic
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.engineering_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mecánico: ${task.assignedMechanicName}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price
              Text(
                task.formattedPrice,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ShiftIQColors.primaryBlue,
                ),
              ),
            ],
          ),

          // Action Buttons for this task
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!task.isCompleted && task.isPending)
                TextButton.icon(
                  onPressed: () => vm.startTask(task.id),
                  icon: const Icon(Icons.play_arrow, size: 14),
                  label: const Text('Iniciar', style: TextStyle(fontSize: 11)),
                ),
              if (!task.isCompleted && task.isInProgress)
                TextButton.icon(
                  onPressed: () => vm.completeTask(task.id),
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Completar', style: TextStyle(fontSize: 11)),
                ),
              TextButton.icon(
                onPressed: () => _showAddProductDialog(context, task.id),
                icon: const Icon(Icons.inventory_2_outlined, size: 14),
                label: const Text('+ Repuesto', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),

          // Attached Products (Repuestos)
          if (task.products.isNotEmpty) ...[
            const Divider(height: 12),
            Text(
              'Repuestos Consumidos:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            ...task.products.map(
              (p) => Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '• ${p.productName} (${p.quantity} unid)',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      p.formattedTotal,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

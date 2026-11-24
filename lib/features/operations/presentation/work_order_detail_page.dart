import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_photo_gallery_viewer.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/spare_part_picker_sheet.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/task_detail_sheet.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/work_order_task_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/billing_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/views/checkout_voucher_page.dart';

class WorkOrderDetailPage extends StatefulWidget {
  final String workOrderId;
  final WorkOrderDetailViewModel? viewModel;
  final bool readOnly;

  const WorkOrderDetailPage({
    super.key,
    required this.workOrderId,
    this.viewModel,
    this.readOnly = false,
  });

  @override
  State<WorkOrderDetailPage> createState() => _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends State<WorkOrderDetailPage> {
  late final WorkOrderDetailViewModel _viewModel;

  bool get _isCustomer {
    if (widget.readOnly) return true;
    if (!getIt.isRegistered<SessionStorage>()) return false;
    return RoleRouter.resolveScope(getIt<SessionStorage>().roles) ==
        MobileRoleScope.customer;
  }

  bool get _isOwnerAdmin {
    if (_isCustomer) return false;
    if (!getIt.isRegistered<SessionStorage>()) return false;
    return RoleRouter.resolveScope(getIt<SessionStorage>().roles) ==
        MobileRoleScope.ownerAdmin;
  }

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<WorkOrderDetailViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadOrder(widget.workOrderId);
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final mechanicController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('add_task')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: loc.translate('task_description_required'),
                hintText: loc.translate('task_description_hint'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: loc.translate('labor_price_required'),
                prefixText: 'S/ ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mechanicController,
              decoration: InputDecoration(
                labelText: loc.translate('assigned_mechanic'),
                hintText: loc.translate('mechanic_name_hint'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.translate('cancel')),
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
            child: Text(loc.translate('add')),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProductSheet(
    BuildContext context,
    WorkOrderTask task,
  ) async {
    final attachedIds = task.products.map((p) => p.productId).toSet();
    final dispatched = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SparePartPickerSheet(
        loadProducts: _viewModel.loadBranchProducts,
        attachedProductIds: attachedIds,
        onDispatch: (product, quantity) async {
          final ok = await _viewModel.addProduct(
            taskId: task.id,
            productId: product.id,
            productName: product.name,
            quantity: quantity,
            unitPrice: product.salePrice,
          );
          if (ok) return null;
          return _viewModel.error ?? 'No se pudo agregar el repuesto.';
        },
      ),
    );
    if (dispatched == true && context.mounted) {
      ShiftIQToast.show(
        context,
        message: 'Repuesto agregado a la tarea correctamente.',
        type: ShiftIQToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        final order = vm.order;
        final loc = AppLocalizations.of(context);

        if (vm.isLoading && order == null) {
          return Scaffold(
            backgroundColor: ShiftIQColors.warmNeutral,
            body: Column(
              children: [
                ShiftIQPageHeader(
                  title: loc.translate('work_order_detail'),
                  showBackButton: true,
                ),
                const Expanded(child: ShiftIQSkeletonDetail()),
              ],
            ),
          );
        }

        if (order == null) {
          return Scaffold(
            backgroundColor: ShiftIQColors.warmNeutral,
            body: Column(
              children: [
                ShiftIQPageHeader(
                  title: loc.translate('work_order_detail'),
                  showBackButton: true,
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ShiftIQEmptyStateIcon(),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate('work_order_not_found'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          body: ShiftIQCollapsibleHeaderBody(
            header: ShiftIQPageHeader(
              title: order.formattedNumber,
              subtitle: '${order.vehicleModel} · ${order.vehiclePlate}',
              showBackButton: true,
            ),
            body: ShiftIQPullToRefresh(
                  onRefresh: () => vm.loadOrder(order.id),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                      if (order.entryInspectionImages.isNotEmpty) ...[
                        const Divider(height: 16),
                        Text(
                          'Fotos de recepción (${order.entryInspectionImages.length}):',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 82,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: order.entryInspectionImages.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              final url = order.entryInspectionImages[index];
                              return GestureDetector(
                                onTap: () => ShiftIQPhotoGalleryViewer.open(
                                  context,
                                  imageUrls: order.entryInspectionImages,
                                  initialIndex: index,
                                  title: 'Recepción',
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    url,
                                    width: 82,
                                    height: 82,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 82,
                                      height: 82,
                                      color: ShiftIQColors.warmNeutral,
                                      child: const Icon(
                                        Icons.broken_image_outlined,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
                    if (_isOwnerAdmin && !order.isCompleted)
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
                            'S/ ${order.tasks.fold(0.0, (sum, t) => sum + t.laborPrice).toStringAsFixed(2)}',
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

                // Finalize Order Button (owner/admin settlement only)
                if (!order.isCompleted && !order.isPaid && _isOwnerAdmin)
                  ElevatedButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(loc.translate('finalize_order_dialog_title')),
                          content: Text(
                            'Se cerrará la orden ${order.formattedNumber} por un monto total de ${order.formattedAmount}.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(loc.translate('cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(loc.translate('confirm_and_settle')),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await vm.completeOrder();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
                else if (order.isCompleted || order.isPaid) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (order.isPaid
                              ? ShiftIQColors.primaryBlue
                              : ShiftIQColors.preventiveGreen)
                          .withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (order.isPaid
                                ? ShiftIQColors.primaryBlue
                                : ShiftIQColors.preventiveGreen)
                            .withAlpha(80),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: order.isPaid
                              ? ShiftIQColors.primaryBlue
                              : ShiftIQColors.preventiveGreen,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            order.isPaid
                                ? 'ORDEN PAGADA'
                                : 'ORDEN COMPLETADA · PENDIENTE DE PAGO',
                            style: TextStyle(
                              color: order.isPaid
                                  ? ShiftIQColors.primaryBlue
                                  : ShiftIQColors.preventiveGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isOwnerAdmin && !order.isPaid) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final items = <VoucherItem>[];
                        for (final task in order.tasks) {
                          items.add(
                            VoucherItem.create(
                              id: 'svc-${task.id}',
                              description: task.description,
                              itemType: VoucherItemType.service,
                              quantity: 1,
                              unitPrice: task.laborPrice,
                            ),
                          );
                          for (final p in task.products) {
                            items.add(
                              VoucherItem.create(
                                id: 'sp-${p.id}',
                                description: p.productName,
                                itemType: VoucherItemType.sparePart,
                                quantity: p.quantity,
                                unitPrice: p.unitPrice,
                              ),
                            );
                          }
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutVoucherPage(
                              branchId: order.branchId,
                              workOrderId: order.id,
                              initialCustomerName: order.customerName,
                              initialPlate: order.vehiclePlate,
                              initialItems: items.isNotEmpty ? items : null,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: Text(loc.translate('emit_voucher_btn')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShiftIQColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 20),
              ],
            ),
                  ),
                ),
          ),
        );
      },
    );
  }

  WorkOrderTask _displayTask(WorkOrderTask task) {
    if (_isCustomer &&
        task.assignedMechanicName == 'Sin asignar' &&
        task.assignedMechanicId.isNotEmpty &&
        task.assignedMechanicId != 'ereg-unassigned') {
      return task.copyWith(assignedMechanicName: 'Mecánico asignado');
    }
    return task;
  }

  void _showTaskDetailSheet(
    BuildContext context,
    WorkOrderTask task,
    WorkOrderDetailViewModel vm,
  ) {
    final displayTask = _displayTask(task);
    final orderCompleted = vm.order?.isCompleted ?? false;
    final canExecute = !_isCustomer && (_isOwnerAdmin || vm.canExecuteTask(task));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TaskDetailSheet(
        task: displayTask,
        onAddProduct: canExecute && !task.isCompleted && !orderCompleted
            ? () => _showAddProductSheet(context, task)
            : null,
        onStartTask:
            canExecute && task.isPending ? () => vm.startTask(task.id) : null,
        onCompleteTask: canExecute && task.isInProgress
            ? () => vm.completeTask(task.id)
            : null,
        onUpdateProductQuantity: canExecute && !task.isCompleted && !orderCompleted
            ? (productId, newQuantity) async {
                final ok = await vm.updateProductQuantity(
                  taskId: task.id,
                  productId: productId,
                  quantity: newQuantity,
                );
                if (!ok) {
                  throw Exception(
                    vm.error ?? 'No se pudo actualizar la cantidad.',
                  );
                }
                return vm.order?.tasks.firstWhere(
                  (t) => t.id == task.id,
                  orElse: () => task,
                );
              }
            : null,
        onRemoveProduct: canExecute && !task.isCompleted && !orderCompleted
            ? (productId) async {
                final ok = await vm.removeProductFromTask(
                  taskId: task.id,
                  productId: productId,
                );
                if (!ok) {
                  throw Exception(
                    vm.error ?? 'No se pudo quitar el repuesto.',
                  );
                }
                return vm.order?.tasks.firstWhere(
                  (t) => t.id == task.id,
                  orElse: () => task,
                );
              }
            : null,
        onAddEvidenceImage: canExecute && !task.isCompleted && !orderCompleted
            ? (bytes, fileName) async {
                final updated = await vm.uploadAndAttachEvidence(
                  task: task,
                  fileBytes: bytes,
                  fileName: fileName,
                );
                if (updated == null) {
                  throw Exception(
                    vm.error ?? 'No se pudo subir la foto de evidencia.',
                  );
                }
                return updated;
              }
            : null,
        onRemoveEvidenceImage: canExecute && !task.isCompleted && !orderCompleted
            ? (imageUrl) async {
                final updated = await vm.removeEvidenceImage(
                  task: task,
                  imageUrl: imageUrl,
                );
                if (updated == null) {
                  throw Exception(
                    vm.error ?? 'No se pudo quitar la foto de evidencia.',
                  );
                }
                return updated;
              }
            : null,
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    WorkOrderTask task,
    WorkOrderDetailViewModel vm,
  ) {
    final displayTask = _displayTask(task);
    final canExecute = !_isCustomer && (_isOwnerAdmin || vm.canExecuteTask(task));
    return WorkOrderTaskCard(
      task: displayTask,
      canExecute: canExecute,
      onTap: () => _showTaskDetailSheet(context, displayTask, vm),
      onStart: () => vm.startTask(task.id),
      onComplete: () => vm.completeTask(task.id),
    );
  }
}

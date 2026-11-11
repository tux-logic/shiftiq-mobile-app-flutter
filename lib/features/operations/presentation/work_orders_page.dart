import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/create_work_order_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/work_order_card.dart';

class WorkOrdersPage extends StatefulWidget {
  final WorkOrdersViewModel? viewModel;

  const WorkOrdersPage({super.key, this.viewModel});

  @override
  State<WorkOrdersPage> createState() => _WorkOrdersPageState();
}

class _WorkOrdersPageState extends State<WorkOrdersPage> {
  late final WorkOrdersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<WorkOrdersViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Órdenes de Trabajo (OTs)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bahías Operativas · ${vm.activeBranchName}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Refrescar OTs',
                icon: const Icon(Icons.refresh),
                onPressed: vm.isLoading ? null : vm.refresh,
              ),
            ],
          ),
          body: Column(
            children: [
              // Filter Chips Row
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todas', null, vm),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'En Progreso',
                        WorkOrderStatus.inProgress,
                        vm,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Pendientes',
                        WorkOrderStatus.pending,
                        vm,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Completadas',
                        WorkOrderStatus.completed,
                        vm,
                      ),
                    ],
                  ),
                ),
              ),

              // Content List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: vm.refresh,
                  color: ShiftIQColors.primaryBlue,
                  child: vm.isLoading && vm.orders.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ShiftIQColors.primaryBlue,
                          ),
                        )
                      : vm.orders.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.all(24),
                              children: [
                                const SizedBox(height: 60),
                                const Icon(
                                  Icons.assignment_outlined,
                                  size: 64,
                                  color: ShiftIQColors.borderSlate,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No hay órdenes en esta categoría',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Puedes registrar una nueva orden presionando el botón inferior "+ Nueva OT".',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: vm.orders.length,
                              itemBuilder: (context, index) {
                                final order = vm.orders[index];
                                return WorkOrderCard(
                                  workOrder: order,
                                  onTap: () async {
                                    final updated =
                                        await Navigator.of(context).push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => WorkOrderDetailPage(
                                          workOrderId: order.id,
                                        ),
                                      ),
                                    );
                                    if (updated == true) {
                                      vm.loadOrders();
                                    }
                                  },
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_work_orders',
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => CreateWorkOrderPage(
                    branchId: vm.activeBranchId,
                  ),
                ),
              );
              if (created == true) {
                vm.loadOrders();
              }
            },
            backgroundColor: ShiftIQColors.primaryBlue,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Nueva OT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    WorkOrderStatus? status,
    WorkOrdersViewModel vm,
  ) {
    final isSelected = vm.statusFilter == status;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.setFilter(status),
      selectedColor: ShiftIQColors.primaryBlue.withAlpha(30),
      backgroundColor: ShiftIQColors.warmNeutral,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? ShiftIQColors.primaryBlue : Colors.grey[700],
      ),
      side: BorderSide(
        color: isSelected
            ? ShiftIQColors.primaryBlue
            : const Color(0xFFCBD5E1),
      ),
    );
  }
}


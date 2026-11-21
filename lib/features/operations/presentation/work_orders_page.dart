import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
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

class _WorkOrdersPageState extends State<WorkOrdersPage>
    with SingleTickerProviderStateMixin {
  static const List<WorkOrderStatus?> _tabStatuses = [
    null,
    WorkOrderStatus.inProgress,
    WorkOrderStatus.pending,
    WorkOrderStatus.completed,
  ];

  late final WorkOrdersViewModel _viewModel;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<WorkOrdersViewModel>();
    _tabController = TabController(length: _tabStatuses.length, vsync: this);
    _tabController.addListener(_handleTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    _viewModel.setFilter(_tabStatuses[_tabController.index]);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openCreateWorkOrder(WorkOrdersViewModel vm) async {
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
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          body: Column(
            children: [
              ShiftIQPageHeader(
                title: 'Órdenes de Trabajo',
                subtitle: vm.activeBranchName,
                actions: [
                  ShiftIQLiquidIconButton(
                    key: const Key('work_orders_profile_button'),
                    tooltip:
                        AppLocalizations.of(context).translate('tooltip_profile'),
                    icon: Icons.person_outline_rounded,
                    onDarkBackground: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Minimalist underline TabBar for Kanban columns
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                  indicatorColor: ShiftIQColors.primaryBlue,
                  indicatorWeight: 2.5,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: ShiftIQColors.borderSlate.withValues(alpha: 0.6),
                  labelColor: ShiftIQColors.primaryBlue,
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    _buildTab('Todas', vm.ordersForStatus(null).length),
                    _buildTab(
                      'En Progreso',
                      vm.ordersForStatus(WorkOrderStatus.inProgress).length,
                    ),
                    _buildTab(
                      'Pendientes',
                      vm.ordersForStatus(WorkOrderStatus.pending).length,
                    ),
                    _buildTab(
                      'Completadas',
                      vm.ordersForStatus(WorkOrderStatus.completed).length,
                    ),
                  ],
                ),
              ),

              // Swipeable Kanban TabBarView
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabStatuses
                      .map((status) => _buildOrdersTab(vm, status))
                      .toList(),
                ),
              ),
            ],
          ),
          floatingActionButton: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (_viewModel.ordersForStatus(_viewModel.statusFilter).isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 84),
                child: ShiftIQPrimaryPillButton(
                  label: 'Nueva OT',
                  icon: Icons.add_rounded,
                  onPressed: () => _openCreateWorkOrder(vm),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Tab _buildTab(String label, int count) {
    return Tab(
      height: 44,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdersTab(WorkOrdersViewModel vm, WorkOrderStatus? status) {
    final orders = vm.ordersForStatus(status);

    return ShiftIQPullToRefresh(
      onRefresh: vm.refresh,
      skeleton: const ShiftIQSkeletonCardList(),
      child: ShiftIQContentTransition(
        child: vm.isLoading && orders.isEmpty
            ? const ShiftIQSkeletonCardList(key: ValueKey('orders_loading'))
            : orders.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 116),
                  children: [
                    const SizedBox(height: 56),
                    const Center(
                      child: ShiftIQEmptyStateIcon(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay órdenes en esta categoría',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Registra una nueva orden para comenzar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ShiftIQPrimaryPillButton(
                        label: 'Nueva OT',
                        icon: Icons.add_rounded,
                        onPressed: () => _openCreateWorkOrder(vm),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 116),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return WorkOrderCard(
                      workOrder: order,
                      onTap: () async {
                        final updated = await Navigator.of(context).push<bool>(
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/presentation/branch_selection_view_model.dart';

class BranchSelectionPage extends StatefulWidget {
  const BranchSelectionPage({super.key});

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  late final BranchSelectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<BranchSelectionViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadBranches();
    });
  }

  void _onBranchSelected(Branch branch) async {
    final success = await _viewModel.selectBranch(branch);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sede seleccionada: ${branch.name}'),
          backgroundColor: ShiftIQColors.preventiveGreen,
        ),
      );
      // In Hito 1, show confirmation screen or direct entry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      appBar: AppBar(
        title: const Text('Seleccionar Sede'),
        backgroundColor: ShiftIQColors.primaryBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final vm = _viewModel;

            if (vm.isLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: ShiftIQColors.primaryBlue),
                    SizedBox(height: 16),
                    Text(
                      'Cargando sedes del taller...',
                      style: TextStyle(
                        fontSize: 14,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (vm.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        color: ShiftIQColors.severityCrimson,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        vm.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: vm.loadBranches,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShiftIQColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (vm.branches.isEmpty) {
              return RefreshIndicator(
                onRefresh: vm.loadBranches,
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    const SizedBox(height: 60),
                    const Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: ShiftIQColors.borderSlate,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No se encontraron sedes activas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifique el registro de su taller en el portal administrativo o contacte a soporte.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: vm.loadBranches,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: vm.loadBranches,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: vm.branches.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Puntos de Atención Disponibles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selecciona la sede operativa para gestionar órdenes, citas e inventario:',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final branch = vm.branches[index - 1];
                  final isCurrent = vm.selectedBranch?.id == branch.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrent
                            ? ShiftIQColors.primaryBlue
                            : ShiftIQColors.borderSlate,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ShiftIQColors.primaryBlue.withAlpha(
                                    20,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: ShiftIQColors.primaryBlue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  branch.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: branch.active
                                      ? ShiftIQColors.preventiveGreen.withAlpha(
                                          25,
                                        )
                                      : ShiftIQColors.severityCrimson.withAlpha(
                                          25,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  branch.active ? 'ACTIVA' : 'INACTIVA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: branch.active
                                        ? ShiftIQColors.preventiveGreen
                                        : ShiftIQColors.severityCrimson,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  branch.address,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _onBranchSelected(branch),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ShiftIQColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('INGRESAR A ESTA SEDE'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

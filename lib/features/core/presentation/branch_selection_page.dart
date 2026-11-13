import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/main/presentation/main_page.dart';

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
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.translate('branch_selected')}: ${branch.name}'),
          backgroundColor: ShiftIQColors.preventiveGreen,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    }
  }

  void _showCreateBranchModal(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registrar Nueva Sede',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: loc.translate('branch_name'),
                  hintText: loc.translate('branch_name_hint'),
                  prefixIcon: const Icon(Icons.store),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: loc.translate('branch_code'),
                  hintText: loc.translate('branch_code_hint'),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: loc.translate('branch_address'),
                  hintText: loc.translate('branch_address_hint'),
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: loc.translate('branch_phone'),
                  hintText: loc.translate('branch_phone_hint'),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  final success = await _viewModel.createBranch(
                    workshopId: _viewModel.branches.isNotEmpty
                        ? _viewModel.branches.first.workshopId
                        : '99abb52d-523e-47dc-a53d-e442899aca4b',
                    code: codeController.text.trim().toUpperCase(),
                    name: nameController.text.trim(),
                    address: addressController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
                  if (success && mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(loc.translate('branch_created_success')),
                        backgroundColor: ShiftIQColors.preventiveGreen,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShiftIQColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(loc.translate('save_branch_backend')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      appBar: AppBar(
        title: Text(loc.translate('select_branch')),
        backgroundColor: ShiftIQColors.primaryBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            key: const Key('btn_profile'),
            icon: const Icon(Icons.person_outline),
            tooltip: loc.translate('tooltip_profile'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: (getIt<SessionStorage>().roles.contains('ROLE_OWNER') ||
              getIt<SessionStorage>().roles.contains('OWNER'))
          ? FloatingActionButton(
              key: const Key('btn_add_branch'),
              heroTag: 'fab_add_branch',
              tooltip: AppLocalizations.of(context).translate('tooltip_create_branch'),
              onPressed: () => _showCreateBranchModal(context),
              backgroundColor: ShiftIQColors.primaryBlue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
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
                        label: Text(loc.translate('retry')),
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
                      label: Text(loc.translate('refresh')),
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
                    key: Key('branch_card_${branch.code}'),
                    margin: const EdgeInsets.only(bottom: 14),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrent
                            ? ShiftIQColors.primaryBlue
                            : ShiftIQColors.borderSlate,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _onBranchSelected(branch),
                      borderRadius: BorderRadius.circular(12),
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
                                    color: ShiftIQColors.primaryBlue.withAlpha(20),
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
                                        ? ShiftIQColors.preventiveGreen.withAlpha(25)
                                        : ShiftIQColors.severityCrimson.withAlpha(25),
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
                            const SizedBox(height: 10),
                            // Workshop & Creator attribution badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ShiftIQColors.primaryBlue.withAlpha(12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.business_center_outlined,
                                    size: 14,
                                    color: ShiftIQColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'Taller: Wagner Motors · Creado por Dueño (Owner)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: ShiftIQColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Cód: ${branch.code}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: ShiftIQColors.graphiteText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
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
                              key: Key('btn_enter_branch_${branch.code}'),
                              onPressed: () => _onBranchSelected(branch),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ShiftIQColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(loc.translate('enter_this_branch')),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
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

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/main/presentation/main_page.dart';

/// Modern multi-branch selector for workshop staff and owners/admins.
class BranchSelectionPage extends StatefulWidget {
  final BranchSelectionViewModel? viewModel;

  const BranchSelectionPage({super.key, this.viewModel});

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  late final BranchSelectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<BranchSelectionViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadBranches();
    });
  }

  MobileRoleScope get _roleScope {
    if (getIt.isRegistered<SessionStorage>()) {
      return RoleRouter.resolveScope(getIt<SessionStorage>().roles);
    }
    return MobileRoleScope.employee;
  }

  Future<void> _onBranchSelected(Branch branch) async {
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

  void _showCreateBranchModal(BuildContext context, String workshopId) {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.translate('register_new_branch'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: authInputDecoration(
                    hintText: loc.translate('branch_name_hint'),
                    prefixIcon: Icons.store_outlined,
                  ).copyWith(labelText: loc.translate('branch_name')),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Branch name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: authInputDecoration(
                    hintText: loc.translate('branch_code_hint'),
                    prefixIcon: Icons.qr_code_rounded,
                  ).copyWith(labelText: loc.translate('branch_code')),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Branch code is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: authInputDecoration(
                    hintText: loc.translate('branch_address_hint'),
                    prefixIcon: Icons.location_on_outlined,
                  ).copyWith(labelText: loc.translate('branch_address')),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Address is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: authInputDecoration(
                    hintText: loc.translate('branch_phone_hint'),
                    prefixIcon: Icons.phone_outlined,
                  ).copyWith(labelText: loc.translate('branch_phone')),
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  label: loc.translate('new_branch'),
                  isLoading: false,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(ctx);
                    final success = await _viewModel.createBranch(
                      workshopId: workshopId,
                      code: codeController.text.trim().toUpperCase(),
                      name: nameController.text.trim(),
                      address: addressController.text.trim(),
                      phone: phoneController.text.trim(),
                    );
                    if (success && mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(loc.translate('save')),
                          backgroundColor: ShiftIQColors.preventiveGreen,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isOwnerAdmin = _roleScope == MobileRoleScope.ownerAdmin;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        final canCreateBranch = isOwnerAdmin && vm.branches.isNotEmpty;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          floatingActionButton: canCreateBranch
              ? FloatingActionButton.extended(
                  key: const Key('btn_add_branch'),
                  heroTag: 'fab_add_branch',
                  onPressed: () => _showCreateBranchModal(
                    context,
                    vm.branches.first.workshopId,
                  ),
                  backgroundColor: ShiftIQColors.primaryBlue,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    loc.translate('new_branch'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              : null,
          body: Column(
            children: [
              // Modern dark-navy header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(22),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withAlpha(45),
                                ),
                              ),
                              child: Text(
                                isOwnerAdmin
                                    ? 'OWNER / ADMIN'
                                    : 'WORKSHOP STAFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            IconButton(
                              key: const Key('btn_profile'),
                              tooltip: loc.translate('tooltip_profile'),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProfilePage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withAlpha(22),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          loc.translate('select_branch'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isOwnerAdmin
                              ? 'Manage operations and analytics across your branches.'
                              : 'Select your assigned branch to start your shift.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Body content
              Expanded(
                child: _buildBody(context, vm, loc),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    BranchSelectionViewModel vm,
    AppLocalizations loc,
  ) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ShiftIQColors.primaryBlue),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: ShiftIQColors.severityCrimson,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: vm.loadBranches,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(loc.translate('retry')),
                style: FilledButton.styleFrom(
                  backgroundColor: ShiftIQColors.primaryBlue,
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
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 48),
            const Icon(
              Icons.storefront_outlined,
              size: 64,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              'No active branches found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ShiftIQColors.graphiteText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Verify your branch assignment or pull down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: vm.loadBranches,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(loc.translate('refresh')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.loadBranches,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
        itemCount: vm.branches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final branch = vm.branches[index];
          final isCurrent = vm.selectedBranch?.id == branch.id;

          return Material(
            key: Key('branch_card_${branch.code}'),
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () => _onBranchSelected(branch),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isCurrent
                        ? ShiftIQColors.primaryBlue
                        : const Color(0xFFE2E8F0),
                    width: isCurrent ? 1.8 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ShiftIQColors.primaryBlue.withAlpha(18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.store_mall_directory_outlined,
                            color: ShiftIQColors.primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ShiftIQColors.graphiteText,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                branch.code,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: branch.active
                                ? ShiftIQColors.preventiveGreen.withAlpha(24)
                                : ShiftIQColors.severityCrimson.withAlpha(24),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            branch.active ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: branch.active
                                  ? ShiftIQColors.preventiveGreen
                                  : ShiftIQColors.severityCrimson,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
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
                    if (branch.phone != null && branch.phone!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            branch.phone!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton.icon(
                        key: Key('btn_enter_branch_${branch.code}'),
                        onPressed: () => _onBranchSelected(branch),
                        style: FilledButton.styleFrom(
                          backgroundColor: ShiftIQColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(
                          loc.translate('enter_this_branch'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
  }
}

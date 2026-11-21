import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/branch_cover_picker.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/branch_list_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/branch_location_picker.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/branch_map_view.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/main/presentation/main_page.dart';

/// Multi-branch selector preserving the ShiftIQ navy-blue palette with
/// animated map pins and a list/map toggle.
class BranchSelectionPage extends StatefulWidget {
  final BranchSelectionViewModel? viewModel;

  const BranchSelectionPage({super.key, this.viewModel});

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  late final BranchSelectionViewModel _viewModel;
  bool _showMap = true;

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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainPage()),
        (route) => false,
      );
    }
  }

  void _showBranchFormModal(
    BuildContext context, {
    required String workshopId,
    Branch? existingBranch,
  }) {
    final loc = AppLocalizations.of(context);
    final isEditing = existingBranch != null;
    final codeController = TextEditingController(
      text: existingBranch?.code ?? '',
    );
    final nameController = TextEditingController(
      text: existingBranch?.name ?? '',
    );
    final addressController = TextEditingController(
      text: existingBranch?.address ?? '',
    );
    final phoneController = TextEditingController(
      text: existingBranch?.phone ?? '',
    );
    final formKey = GlobalKey<FormState>();
    String? coverImageUrl = existingBranch?.coverImageUrl;
    LatLng? pickedCoordinates =
        existingBranch != null && existingBranch.hasCoordinates
            ? LatLng(existingBranch.latitude!, existingBranch.longitude!)
            : null;

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
                      isEditing
                          ? 'Edit Branch'
                          : loc.translate('register_new_branch'),
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
                const SizedBox(height: 14),
                BranchCoverPicker(
                  initialImageUrl: coverImageUrl,
                  onUploadImage: (bytes, fileName) =>
                      _viewModel.uploadBranchCoverImage(
                    fileBytes: bytes,
                    fileName: fileName,
                  ),
                  onImageChanged: (url) => coverImageUrl = url,
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                BranchLocationPicker(
                  initialLatitude: pickedCoordinates?.latitude,
                  initialLongitude: pickedCoordinates?.longitude,
                  onLocationPicked: (point) => pickedCoordinates = point,
                  onAddressResolved: (resolved) {
                    if (addressController.text.trim().isEmpty) {
                      addressController.text = resolved;
                    }
                  },
                ),
                const SizedBox(height: 20),
                ShiftIQLiquidButton(
                  label: isEditing
                      ? loc.translate('save')
                      : loc.translate('new_branch'),
                  expand: true,
                  height: 48,
                  borderRadius: 14,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    if (isEditing) {
                      await _viewModel.updateBranch(
                        branchId: existingBranch.id,
                        code: codeController.text.trim().toUpperCase(),
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        phone: phoneController.text.trim(),
                        coverImageUrl: coverImageUrl,
                        latitude: pickedCoordinates?.latitude,
                        longitude: pickedCoordinates?.longitude,
                      );
                    } else {
                      await _viewModel.createBranch(
                        workshopId: workshopId,
                        code: codeController.text.trim().toUpperCase(),
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        phone: phoneController.text.trim(),
                        coverImageUrl: coverImageUrl,
                        latitude: pickedCoordinates?.latitude,
                        longitude: pickedCoordinates?.longitude,
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
          floatingActionButton: !_showMap && canCreateBranch
              ? ShiftIQLiquidButton(
                  key: const Key('btn_add_branch'),
                  icon: Icons.add_rounded,
                  label: loc.translate('new_branch'),
                  height: 46,
                  borderRadius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  onPressed: () => _showBranchFormModal(
                    context,
                    workshopId: vm.branches.first.workshopId,
                  ),
                )
              : null,
          body: Column(
            children: [
              // Signature ShiftIQ compact dark-navy gradient header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 14, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                loc.translate('select_branch'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${vm.branches.length} ${vm.branches.length == 1 ? 'branch' : 'branches'} available',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ViewModeToggle(
                          showMap: _showMap,
                          onChanged: (mapMode) =>
                              setState(() => _showMap = mapMode),
                        ),
                        const SizedBox(width: 8),
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
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withAlpha(22),
                            minimumSize: const Size(38, 38),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content area: full map or branch list
              Expanded(
                child: ShiftIQContentTransition(
                  child: _buildContent(context, vm, loc),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    BranchSelectionViewModel vm,
    AppLocalizations loc,
  ) {
    if (vm.isLoading && vm.branches.isEmpty) {
      return const ShiftIQSkeletonBranchList(key: ValueKey('branches_loading'));
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
            const Center(
              child: ShiftIQEmptyStateIcon(),
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
            Center(
              child: OutlinedButton.icon(
                onPressed: vm.loadBranches,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(loc.translate('refresh')),
              ),
            ),
          ],
        ),
      );
    }

    if (_showMap) {
      final canCreateBranch =
          _roleScope == MobileRoleScope.ownerAdmin && vm.branches.isNotEmpty;
      return BranchMapView(
        branches: vm.branches,
        selectedBranch: vm.selectedBranch,
        onEnterBranch: _onBranchSelected,
        onCreateBranch: canCreateBranch
            ? () => _showBranchFormModal(
                  context,
                  workshopId: vm.branches.first.workshopId,
                )
            : null,
      );
    }

    final isOwnerAdmin = _roleScope == MobileRoleScope.ownerAdmin;
    return RefreshIndicator(
      onRefresh: vm.loadBranches,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        itemCount: vm.branches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final branch = vm.branches[index];
          final isCurrent = vm.selectedBranch?.id == branch.id;
          return BranchListCard(
            branch: branch,
            isFocused: true,
            isCurrentSession: isCurrent,
            onTap: () => _onBranchSelected(branch),
            onEnter: () => _onBranchSelected(branch),
            onEdit: isOwnerAdmin
                ? () => _showBranchFormModal(
                      context,
                      workshopId: branch.workshopId,
                      existingBranch: branch,
                    )
                : null,
          );
        },
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final bool showMap;
  final ValueChanged<bool> onChanged;

  const _ViewModeToggle({
    required this.showMap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            key: const Key('toggle_branch_map'),
            icon: Icons.map_outlined,
            selected: showMap,
            onTap: () => onChanged(true),
          ),
          _ToggleChip(
            key: const Key('toggle_branch_list'),
            icon: Icons.view_agenda_outlined,
            selected: !showMap,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 16,
          color: selected ? const Color(0xFF0F172A) : Colors.white70,
        ),
      ),
    );
  }
}

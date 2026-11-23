import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_pull_to_refresh.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';

/// Redesigned user profile screen displaying live backend identity and branch context.
class ProfilePage extends StatefulWidget {
  final ProfileViewModel? viewModel;

  const ProfilePage({super.key, this.viewModel});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileViewModel _viewModel;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<ProfileViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      final ok = await _viewModel.uploadAndSetProfileImage(
        fileBytes: bytes,
        fileName: picked.name,
      );
      if (!mounted) return;

      ShiftIQToast.show(
        context,
        message: ok
            ? 'Foto de perfil actualizada'
            : (_viewModel.error ?? 'No se pudo actualizar la foto de perfil'),
        type: ok ? ShiftIQToastType.success : ShiftIQToastType.error,
      );
    } catch (e) {
      if (!mounted) return;
      ShiftIQToast.show(
        context,
        message: 'No se pudo seleccionar la imagen: $e',
        type: ShiftIQToastType.error,
      );
    }
  }

  void _showAvatarSourceSheet() {
    if (_viewModel.isUploadingImage) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: ShiftIQColors.primaryBlue,
                ),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndUploadAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: ShiftIQColors.primaryBlue,
                ),
                title: const Text('Elegir de la galería'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet() {
    final loc = AppLocalizations.of(context);
    final emp = _viewModel.profileContext?.employee;
    final owner = _viewModel.profileContext?.owner;
    final customer = _viewModel.profileContext?.customer;

    final firstNameController = TextEditingController(
      text: emp?.firstName ?? owner?.firstName ?? customer?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: emp?.lastName ?? owner?.lastName ?? customer?.lastName ?? '',
    );
    final phoneController = TextEditingController(
      text: emp?.phone ?? owner?.phone ?? customer?.phone ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
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
                        loc.translate('edit_profile'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: firstNameController,
                    decoration: authInputDecoration(
                      hintText: loc.translate('first_name'),
                      prefixIcon: Icons.person_outline_rounded,
                    ).copyWith(labelText: loc.translate('first_name')),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'First name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastNameController,
                    decoration: authInputDecoration(
                      hintText: loc.translate('last_name'),
                      prefixIcon: Icons.badge_outlined,
                    ).copyWith(labelText: loc.translate('last_name')),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Last name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: authInputDecoration(
                      hintText: loc.translate('mobile_phone'),
                      prefixIcon: Icons.phone_outlined,
                    ).copyWith(labelText: loc.translate('mobile_phone')),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Phone is required'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  AuthPrimaryButton(
                    label: loc.translate('save'),
                    isLoading: _viewModel.isSaving,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final nav = Navigator.of(bottomSheetContext);

                      final success = await _viewModel.updateProfile(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        phone: phoneController.text,
                      );

                      if (success) {
                        nav.pop();
                      } else if (mounted) {
                        ShiftIQToast.show(
                          context,
                          message: _viewModel.error ?? 'Error',
                          type: ShiftIQToastType.error,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: ShiftIQColors.borderSlate),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: ShiftIQColors.severityCrimson.withAlpha(18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ShiftIQColors.severityCrimson.withAlpha(45),
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: ShiftIQColors.severityCrimson,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.translate('logout_dialog_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('customer_logout_confirm'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ShiftIQColors.graphiteText,
                            side: const BorderSide(
                              color: ShiftIQColors.borderSlate,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            loc.translate('cancel'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: FilledButton(
                          key: const Key('btn_confirm_logout'),
                          style: FilledButton.styleFrom(
                            backgroundColor: ShiftIQColors.severityCrimson,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await _viewModel.logout();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => LoginPage(
                                    viewModel: getIt<LoginViewModel>(),
                                  ),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          body: ShiftIQCollapsibleHeaderBody(
            header: ShiftIQPageHeader(
              title: loc.translate('profile_title'),
              subtitle: vm.roleDisplay,
              showBackButton: Navigator.of(context).canPop(),
            ),
            body: ShiftIQContentTransition(
                  child: vm.isLoading &&
                          vm.profileContext == null &&
                          vm.userEmail.isEmpty
                      ? const ShiftIQSkeletonDetail(key: ValueKey('profile_loading'))
                      : ShiftIQPullToRefresh(
                          onRefresh: vm.init,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Identity hero card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F172A),
                              ShiftIQColors.primaryBlue,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              key: const Key('profile_avatar_button'),
                              onTap: _showAvatarSourceSheet,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Colors.white.withAlpha(30),
                                    backgroundImage:
                                        vm.profileImageUrl != null
                                            ? NetworkImage(vm.profileImageUrl!)
                                            : null,
                                    child: vm.isUploadingImage
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : (vm.profileImageUrl == null
                                            ? Text(
                                                vm.displayName.isNotEmpty
                                                    ? vm.displayName[0]
                                                        .toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: ShiftIQColors.primaryBlue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              vm.displayName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vm.userEmail,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(24),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withAlpha(55),
                                ),
                              ),
                              child: Text(
                                vm.roleDisplay,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Personal Info Card
                      _ProfileSectionCard(
                        icon: Icons.badge_outlined,
                        title: 'Personal Information',
                        children: [
                          _InfoRow(label: 'Document', value: vm.documentDisplay),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'Phone', value: vm.phoneDisplay),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'Email', value: vm.userEmail),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Branch & Role Context Card
                      _ProfileSectionCard(
                        icon: vm.isOwnerAdmin
                            ? Icons.business_outlined
                            : Icons.storefront_outlined,
                        title: vm.isOwnerAdmin
                            ? 'Organization & Active Branch'
                            : 'Assigned Branch',
                        children: [
                          _InfoRow(
                            label: 'Active Branch',
                            value: vm.activeBranchName,
                          ),
                          if (!vm.isOwnerAdmin) ...[
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: 'Specialty',
                              value: vm.specialtyName,
                            ),
                            if (vm.salary > 0) ...[
                              const SizedBox(height: 10),
                              _InfoRow(
                                label: 'Base Salary',
                                value: 'S/ ${vm.salary.toStringAsFixed(2)}',
                              ),
                            ],
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Language Card
                      _ProfileSectionCard(
                        icon: Icons.translate_rounded,
                        title: 'Language (i18n)',
                        children: [
                          ValueListenableBuilder<Locale>(
                            valueListenable: appLocaleNotifier,
                            builder: (context, currentLocale, _) {
                              final isSpanish =
                                  currentLocale.languageCode == 'es';
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: Text(loc.translate('spanish_pe')),
                                    selected: isSpanish,
                                    selectedColor:
                                        ShiftIQColors.primaryBlue.withAlpha(24),
                                    onSelected: (selected) {
                                      if (selected) {
                                        appLocaleNotifier.value =
                                            const Locale('es', 'PE');
                                        if (getIt.isRegistered<SessionStorage>()) {
                                          getIt<SessionStorage>()
                                              .saveLocale('es');
                                        }
                                      }
                                    },
                                  ),
                                  ChoiceChip(
                                    label: Text(loc.translate('english_us')),
                                    selected: !isSpanish,
                                    selectedColor:
                                        ShiftIQColors.primaryBlue.withAlpha(24),
                                    onSelected: (selected) {
                                      if (selected) {
                                        appLocaleNotifier.value =
                                            const Locale('en', 'US');
                                        if (getIt.isRegistered<SessionStorage>()) {
                                          getIt<SessionStorage>()
                                              .saveLocale('en');
                                        }
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      ShiftIQLiquidButton(
                        key: const Key('btn_edit_profile'),
                        expand: true,
                        height: 48,
                        borderRadius: 16,
                        icon: Icons.edit_outlined,
                        label: loc.translate('edit_profile'),
                        onPressed: _showEditProfileBottomSheet,
                      ),
                      const SizedBox(height: 12),

                      // Soft Crimson Logout button
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          key: const Key('btn_logout'),
                          onPressed: _confirmLogout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 19,
                            color: ShiftIQColors.severityCrimson,
                          ),
                          label: const Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ShiftIQColors.severityCrimson,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                ShiftIQColors.severityCrimson.withAlpha(14),
                            side: BorderSide(
                              color:
                                  ShiftIQColors.severityCrimson.withAlpha(55),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _ProfileSectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ShiftIQColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: Color(0xFFE2E8F0)),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ShiftIQColors.graphiteText,
            ),
          ),
        ),
      ],
    );
  }
}

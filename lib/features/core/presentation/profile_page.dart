import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_view_model.dart';

class ProfilePage extends StatefulWidget {
  final ProfileViewModel? viewModel;

  const ProfilePage({super.key, this.viewModel});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<ProfileViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  void _showEditProfileBottomSheet() {
    final loc = AppLocalizations.of(context);
    final emp = _viewModel.profileContext?.employee;
    final owner = _viewModel.profileContext?.owner;

    final firstNameController = TextEditingController(
      text: emp?.firstName ?? owner?.firstName ?? '',
    );
    final lastNameController = TextEditingController(
      text: emp?.lastName ?? owner?.lastName ?? '',
    );
    final phoneController = TextEditingController(
      text: emp?.phone ?? owner?.phone ?? '',
    );

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                          fontWeight: FontWeight.bold,
                          color: ShiftIQColors.primaryBlue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los cambios se sincronizarán directamente con el servidor Render.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // First Name
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: loc.translate('first_name'),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa tus nombres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Last Name
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: loc.translate('last_name'),
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa tus apellidos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: loc.translate('mobile_phone'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Ingresa un teléfono de contacto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _viewModel.isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            final nav = Navigator.of(bottomSheetContext);
                            final messenger = ScaffoldMessenger.of(context);

                            final success = await _viewModel.updateProfile(
                              firstName: firstNameController.text,
                              lastName: lastNameController.text,
                              phone: phoneController.text,
                            );

                            if (success) {
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Perfil actualizado en el backend Render con éxito.',
                                  ),
                                  backgroundColor:
                                      ShiftIQColors.preventiveGreen,
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _viewModel.error ?? 'Error al guardar en el servidor Render.',
                                  ),
                                  backgroundColor:
                                      ShiftIQColors.severityCrimson,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShiftIQColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _viewModel.isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'GUARDAR CAMBIOS EN RENDER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
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
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.logout, color: ShiftIQColors.severityCrimson),
              const SizedBox(width: 8),
              Text(loc.translate('logout_dialog_title')),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar tu sesión activa en este taller?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.translate('cancel_upper')),
            ),
            ElevatedButton(
              key: const Key('btn_confirm_logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ShiftIQColors.severityCrimson,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _viewModel.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          LoginPage(viewModel: getIt<LoginViewModel>()),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Text(loc.translate('logout_upper')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final vm = _viewModel;
        final loc = AppLocalizations.of(context);

        return Scaffold(
          backgroundColor: ShiftIQColors.warmNeutral,
          appBar: AppBar(
            title: Text(
              loc.translate('profile_title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: AppLocalizations.of(context)
                    .translate('tooltip_refresh'),
                icon: const Icon(Icons.refresh),
                onPressed: vm.isLoading ? null : vm.init,
              ),
            ],
          ),
          body: vm.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ShiftIQColors.primaryBlue,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Avatar & Role Header
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: ShiftIQColors.borderSlate,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: ShiftIQColors.primaryBlue,
                                child: Text(
                                  vm.displayName.isNotEmpty
                                      ? vm.displayName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                vm.displayName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ShiftIQColors.graphiteText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vm.userEmail,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ShiftIQColors.primaryBlue.withAlpha(
                                    25,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: ShiftIQColors.primaryBlue,
                                  ),
                                ),
                                child: Text(
                                  vm.roleDisplay,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ShiftIQColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Personal Information Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: ShiftIQColors.borderSlate,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    color: ShiftIQColors.primaryBlue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Información Personal',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildInfoRow('Documento', vm.documentDisplay),
                              const SizedBox(height: 12),
                              _buildInfoRow('Teléfono Móvil', vm.phoneDisplay),
                              const SizedBox(height: 12),
                              _buildInfoRow('Correo', vm.userEmail),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Assigned Workshop & Branch Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: ShiftIQColors.borderSlate,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    vm.isOwner
                                        ? Icons.business_outlined
                                        : Icons.storefront_outlined,
                                    color: ShiftIQColors.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    vm.isOwner
                                        ? 'Empresa y Taller Matriz (Dueño)'
                                        : 'Sede de Taller Asignada',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              if (vm.isOwner) ...[
                                _buildInfoRow('Taller Matriz', 'Wagner Motors'),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Fundador / Propietario',
                                  vm.displayName,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow('RUC Empresa', '20601234567'),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Sede Principal',
                                  vm.activeBranchName,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Gobernanza',
                                  'Multisede / Administración Total',
                                ),
                              ] else ...[
                                _buildInfoRow(
                                  'Sede Actual',
                                  vm.activeBranchName,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Dirección',
                                  'Av. Tomas Marsano Nro. 890, Surquillo',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Especialidad Técnica',
                                  vm.specialtyName,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  'Salario Base Asignado',
                                  'S/ ${vm.salary.toStringAsFixed(2)}',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Language & Localization Settings Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: ShiftIQColors.borderSlate,
                          ),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.translate_outlined,
                                    color: ShiftIQColors.primaryBlue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Idioma de la Aplicación (i18n)',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
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
                                        avatar: const Text(
                                          '🇵🇪',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        label: Text(
                                          loc.translate('spanish_pe'),
                                        ),
                                        selected: isSpanish,
                                        selectedColor: ShiftIQColors.primaryBlue
                                            .withAlpha(25),
                                        onSelected: (selected) {
                                          if (selected) {
                                            appLocaleNotifier.value =
                                                const Locale('es', 'PE');
                                            getIt<SessionStorage>().saveLocale(
                                              'es',
                                            );
                                          }
                                        },
                                      ),
                                      ChoiceChip(
                                        avatar: const Text(
                                          '🇺🇸',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        label: Text(
                                          loc.translate('english_us'),
                                        ),
                                        selected: !isSpanish,
                                        selectedColor: ShiftIQColors.primaryBlue
                                            .withAlpha(25),
                                        onSelected: (selected) {
                                          if (selected) {
                                            appLocaleNotifier.value =
                                                const Locale('en', 'US');
                                            getIt<SessionStorage>().saveLocale(
                                              'en',
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Edit Profile Button
                      ElevatedButton.icon(
                        key: const Key('btn_edit_profile'),
                        onPressed: _showEditProfileBottomSheet,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text(
                          'EDITAR DATOS PERSONALES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShiftIQColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Logout Button
                      OutlinedButton.icon(
                        key: const Key('btn_logout'),
                        onPressed: _confirmLogout,
                        icon: const Icon(
                          Icons.logout,
                          color: ShiftIQColors.severityCrimson,
                        ),
                        label: const Text(
                          'CERRAR SESIÓN DEL TALLER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ShiftIQColors.severityCrimson,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: ShiftIQColors.severityCrimson,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 8),
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

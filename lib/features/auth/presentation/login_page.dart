import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/security/biometric_auth_service.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/forgot_password_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/forgot_password_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/register_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/register_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/widgets/auth_scaffold.dart';

/// Modern sign-in screen supporting Customers, Staff, and Workshop Owners/Admins.
class LoginPage extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginPage({super.key, required this.viewModel});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    widget.viewModel.clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      await _maybePromptBiometricEnrollment();
      if (!mounted) return;
      final destination = RoleRouter.resolveHomeForSession(
        getIt<SessionStorage>(),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  Future<void> _maybePromptBiometricEnrollment() async {
    if (!getIt.isRegistered<BiometricAuthService>() ||
        !getIt.isRegistered<SessionStorage>()) {
      return;
    }
    final userId = getIt<SessionStorage>().userId ?? '';
    if (userId.isEmpty) return;

    final biometric = getIt<BiometricAuthService>();
    final capability = await biometric.getCapability();
    if (capability != BiometricCapability.fingerprintOnly &&
        capability != BiometricCapability.faceOnly &&
        capability != BiometricCapability.both) {
      return;
    }

    final alreadyEnabled = await biometric.isBiometricEnabledForUser(userId);
    final alreadyPrompted =
        await biometric.hasPromptedEnrollmentForUser(userId);
    if (alreadyEnabled || alreadyPrompted || !mounted) return;

    final iconData = capability == BiometricCapability.faceOnly
        ? Icons.face_rounded
        : Icons.fingerprint_rounded;
    final bodyText = switch (capability) {
      BiometricCapability.fingerprintOnly =>
        'Usa tu huella digital para desbloquear tu sesión al abrir ShiftIQ. También puedes configurarlo después en tu Perfil.',
      BiometricCapability.faceOnly =>
        'Usa tu reconocimiento facial para desbloquear tu sesión al abrir ShiftIQ. También puedes configurarlo después en tu Perfil.',
      _ =>
        'Usa tu huella dactilar o reconocimiento facial para desbloquear tu sesión al abrir ShiftIQ. También puedes configurarlo después en tu Perfil.',
    };
    final ctaLabel = switch (capability) {
      BiometricCapability.fingerprintOnly => 'Activar Huella Digital',
      BiometricCapability.faceOnly => 'Activar Reconocimiento Facial',
      _ => 'Activar Huella / Rostro',
    };
    final authReason = switch (capability) {
      BiometricCapability.fingerprintOnly =>
        'Confirma tu huella digital para activar el desbloqueo rápido',
      BiometricCapability.faceOnly =>
        'Confirma tu reconocimiento facial para activar el desbloqueo rápido',
      _ =>
        'Confirma tu huella o rostro para activar el desbloqueo rápido',
    };

    final enable = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ShiftIQColors.primaryBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 32,
                    color: ShiftIQColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context)
                      .translate('biometric_optin_title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bodyText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: ShiftIQColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      ctaLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(
                    AppLocalizations.of(context).translate('biometric_not_now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (enable == true) {
      final result = await biometric.authenticate(reason: authReason);
      await biometric.setBiometricEnabled(userId, result.isSuccess);
    } else {
      await biometric.markEnrollmentPrompted(userId);
    }
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordPage(
          viewModel: getIt<ForgotPasswordViewModel>(),
        ),
      ),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterPage(
          viewModel: getIt<RegisterViewModel>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        return AuthScaffold(
          title: loc.translate('auth_welcome_title'),
          subtitle: loc.translate('auth_welcome_subtitle'),
          footer: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    loc.translate('auth_no_account'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  TextButton(
                    key: const Key('login_register_button'),
                    onPressed: _openRegister,
                    child: Text(
                      loc.translate('auth_create_account'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                loc.translate('auth_footer_roles'),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vm.errorMessage != null)
                  AuthErrorBanner(message: vm.errorMessage!),

                Text(
                  loc.translate('email'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('login_email_input'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: authInputDecoration(
                    hintText: loc.translate('email_hint'),
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.translate('auth_email_required');
                    }
                    if (!value.contains('@')) {
                      return loc.translate('auth_email_invalid');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                Text(
                  loc.translate('password'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('login_password_input'),
                  controller: _passwordController,
                  obscureText: vm.obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: authInputDecoration(
                    hintText: loc.translate('password_hint'),
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        vm.obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: vm.togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.translate('auth_password_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('login_forgot_password_button'),
                    onPressed: _openForgotPassword,
                    child: Text(
                      loc.translate('forgot_password'),
                      style: const TextStyle(
                        color: ShiftIQColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                AuthPrimaryButton(
                  buttonKey: const Key('login_submit_button'),
                  label: loc.translate('auth_sign_in_btn'),
                  isLoading: vm.isLoading,
                  onPressed: _handleLogin,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

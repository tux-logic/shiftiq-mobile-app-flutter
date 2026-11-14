import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/forgot_password_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/widgets/auth_scaffold.dart';

/// Two-step password recovery and reset screen backed by `/password-recoveries` and `/password-resets`.
class ForgotPasswordPage extends StatefulWidget {
  final ForgotPasswordViewModel viewModel;

  const ForgotPasswordPage({super.key, required this.viewModel});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendEmail() async {
    widget.viewModel.clearError();
    if (!_formKey.currentState!.validate()) return;
    await widget.viewModel.sendRecoveryEmail(_emailController.text);
  }

  Future<void> _handleResetPassword() async {
    widget.viewModel.clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.resetPassword(
      token: _tokenController.text,
      newPassword: _newPasswordController.text,
    );

    if (success && mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('forgot_success_msg')),
          backgroundColor: ShiftIQColors.preventiveGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final isStepOne = vm.step == ForgotPasswordStep.requestEmail;

        return AuthScaffold(
          title: loc.translate('forgot_title'),
          subtitle: isStepOne
              ? loc.translate('forgot_step1_subtitle')
              : loc.translate('forgot_step2_subtitle'),
          showBackButton: true,
          showLogo: false,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vm.errorMessage != null)
                  AuthErrorBanner(message: vm.errorMessage!),

                if (isStepOne) ...[
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
                    key: const Key('forgot_email_input'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
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
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    buttonKey: const Key('forgot_send_button'),
                    label: loc.translate('forgot_send_btn'),
                    isLoading: vm.isLoading,
                    onPressed: _handleSendEmail,
                  ),
                ] else ...[
                  Text(
                    loc.translate('forgot_token_label'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('forgot_token_input'),
                    controller: _tokenController,
                    autocorrect: false,
                    decoration: authInputDecoration(
                      hintText: loc.translate('forgot_token_hint'),
                      prefixIcon: Icons.vpn_key_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.translate('forgot_token_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    loc.translate('forgot_new_password_label'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('forgot_new_password_input'),
                    controller: _newPasswordController,
                    obscureText: vm.obscurePassword,
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
                      if (value.length < 8) {
                        return loc.translate('auth_password_min');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    buttonKey: const Key('forgot_reset_button'),
                    label: loc.translate('forgot_reset_btn'),
                    isLoading: vm.isLoading,
                    onPressed: _handleResetPassword,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

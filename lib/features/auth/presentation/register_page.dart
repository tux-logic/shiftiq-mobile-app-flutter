import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/register_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/widgets/auth_scaffold.dart';

/// Three-step customer sign-up flow with mandatory 6-digit OTP email verification.
class RegisterPage extends StatefulWidget {
  final RegisterViewModel viewModel;

  const RegisterPage({super.key, required this.viewModel});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    widget.viewModel.clearError();
    if (!_formKey.currentState!.validate()) return;
    await widget.viewModel.sendOtp(_emailController.text);
  }

  Future<void> _handleVerifyOtp() async {
    widget.viewModel.clearError();
    if (!_formKey.currentState!.validate()) return;
    await widget.viewModel.verifyOtp(_otpController.text);
  }

  Future<void> _handleSignUp() async {
    widget.viewModel.clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await widget.viewModel.completeSignUp(
      _passwordController.text,
    );

    if (success && mounted) {
      final destination = RoleRouter.resolveHomeForSession(
        getIt<SessionStorage>(),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final subtitle = switch (vm.step) {
          RegisterStep.enterEmail => loc.translate('register_step1_subtitle'),
          RegisterStep.verifyOtp => loc.translate('register_step2_subtitle'),
          RegisterStep.createPassword =>
            loc.translate('register_step3_subtitle'),
        };

        return AuthScaffold(
          title: loc.translate('register_title'),
          subtitle: subtitle,
          showBackButton: true,
          showLogo: false,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepIndicator(currentStep: vm.step.index),
                const SizedBox(height: 20),
                if (vm.errorMessage != null)
                  AuthErrorBanner(message: vm.errorMessage!),

                if (vm.step == RegisterStep.enterEmail) ...[
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
                    key: const Key('register_email_input'),
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
                    buttonKey: const Key('register_send_otp_button'),
                    label: loc.translate('register_send_otp_btn'),
                    isLoading: vm.isLoading,
                    onPressed: _handleSendOtp,
                  ),
                ] else if (vm.step == RegisterStep.verifyOtp) ...[
                  Text(
                    loc.translate('register_otp_label'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('register_otp_input'),
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: authInputDecoration(
                      hintText: '123456',
                      prefixIcon: Icons.pin_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length != 6) {
                        return loc.translate('register_otp_required');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthPrimaryButton(
                    buttonKey: const Key('register_verify_otp_button'),
                    label: loc.translate('register_verify_otp_btn'),
                    isLoading: vm.isLoading,
                    onPressed: _handleVerifyOtp,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: vm.isLoading
                        ? null
                        : () => vm.sendOtp(vm.verifiedEmail),
                    child: Text(
                      loc.translate('register_resend_otp'),
                      style: const TextStyle(
                        color: ShiftIQColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
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
                    key: const Key('register_password_input'),
                    controller: _passwordController,
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
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('register_confirm_password_label'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('register_confirm_password_input'),
                    controller: _confirmPasswordController,
                    obscureText: vm.obscurePassword,
                    decoration: authInputDecoration(
                      hintText: loc.translate('password_hint'),
                      prefixIcon: Icons.lock_reset_outlined,
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return loc.translate('register_password_mismatch');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    buttonKey: const Key('register_submit_button'),
                    label: loc.translate('register_submit_btn'),
                    isLoading: vm.isLoading,
                    onPressed: _handleSignUp,
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

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
            decoration: BoxDecoration(
              color: active
                  ? ShiftIQColors.primaryBlue
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

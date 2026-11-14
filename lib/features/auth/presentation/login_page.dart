import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
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
      final destination = RoleRouter.resolveHomeForSession(
        getIt<SessionStorage>(),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_logo.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_page.dart';

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BranchSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                final vm = widget.viewModel;
                final loc = AppLocalizations.of(context);

                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ShiftIQ Workshop Logo & Header
                      const Center(
                        child: ShiftIqLogo(size: LogoSize.medium),
                      ),
                      const SizedBox(height: 32),

                      // Error Banner
                      if (vm.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ShiftIQColors.severityCrimson.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ShiftIQColors.severityCrimson.withAlpha(
                                120,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: ShiftIQColors.severityCrimson,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  vm.errorMessage!,
                                  style: const TextStyle(
                                    color: ShiftIQColors.severityCrimson,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Email Field
                      Text(
                        loc.translate('email'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('login_email_input'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          hintText: loc.translate('email_hint'),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese su correo electrónico';
                          }
                          if (!value.contains('@')) {
                            return 'Ingrese un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      Text(
                        loc.translate('password'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('login_password_input'),
                        controller: _passwordController,
                        obscureText: vm.obscurePassword,
                        decoration: InputDecoration(
                          hintText: loc.translate('password_hint'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              vm.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: vm.togglePasswordVisibility,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese su contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ingrese a recuperación mediante el portal web o contacte a soporte.',
                                ),
                              ),
                            );
                          },
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
                      const SizedBox(height: 16),

                      // Quick Account Autofill Chips (Comentado según solicitud)
                      /*
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ShiftIQColors.primaryBlue.withAlpha(12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ShiftIQColors.primaryBlue.withAlpha(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate('quick_access_title'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ShiftIQColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ActionChip(
                                  key: const Key('chip_mechanic'),
                                  avatar: const Icon(
                                    Icons.build,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  label: Text(loc.translate('mechanic_chip')),
                                  backgroundColor: ShiftIQColors.primaryBlue,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _emailController.text =
                                          'aldospeedcuber@gmail.com';
                                      _passwordController.text = 'ShiftIQ2026!';
                                    });
                                  },
                                ),
                                ActionChip(
                                  key: const Key('chip_owner'),
                                  avatar: const Icon(
                                    Icons.business,
                                    size: 14,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                  label: Text(loc.translate('owner_chip')),
                                  backgroundColor: Colors.white,
                                  labelStyle: const TextStyle(
                                    color: ShiftIQColors.graphiteText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _emailController.text =
                                          'allan.wagner.107@gmail.com';
                                      _passwordController.text = '12345678A';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      */

                      // Submit Button
                      ElevatedButton(
                        key: const Key('login_submit_button'),
                        onPressed: vm.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ShiftIQColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: vm.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                loc.translate('login_btn'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Footer Note
                      Center(
                        child: Text(
                          'ShiftIQ v1.0 • Acceso seguro B2B Talleres',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

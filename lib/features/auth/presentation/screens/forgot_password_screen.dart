import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _pageController = PageController();
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;
  bool _resetSuccess = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestRecovery() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    FocusScope.of(context).unfocus();

    try {
      final repository = context.read<IAuthRepository>();
      await repository.requestPasswordRecovery(email: _emailController.text.trim());

      setState(() {
        _isLoading = false;
        _currentStep = 1;
      });

      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleResetPassword() async {
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    FocusScope.of(context).unfocus();

    try {
      final repository = context.read<IAuthRepository>();
      await repository.resetPassword(
        token: _tokenController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      setState(() {
        _isLoading = false;
        _resetSuccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
          onPressed: () {
            if (_resetSuccess) {
              Navigator.of(context).pop();
            } else if (_currentStep == 1) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
              setState(() => _currentStep = 0);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _resetSuccess
              ? 'Contraseña Actualizada'
              : _currentStep == 0
                  ? 'Recuperar Contraseña'
                  : 'Restablecer Contraseña',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _resetSuccess
            ? _buildSuccessView()
            : Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4,
                            decoration: BoxDecoration(
                              color: _currentStep == 1 ? AppColors.primary : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildRequestStep(),
                        _buildResetStep(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ========================================================
  // STEP 1: Solicitar recuperación
  // ========================================================
  Widget _buildRequestStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _emailFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No te preocupes. Ingresa el correo electrónico asociado a tu cuenta de ShiftIQ y te enviaremos un código o token de recuperación.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Correo electrónico',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleRequestRecovery(),
              decoration: InputDecoration(
                hintText: 'ejemplo@shiftiq.com',
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                fillColor: const Color(0xFFF8FAFC),
              ),
              validator: (value) {
                final email = Email(value ?? '');
                return email.errorMessage;
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleRequestRecovery,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Enviar Instrucciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // STEP 2: Ingresar Token y Nueva Contraseña
  // ========================================================
  Widget _buildResetStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _resetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el token',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14.5, color: Color(0xFF64748B), height: 1.4),
                children: [
                  const TextSpan(text: 'Revisa tu bandeja de entrada en '),
                  TextSpan(
                    text: _emailController.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const TextSpan(text: ' y pega el token de restablecimiento.'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Token Field
            const Text(
              'Token de recuperación',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tokenController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Pega el token recibido por correo',
                prefixIcon: const Icon(Icons.key_outlined, size: 20),
                fillColor: const Color(0xFFF8FAFC),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Ingresa el token recibido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // New Password Field
            const Text(
              'Nueva contraseña',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Mínimo 8 caracteres',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                fillColor: const Color(0xFFF8FAFC),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                final password = Password(value ?? '');
                return password.errorMessage;
              },
            ),
            const SizedBox(height: 12),
            _buildPasswordRequirements(),
            const SizedBox(height: 20),

            // Confirm Password Field
            const Text(
              'Confirmar nueva contraseña',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleResetPassword(),
              decoration: InputDecoration(
                hintText: 'Repite la nueva contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                fillColor: const Color(0xFFF8FAFC),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (value != _newPasswordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Actualizar Contraseña',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Password Strength helper ---
  Widget _buildPasswordRequirements() {
    final text = _newPasswordController.text;
    final hasLength = text.length >= 8;
    final hasUpper = text.contains(RegExp(r'[A-Z]'));
    final hasNumber = text.contains(RegExp(r'[0-9]'));
    final hasSpecial = text.contains(RegExp(r'[@$!%*?&#.\-_]'));

    Widget reqChip(String label, bool satisfied) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            satisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 14,
            color: satisfied ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: satisfied ? const Color(0xFF0F766E) : const Color(0xFF64748B),
              fontWeight: satisfied ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        reqChip('8+ caracteres', hasLength),
        reqChip('1 Mayúscula', hasUpper),
        reqChip('1 Número', hasNumber),
        reqChip('1 Símbolo', hasSpecial),
      ],
    );
  }

  // ========================================================
  // SUCCESS SCREEN
  // ========================================================
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFECFDF5),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 52,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Contraseña actualizada!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tu contraseña se ha modificado exitosamente. Ya puedes iniciar sesión con tus nuevas credenciales.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Volver a Iniciar Sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

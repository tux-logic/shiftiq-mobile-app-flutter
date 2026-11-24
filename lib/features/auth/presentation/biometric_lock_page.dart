import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/security/biometric_auth_service.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/logout.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';

/// Biometric app-lock gate shown on launch when the active user enabled
/// fingerprint/face unlock. Never blocks switching to another account.
class BiometricLockPage extends StatefulWidget {
  final BiometricAuthService? biometricService;

  const BiometricLockPage({super.key, this.biometricService});

  @override
  State<BiometricLockPage> createState() => _BiometricLockPageState();
}

class _BiometricLockPageState extends State<BiometricLockPage> {
  late final BiometricAuthService _biometricService;
  BiometricCapability _capability = BiometricCapability.fingerprintOnly;
  bool _isAuthenticating = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _biometricService =
        widget.biometricService ?? getIt<BiometricAuthService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndUnlock());
  }

  Future<void> _initAndUnlock() async {
    final cap = await _biometricService.getCapability();
    if (!mounted) return;
    setState(() => _capability = cap);
    await _attemptUnlock();
  }

  Future<void> _attemptUnlock() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _statusMessage = null;
    });

    final reason = switch (_capability) {
      BiometricCapability.fingerprintOnly =>
        'Desbloquea tu sesión de ShiftIQ con tu huella digital',
      BiometricCapability.faceOnly =>
        'Desbloquea tu sesión de ShiftIQ con reconocimiento facial',
      _ => 'Desbloquea tu sesión de ShiftIQ con huella o rostro',
    };

    final result = await _biometricService.authenticate(reason: reason);

    if (!mounted) return;

    if (result.isSuccess) {
      final session = getIt<SessionStorage>();
      final destination = RoleRouter.resolveHomeForSession(
        session,
        preferActiveBranch: true,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
      return;
    }

    setState(() {
      _isAuthenticating = false;
      _statusMessage = result.status == BiometricAuthStatus.cancelled
          ? 'Verificación cancelada. Toca el botón para intentar nuevamente.'
          : (result.message ?? 'No se pudo verificar tu identidad.');
    });
  }

  Future<void> _switchAccount() async {
    if (getIt.isRegistered<LogoutUseCase>()) {
      await getIt<LogoutUseCase>().execute();
    } else if (getIt.isRegistered<SessionStorage>()) {
      await getIt<SessionStorage>().clearSession();
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginPage(viewModel: getIt<LoginViewModel>()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = getIt.isRegistered<SessionStorage>()
        ? (getIt<SessionStorage>().username ?? '')
        : '';

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _capability == BiometricCapability.faceOnly
                        ? Icons.face_rounded
                        : Icons.fingerprint_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  AppLocalizations.of(context).translate('biometric_lock_title'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (username.isNotEmpty)
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(height: 14),
                Text(
                  _statusMessage ??
                      switch (_capability) {
                        BiometricCapability.fingerprintOnly =>
                          'Usa tu huella digital para continuar.',
                        BiometricCapability.faceOnly =>
                          'Usa tu reconocimiento facial para continuar.',
                        _ =>
                          'Usa tu huella digital o reconocimiento facial para continuar.',
                      },
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isAuthenticating ? null : _attemptUnlock,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ShiftIQColors.primaryBlue,
                            ),
                          )
                        : const Icon(Icons.lock_open_rounded),
                    label: Text(
                      _isAuthenticating
                          ? AppLocalizations.of(context)
                              .translate('biometric_verifying')
                          : switch (_capability) {
                              BiometricCapability.fingerprintOnly =>
                                AppLocalizations.of(context)
                                    .translate('biometric_unlock_fingerprint'),
                              BiometricCapability.faceOnly =>
                                AppLocalizations.of(context)
                                    .translate('biometric_unlock_face'),
                              _ => AppLocalizations.of(context)
                                  .translate('biometric_unlock_both'),
                            },
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isAuthenticating ? null : _switchAccount,
                  child: Text(
                    AppLocalizations.of(context)
                        .translate('biometric_use_another_account'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

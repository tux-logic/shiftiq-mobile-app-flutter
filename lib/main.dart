import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/security/biometric_auth_service.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/biometric_lock_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await getIt<SessionStorage>().initialize();
  final savedLocale = getIt<SessionStorage>().savedLocale;
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  appLocaleNotifier.value = AppLocalizations.resolveInitialLocale(
    savedLocale,
    systemLocale,
  );
  final session = getIt<SessionStorage>();
  var requireBiometricUnlock = false;
  if (session.isAuthenticated && session.userId != null) {
    final biometric = getIt<BiometricAuthService>();
    final supported = await biometric.isDeviceSupported();
    final enabled = await biometric.isBiometricEnabledForUser(session.userId!);
    requireBiometricUnlock = supported && enabled;
  }
  runApp(ShiftIqApp(requireBiometricUnlock: requireBiometricUnlock));
}

class ShiftIqApp extends StatelessWidget {
  final bool requireBiometricUnlock;

  const ShiftIqApp({super.key, this.requireBiometricUnlock = false});

  @override
  Widget build(BuildContext context) {
    const textTheme = TextTheme();
    final materialTheme = MaterialTheme(textTheme);

    return ValueListenableBuilder<Locale>(
      valueListenable: appLocaleNotifier,
      builder: (context, activeLocale, _) {
        return MaterialApp(
          title: 'ShiftIQ Workshop',
          debugShowCheckedModeBanner: false,
          theme: materialTheme.light(),
          darkTheme: materialTheme.dark(),
          themeMode: ThemeMode.light,
          locale: activeLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: _resolveInitialScreen(),
        );
      },
    );
  }

  Widget _resolveInitialScreen() {
    final session = getIt<SessionStorage>();
    if (session.isAuthenticated) {
      if (requireBiometricUnlock) {
        return const BiometricLockPage();
      }
      return RoleRouter.resolveHomeForSession(
        session,
        preferActiveBranch: true,
      );
    }
    return LoginPage(viewModel: getIt<LoginViewModel>());
  }
}

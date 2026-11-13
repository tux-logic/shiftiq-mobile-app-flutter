import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await getIt<SessionStorage>().initialize();
  final savedLocale = getIt<SessionStorage>().savedLocale;
  if (savedLocale != null && savedLocale.isNotEmpty) {
    appLocaleNotifier.value = Locale(savedLocale);
  }
  runApp(const ShiftIqApp());
}

class ShiftIqApp extends StatelessWidget {
  const ShiftIqApp({super.key});

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
          home: LoginPage(viewModel: getIt<LoginViewModel>()),
        );
      },
    );
  }
}

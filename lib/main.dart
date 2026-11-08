import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const ShiftIqApp());
}

class ShiftIqApp extends StatelessWidget {
  const ShiftIqApp({super.key});

  @override
  Widget build(BuildContext context) {
    const textTheme = TextTheme();
    final materialTheme = MaterialTheme(textTheme);

    return MaterialApp(
      title: 'ShiftIQ Workshop',
      debugShowCheckedModeBanner: false,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.light,
      home: LoginPage(viewModel: getIt<LoginViewModel>()),
    );
  }
}

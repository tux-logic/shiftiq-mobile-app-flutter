import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/login_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginViewModel({required this.loginUseCase});

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;
  UserSession? currentSession;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      errorMessage = 'Por favor complete todos los campos requeridos.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentSession = await loginUseCase.execute(
        email: email.trim(),
        password: password,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/password_recovery.dart';

enum ForgotPasswordStep { requestEmail, resetWithToken, completed }

/// ViewModel managing the two-step password recovery and reset workflow.
class ForgotPasswordViewModel extends ChangeNotifier {
  final RequestPasswordRecoveryUseCase requestRecoveryUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  ForgotPasswordViewModel({
    required this.requestRecoveryUseCase,
    required this.resetPasswordUseCase,
  });

  ForgotPasswordStep step = ForgotPasswordStep.requestEmail;
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;
  String targetEmail = '';

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

  Future<bool> sendRecoveryEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      errorMessage = 'Please enter a valid email address.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await requestRecoveryUseCase.execute(email: trimmed);
      targetEmail = trimmed;
      step = ForgotPasswordStep.resetWithToken;
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

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty || newPassword.length < 8) {
      errorMessage = 'Provide a valid token and a password of at least 8 characters.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await resetPasswordUseCase.execute(
        token: trimmedToken,
        newPassword: newPassword,
      );
      step = ForgotPasswordStep.completed;
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

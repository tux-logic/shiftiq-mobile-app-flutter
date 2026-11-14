import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/login_with_password.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/otp_verification.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/sign_up_user.dart';

enum RegisterStep { enterEmail, verifyOtp, createPassword }

/// ViewModel orchestrating OTP email verification, sign-up, and auto-login.
class RegisterViewModel extends ChangeNotifier {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final SignUpUserUseCase signUpUserUseCase;
  final LoginWithPasswordUseCase loginUseCase;

  RegisterViewModel({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.signUpUserUseCase,
    required this.loginUseCase,
  });

  RegisterStep step = RegisterStep.enterEmail;
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;
  String verifiedEmail = '';

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

  void backToEmailStep() {
    step = RegisterStep.enterEmail;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> sendOtp(String email) async {
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
      await sendOtpUseCase.execute(email: trimmed);
      verifiedEmail = trimmed;
      step = RegisterStep.verifyOtp;
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

  Future<bool> verifyOtp(String code) async {
    final trimmedCode = code.trim();
    if (trimmedCode.length != 6) {
      errorMessage = 'Please enter the 6-digit verification code.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await verifyOtpUseCase.execute(email: verifiedEmail, code: trimmedCode);
      step = RegisterStep.createPassword;
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

  Future<bool> completeSignUp(String password) async {
    if (password.length < 8) {
      errorMessage = 'Password must be at least 8 characters.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await signUpUserUseCase.execute(
        email: verifiedEmail,
        password: password,
      );
      await loginUseCase.execute(email: verifiedEmail, password: password);
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

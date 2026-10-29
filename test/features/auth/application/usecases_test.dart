import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/application/login_with_email_usecase.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/application/request_password_recovery_usecase.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/application/reset_password_usecase.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/application/send_otp_usecase.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/application/sign_up_usecase.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/application/verify_otp_usecase.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/domain/entities/auth_tokens.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/domain/entities/user.dart';
import 'package:app_mobile_flutter_shiftiq/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements IAuthRepository {
  bool sendOtpCalled = false;
  bool verifyOtpCalled = false;
  bool signUpCalled = false;
  bool requestRecoveryCalled = false;
  bool resetPasswordCalled = false;
  bool loginCalled = false;

  @override
  Future<void> sendOtp({required String email}) async {
    sendOtpCalled = true;
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    verifyOtpCalled = true;
  }

  @override
  Future<User> signUp({required String email, required String password}) async {
    signUpCalled = true;
    return const User(id: 'usr-1', email: 'test@shiftiq.com', role: 'ROLE_USER');
  }

  @override
  Future<void> requestPasswordRecovery({required String email}) async {
    requestRecoveryCalled = true;
  }

  @override
  Future<void> resetPassword({required String token, required String newPassword}) async {
    resetPasswordCalled = true;
  }

  @override
  Future<User> loginWithEmail({required String email, required String password}) async {
    loginCalled = true;
    return const User(id: 'usr-1', email: 'test@shiftiq.com', role: 'ROLE_USER');
  }

  @override
  Future<List<String>> getActiveRoles(String userId) async => ['ROLE_USER'];

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<User> loginWithGoogle({required String idToken}) async {
    return const User(id: 'usr-1', email: 'test@shiftiq.com', role: 'ROLE_USER');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthTokens> refreshToken() async {
    return const AuthTokens(accessToken: 'a', refreshToken: 'r', expiresInSeconds: 900);
  }
}

void main() {
  group('IAM Use Cases Test Suite', () {
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
    });

    test('SendOtpUseCase calls repository', () async {
      final useCase = SendOtpUseCase(repository: mockRepo);
      await useCase(email: 'user@shiftiq.com');
      expect(mockRepo.sendOtpCalled, true);
    });

    test('VerifyOtpUseCase calls repository', () async {
      final useCase = VerifyOtpUseCase(repository: mockRepo);
      await useCase(email: 'user@shiftiq.com', code: '123456');
      expect(mockRepo.verifyOtpCalled, true);
    });

    test('SignUpUseCase calls repository and returns User', () async {
      final useCase = SignUpUseCase(repository: mockRepo);
      final user = await useCase(email: 'user@shiftiq.com', password: 'Password123!');
      expect(mockRepo.signUpCalled, true);
      expect(user.id, 'usr-1');
      expect(user.role, 'ROLE_USER');
    });

    test('RequestPasswordRecoveryUseCase calls repository', () async {
      final useCase = RequestPasswordRecoveryUseCase(repository: mockRepo);
      await useCase(email: 'user@shiftiq.com');
      expect(mockRepo.requestRecoveryCalled, true);
    });

    test('ResetPasswordUseCase calls repository', () async {
      final useCase = ResetPasswordUseCase(repository: mockRepo);
      await useCase(token: 'xyz-token', newPassword: 'NewPassword123!');
      expect(mockRepo.resetPasswordCalled, true);
    });

    test('LoginWithEmailUseCase calls repository and returns User', () async {
      final useCase = LoginWithEmailUseCase(repository: mockRepo);
      final user = await useCase(email: 'user@shiftiq.com', password: 'Password123!');
      expect(mockRepo.loginCalled, true);
      expect(user.email, 'test@shiftiq.com');
    });
  });
}

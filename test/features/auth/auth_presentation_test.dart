import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/login_with_password.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/otp_verification.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/password_recovery.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/sign_up_user.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/entities/user_account.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/value_objects/user_role.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/forgot_password_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/register_view_model.dart';

class _FakeAuthRepository implements AuthRepository {
  bool shouldFail = false;
  int loginCallCount = 0;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    if (shouldFail) throw Exception('Invalid credentials');
    return UserSession(
      id: 'user-1',
      username: email,
      token: 'token-123',
      refreshToken: 'refresh-123',
      roles: const ['ROLE_USER'],
    );
  }

  @override
  Future<void> requestPasswordRecovery({required String email}) async {
    if (shouldFail) throw Exception('Recovery error');
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (shouldFail) throw Exception('Invalid token');
  }

  @override
  Future<void> sendOtp({required String email}) async {
    if (shouldFail) throw Exception('OTP send failed');
  }

  @override
  Future<void> verifyOtp({required String email, required String code}) async {
    if (shouldFail) throw Exception('Invalid OTP');
  }

  @override
  Future<UserAccount> signUp({
    required String email,
    required String password,
  }) async {
    if (shouldFail) throw Exception('Sign up failed');
    return UserAccount(
      id: 'user-1',
      email: email,
      role: UserRole.user,
    );
  }

  @override
  Future<UserSession> loginWithGoogle({required String idToken}) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<UserSession> refreshToken() => throw UnimplementedError();

  @override
  Future<UserAccount> getUserById(String userId) => throw UnimplementedError();

  @override
  Future<UserAccount> getUserByEmail(String email) => throw UnimplementedError();

  @override
  Future<UserSession> updateUserEmail({
    required String userId,
    required String newEmail,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> updateUserPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) =>
      throw UnimplementedError();
}

void main() {
  group('RoleRouter.resolveScope', () {
    test('maps customer and default user roles to customer scope', () {
      expect(RoleRouter.resolveScope(['ROLE_USER']), MobileRoleScope.customer);
      expect(
        RoleRouter.resolveScope(['ROLE_CUSTOMER']),
        MobileRoleScope.customer,
      );
      expect(RoleRouter.resolveScope([]), MobileRoleScope.customer);
    });

    test('maps employee roles to employee scope', () {
      expect(
        RoleRouter.resolveScope(['ROLE_EMPLOYEE']),
        MobileRoleScope.employee,
      );
      expect(
        RoleRouter.resolveScope(['EMPLOYEE']),
        MobileRoleScope.employee,
      );
    });

    test('maps owner and admin roles to ownerAdmin scope', () {
      expect(
        RoleRouter.resolveScope(['ROLE_OWNER']),
        MobileRoleScope.ownerAdmin,
      );
      expect(
        RoleRouter.resolveScope(['ROLE_ADMIN']),
        MobileRoleScope.ownerAdmin,
      );
    });
  });

  group('ForgotPasswordViewModel', () {
    late _FakeAuthRepository repo;
    late ForgotPasswordViewModel vm;

    setUp(() {
      repo = _FakeAuthRepository();
      vm = ForgotPasswordViewModel(
        requestRecoveryUseCase: RequestPasswordRecoveryUseCase(repository: repo),
        resetPasswordUseCase: ResetPasswordUseCase(repository: repo),
      );
    });

    test('advances from email request to reset step and completes', () async {
      expect(vm.step, ForgotPasswordStep.requestEmail);

      final sent = await vm.sendRecoveryEmail('customer@shiftiq.com');
      expect(sent, isTrue);
      expect(vm.step, ForgotPasswordStep.resetWithToken);
      expect(vm.targetEmail, 'customer@shiftiq.com');

      final reset = await vm.resetPassword(
        token: 'reset-token-1',
        newPassword: 'Password123!',
      );
      expect(reset, isTrue);
      expect(vm.step, ForgotPasswordStep.completed);
    });

    test('rejects invalid email and short password locally', () async {
      final sent = await vm.sendRecoveryEmail('not-an-email');
      expect(sent, isFalse);
      expect(vm.errorMessage, isNotNull);

      final reset = await vm.resetPassword(token: '', newPassword: '123');
      expect(reset, isFalse);
      expect(vm.errorMessage, isNotNull);
    });
  });

  group('RegisterViewModel', () {
    late _FakeAuthRepository repo;
    late RegisterViewModel vm;

    setUp(() {
      repo = _FakeAuthRepository();
      vm = RegisterViewModel(
        sendOtpUseCase: SendOtpUseCase(repository: repo),
        verifyOtpUseCase: VerifyOtpUseCase(repository: repo),
        signUpUserUseCase: SignUpUserUseCase(repository: repo),
        loginUseCase: LoginWithPasswordUseCase(repository: repo),
      );
    });

    test('completes OTP verification, sign up, and auto-login', () async {
      expect(vm.step, RegisterStep.enterEmail);

      expect(await vm.sendOtp('new.customer@shiftiq.com'), isTrue);
      expect(vm.step, RegisterStep.verifyOtp);

      expect(await vm.verifyOtp('123456'), isTrue);
      expect(vm.step, RegisterStep.createPassword);

      expect(await vm.completeSignUp('Password123!'), isTrue);
      expect(repo.loginCallCount, 1);
    });

    test('rejects invalid OTP length locally', () async {
      await vm.sendOtp('new.customer@shiftiq.com');
      expect(await vm.verifyOtp('123'), isFalse);
      expect(vm.errorMessage, isNotNull);
    });
  });

  group('LoginPage widget', () {
    testWidgets('renders redesigned fields and validates empty submit',
        (tester) async {
      final repo = _FakeAuthRepository();
      final vm = LoginViewModel(
        loginUseCase: LoginWithPasswordUseCase(repository: repo),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: LoginPage(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_email_input')), findsOneWidget);
      expect(find.byKey(const Key('login_password_input')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(
        find.byKey(const Key('login_forgot_password_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('login_register_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email address'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/login_with_password.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/entities/user_account.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/model/value_objects/user_role.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/user_session.dart';

class MockAuthRepository implements AuthRepository {
  bool shouldThrow = false;
  String expectedEmail = 'felipe.taller@castromotors.pe';
  String expectedPassword = 'Password123!';

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw Exception('Invalid credentials');
    }

    if (email == expectedEmail && password == expectedPassword) {
      return const UserSession(
        id: 'usr-1234',
        username: 'felipe.taller@castromotors.pe',
        token: 'jwt-access-token-xyz',
        refreshToken: 'refresh-token-abc',
        roles: ['ROLE_OWNER'],
      );
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<UserSession> loginWithGoogle({required String idToken}) async {
    return const UserSession(
      id: 'usr-google',
      username: 'google.user@shiftiq.com',
      token: 'jwt-google-token',
      refreshToken: 'refresh-google-token',
      roles: ['ROLE_USER'],
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> requestPasswordRecovery({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {}

  @override
  Future<UserSession> refreshToken() async {
    return const UserSession(
      id: 'usr-1234',
      username: 'felipe.taller@castromotors.pe',
      token: 'jwt-new-token',
      refreshToken: 'new-refresh-token',
      roles: ['ROLE_OWNER'],
    );
  }

  @override
  Future<void> sendOtp({required String email}) async {}

  @override
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {}

  @override
  Future<UserAccount> signUp({
    required String email,
    required String password,
  }) async {
    return UserAccount(
      id: 'usr-new',
      email: email,
      role: UserRole.user,
    );
  }

  @override
  Future<UserAccount> getUserById(String userId) async {
    return UserAccount(
      id: userId,
      email: 'user@castromotors.pe',
      role: UserRole.owner,
    );
  }

  @override
  Future<UserAccount> getUserByEmail(String email) async {
    return UserAccount(
      id: 'usr-1234',
      email: email,
      role: UserRole.owner,
    );
  }

  @override
  Future<UserSession> updateUserEmail({
    required String userId,
    required String newEmail,
  }) async {
    return UserSession(
      id: userId,
      username: newEmail,
      token: 'jwt-updated-token',
      refreshToken: 'refresh-updated-token',
      roles: const ['ROLE_OWNER'],
    );
  }

  @override
  Future<void> updateUserPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {}
}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(repository: mockRepository);
  });

  test(
    'LoginUseCase should return UserSession when credentials are valid',
    () async {
      final session = await useCase.execute(
        email: 'felipe.taller@castromotors.pe',
        password: 'Password123!',
      );

      expect(session.id, 'usr-1234');
      expect(session.username, 'felipe.taller@castromotors.pe');
      expect(session.token, 'jwt-access-token-xyz');
      expect(session.isOwner, true);
      expect(session.hasWorkshopManagementAccess, true);
    },
  );

  test('LoginUseCase should rethrow exception when repository fails', () async {
    mockRepository.shouldThrow = true;

    expect(
      () => useCase.execute(email: 'wrong@castromotors.pe', password: 'wrong'),
      throwsA(isA<Exception>()),
    );
  });
}

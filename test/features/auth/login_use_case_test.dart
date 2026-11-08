import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/login_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
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
      throw Exception('Credenciales incorrectas');
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
    throw Exception('Credenciales incorrectas');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> recoverPassword(String email) async {}

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

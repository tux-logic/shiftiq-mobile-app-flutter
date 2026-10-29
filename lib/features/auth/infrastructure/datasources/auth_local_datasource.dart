import '../../../../core/storage/secure_storage_service.dart';

abstract class IAuthLocalDataSource {
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
  });

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getUserId();
  Future<String?> getUserRole();
  Future<void> clearAuthSession();
  Future<bool> hasActiveSession();
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  final ISecureStorageService storageService;

  AuthLocalDataSource({required this.storageService});

  @override
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String role,
  }) async {
    await storageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await storageService.saveUserId(userId);
    await storageService.saveUserRole(role);
  }

  @override
  Future<String?> getAccessToken() => storageService.getAccessToken();

  @override
  Future<String?> getRefreshToken() => storageService.getRefreshToken();

  @override
  Future<String?> getUserId() => storageService.getUserId();

  @override
  Future<String?> getUserRole() => storageService.getUserRole();

  @override
  Future<void> clearAuthSession() => storageService.clearAll();

  @override
  Future<bool> hasActiveSession() async {
    final token = await storageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

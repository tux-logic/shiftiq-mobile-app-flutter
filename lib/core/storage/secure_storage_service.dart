import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';

abstract class ISecureStorageService {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveUserRole(String role);
  Future<String?> getUserRole();
  Future<void> clearAll();
}

class SecureStorageService implements ISecureStorageService {
  static const _accessTokenKey = 'shiftiq_access_token';
  static const _refreshTokenKey = 'shiftiq_refresh_token';
  static const _userIdKey = 'shiftiq_user_id';
  static const _userRoleKey = 'shiftiq_user_role';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException(message: 'Error al guardar los tokens de autenticación: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw CacheException(message: 'Error al leer el access token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw CacheException(message: 'Error al leer el refresh token: $e');
    }
  }

  @override
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      throw CacheException(message: 'Error al guardar el ID de usuario: $e');
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      throw CacheException(message: 'Error al leer el ID de usuario: $e');
    }
  }

  @override
  Future<void> saveUserRole(String role) async {
    try {
      await _storage.write(key: _userRoleKey, value: role);
    } catch (e) {
      throw CacheException(message: 'Error al guardar el rol de usuario: $e');
    }
  }

  @override
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (e) {
      throw CacheException(message: 'Error al leer el rol de usuario: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException(message: 'Error al limpiar el almacenamiento seguro: $e');
    }
  }
}

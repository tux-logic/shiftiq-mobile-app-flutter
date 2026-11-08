import 'dart:convert';
import 'package:shiftiq_mobile_app_flutter/core/app_database.dart';
import 'package:sqflite/sqflite.dart';

/// Storage manager for B2B session tokens, user identity, and active branch
class SessionStorage {
  final AppDatabase? appDatabase;

  // In-memory cache for high-speed synchronous access
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _username;
  List<String> _roles = [];
  String? _activeWorkshopId;
  String? _activeBranchId;
  String? _activeBranchName;

  SessionStorage({this.appDatabase});

  // Keys in SQLite app_settings table
  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUsername = 'auth_username';
  static const String _keyRoles = 'auth_roles';
  static const String _keyWorkshopId = 'auth_workshop_id';
  static const String _keyBranchId = 'auth_branch_id';
  static const String _keyBranchName = 'auth_branch_name';

  /// Initializes in-memory cache from persistent SQLite database
  Future<void> initialize() async {
    if (appDatabase == null) return;
    try {
      final db = await appDatabase!.database;
      final results = await db.query('app_settings');
      for (final row in results) {
        final key = row['key'] as String;
        final value = row['value'] as String;
        switch (key) {
          case _keyAccessToken:
            _accessToken = value;
            break;
          case _keyRefreshToken:
            _refreshToken = value;
            break;
          case _keyUserId:
            _userId = value;
            break;
          case _keyUsername:
            _username = value;
            break;
          case _keyRoles:
            _roles = (jsonDecode(value) as List).cast<String>();
            break;
          case _keyWorkshopId:
            _activeWorkshopId = value;
            break;
          case _keyBranchId:
            _activeBranchId = value;
            break;
          case _keyBranchName:
            _activeBranchName = value;
            break;
        }
      }
    } catch (_) {
      // Allow fallback if database is unavailable during tests
    }
  }

  Future<void> _persistSetting(String key, String? value) async {
    if (appDatabase == null) return;
    try {
      final db = await appDatabase!.database;
      if (value == null) {
        await db.delete('app_settings', where: 'key = ?', whereArgs: [key]);
      } else {
        await db.insert(
          'app_settings',
          {'key': key, 'value': value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (_) {
      // In-memory cache remains available
    }
  }

  // Getters & Setters
  Future<String?> getAccessToken() async => _accessToken;
  Future<String?> getRefreshToken() async => _refreshToken;
  Future<String?> getActiveBranchId() async => _activeBranchId;
  Future<String?> getActiveBranchName() async => _activeBranchName;
  String? get userId => _userId;
  String? get username => _username;
  List<String> get roles => _roles;
  String? get activeWorkshopId => _activeWorkshopId;
  String? get activeBranchId => _activeBranchId;
  String? get activeBranchName => _activeBranchName;

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get hasActiveBranch => _activeBranchId != null && _activeBranchId!.isNotEmpty;

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    required List<String> roles,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userId = userId;
    _username = username;
    _roles = roles;

    await _persistSetting(_keyAccessToken, accessToken);
    await _persistSetting(_keyRefreshToken, refreshToken);
    await _persistSetting(_keyUserId, userId);
    await _persistSetting(_keyUsername, username);
    await _persistSetting(_keyRoles, jsonEncode(roles));
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _persistSetting(_keyAccessToken, accessToken);
    await _persistSetting(_keyRefreshToken, refreshToken);
  }

  Future<void> setActiveWorkshop(String workshopId) async {
    _activeWorkshopId = workshopId;
    await _persistSetting(_keyWorkshopId, workshopId);
  }

  Future<void> setActiveBranch({
    required String branchId,
    required String branchName,
  }) async {
    _activeBranchId = branchId;
    _activeBranchName = branchName;
    await _persistSetting(_keyBranchId, branchId);
    await _persistSetting(_keyBranchName, branchName);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _username = null;
    _roles = [];
    _activeWorkshopId = null;
    _activeBranchId = null;
    _activeBranchName = null;

    if (appDatabase != null) {
      try {
        final db = await appDatabase!.database;
        await db.delete('app_settings');
      } catch (_) {
        // Ignored during testing
      }
    }
  }
}


import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_platform_interface/types/auth_messages.dart';
import 'package:shiftiq_mobile_app_flutter/core/security/biometric_auth_service.dart';

class _FakeLocalAuth extends Fake implements LocalAuthentication {
  bool supported;
  bool canCheck;
  bool nextAuthResult = true;
  List<BiometricType> availableBiometrics = [BiometricType.fingerprint];
  PlatformException? nextException;

  _FakeLocalAuth({
    this.supported = true,
    this.canCheck = true,
  });

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      availableBiometrics;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    if (nextException != null) throw nextException!;
    return nextAuthResult;
  }
}

class _InMemorySecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      _store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _store.remove(key);
  }
}

void main() {
  group('BiometricAuthService', () {
    test('stores biometric preference independently per userId', () async {
      final service = BiometricAuthService(
        localAuth: _FakeLocalAuth(),
        secureStorage: _InMemorySecureStorage(),
      );

      expect(await service.isBiometricEnabledForUser('user-1'), isFalse);
      expect(await service.hasPromptedEnrollmentForUser('user-1'), isFalse);

      await service.setBiometricEnabled('user-1', true);

      expect(await service.isBiometricEnabledForUser('user-1'), isTrue);
      expect(await service.hasPromptedEnrollmentForUser('user-1'), isTrue);
      expect(await service.isBiometricEnabledForUser('user-2'), isFalse);
      expect(await service.hasPromptedEnrollmentForUser('user-2'), isFalse);

      await service.setBiometricEnabled('user-1', false);
      expect(await service.isBiometricEnabledForUser('user-1'), isFalse);
    });

    test('returns unavailable when device has no biometric support', () async {
      final service = BiometricAuthService(
        localAuth: _FakeLocalAuth(supported: false, canCheck: false),
        secureStorage: _InMemorySecureStorage(),
      );

      final result = await service.authenticate(reason: 'Unlock');
      expect(result.isSuccess, isFalse);
      expect(result.status, BiometricAuthStatus.unavailable);
    });

    test('returns success, cancelled, and error states cleanly', () async {
      final auth = _FakeLocalAuth();
      final service = BiometricAuthService(
        localAuth: auth,
        secureStorage: _InMemorySecureStorage(),
      );

      final ok = await service.authenticate(reason: 'Unlock');
      expect(ok.isSuccess, isTrue);

      auth.nextAuthResult = false;
      final cancelled = await service.authenticate(reason: 'Unlock');
      expect(cancelled.status, BiometricAuthStatus.cancelled);

      auth.nextException = PlatformException(code: 'LockedOut', message: 'Locked');
      final err = await service.authenticate(reason: 'Unlock');
      expect(err.status, BiometricAuthStatus.error);
      expect(err.message, 'Locked');
    });

    test('detects fingerprintOnly, faceOnly, both, and none capabilities', () async {
      final auth = _FakeLocalAuth();
      final service = BiometricAuthService(
        localAuth: auth,
        secureStorage: _InMemorySecureStorage(),
      );

      auth.availableBiometrics = [BiometricType.fingerprint];
      expect(await service.getCapability(), BiometricCapability.fingerprintOnly);

      auth.availableBiometrics = [BiometricType.face];
      expect(await service.getCapability(), BiometricCapability.faceOnly);

      auth.availableBiometrics = [BiometricType.fingerprint, BiometricType.face];
      expect(await service.getCapability(), BiometricCapability.both);

      auth.availableBiometrics = [];
      auth.supported = true;
      expect(await service.getCapability(), BiometricCapability.deviceCredentialOnly);

      auth.supported = false;
      auth.canCheck = false;
      expect(await service.getCapability(), BiometricCapability.none);
    });
  });
}

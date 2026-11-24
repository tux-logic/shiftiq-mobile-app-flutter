import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric modalities actively supported and enrolled on this device.
enum BiometricCapability {
  fingerprintOnly,
  faceOnly,
  both,
  deviceCredentialOnly,
  none,
}

/// Outcome of a local biometric verification attempt.
enum BiometricAuthStatus {
  success,
  cancelled,
  unavailable,
  error,
}

class BiometricAuthResult {
  final BiometricAuthStatus status;
  final String? message;

  const BiometricAuthResult({required this.status, this.message});

  bool get isSuccess => status == BiometricAuthStatus.success;
}

/// Manages hardware-backed biometric unlock preferences and OS prompt verification.
class BiometricAuthService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _enabledPrefix = 'shiftiq_biometric_enabled_';
  static const String _promptedPrefix = 'shiftiq_biometric_prompted_';

  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Returns true if the device has biometric hardware or device credential lock.
  Future<bool> isDeviceSupported() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported || canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Detects which biometric modalities are enrolled on this device.
  Future<BiometricCapability> getCapability() async {
    try {
      final types = await _localAuth.getAvailableBiometrics();
      final hasFace = types.contains(BiometricType.face);
      final hasFingerprint =
          types.contains(BiometricType.fingerprint) ||
          types.contains(BiometricType.strong);

      if (hasFace && hasFingerprint) return BiometricCapability.both;
      if (hasFace) return BiometricCapability.faceOnly;
      if (hasFingerprint) return BiometricCapability.fingerprintOnly;

      final supported = await isDeviceSupported();
      return supported
          ? BiometricCapability.deviceCredentialOnly
          : BiometricCapability.none;
    } catch (_) {
      return BiometricCapability.none;
    }
  }

  /// Returns whether biometric unlock is enabled for [userId].
  Future<bool> isBiometricEnabledForUser(String userId) async {
    if (userId.trim().isEmpty) return false;
    try {
      final value = await _secureStorage.read(key: '$_enabledPrefix$userId');
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Persists the biometric unlock preference for [userId] in secure storage.
  Future<void> setBiometricEnabled(String userId, bool enabled) async {
    if (userId.trim().isEmpty) return;
    try {
      if (enabled) {
        await _secureStorage.write(
          key: '$_enabledPrefix$userId',
          value: 'true',
        );
      } else {
        await _secureStorage.delete(key: '$_enabledPrefix$userId');
      }
      await markEnrollmentPrompted(userId);
    } catch (_) {
      // Ignore secure storage errors gracefully
    }
  }

  /// Returns whether [userId] was already asked to opt in after login.
  Future<bool> hasPromptedEnrollmentForUser(String userId) async {
    if (userId.trim().isEmpty) return true;
    try {
      final value = await _secureStorage.read(key: '$_promptedPrefix$userId');
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Marks that [userId] has seen the post-login biometric enrollment prompt.
  Future<void> markEnrollmentPrompted(String userId) async {
    if (userId.trim().isEmpty) return;
    try {
      await _secureStorage.write(
        key: '$_promptedPrefix$userId',
        value: 'true',
      );
    } catch (_) {
      // Ignore secure storage errors gracefully
    }
  }

  /// Prompts the OS biometric / device credential dialog.
  Future<BiometricAuthResult> authenticate({required String reason}) async {
    try {
      final supported = await isDeviceSupported();
      if (!supported) {
        return const BiometricAuthResult(
          status: BiometricAuthStatus.unavailable,
          message: 'Biometric authentication is not available on this device.',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        return const BiometricAuthResult(status: BiometricAuthStatus.success);
      }
      return const BiometricAuthResult(status: BiometricAuthStatus.cancelled);
    } on PlatformException catch (e) {
      return BiometricAuthResult(
        status: BiometricAuthStatus.error,
        message: e.message ?? e.code,
      );
    } catch (e) {
      return BiometricAuthResult(
        status: BiometricAuthStatus.error,
        message: e.toString(),
      );
    }
  }
}

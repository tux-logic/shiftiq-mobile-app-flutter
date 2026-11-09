import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/identity_validation.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/repositories/shared_repository.dart';

/// Application use case managing Peruvian identity document validations (RENIEC, SUNAT, Migraciones).
class ManageIdentityValidations {
  final SharedRepository repository;

  static final RegExp _dniRegex = RegExp(r'^\d{8}$');
  static final RegExp _rucRegex = RegExp(r'^(10|20)\d{9}$');
  static final RegExp _ceRegex = RegExp(r'^[a-zA-Z0-9]{7,12}$');

  ManageIdentityValidations({required this.repository});

  /// Looks up an identity document with pre-flight format validation.
  Future<IdentityValidationResult> lookup({
    required IdentityDocumentType type,
    required String documentNumber,
  }) async {
    validateDocumentFormat(type: type, documentNumber: documentNumber);

    return repository.lookupIdentity(
      type: type,
      documentNumber: documentNumber.trim(),
    );
  }

  /// Specialized lookup for natural person DNI (RENIEC).
  Future<DniValidationResult> lookupDni(String dni) async {
    final result = await lookup(
      type: IdentityDocumentType.dni,
      documentNumber: dni,
    );
    if (result is DniValidationResult) {
      return result;
    }
    throw FormatException(
      'Expected DniValidationResult but received ${result.runtimeType}',
    );
  }

  /// Specialized lookup for corporate/business RUC (SUNAT).
  Future<RucValidationResult> lookupRuc(String ruc) async {
    final result = await lookup(
      type: IdentityDocumentType.ruc,
      documentNumber: ruc,
    );
    if (result is RucValidationResult) {
      return result;
    }
    throw FormatException(
      'Expected RucValidationResult but received ${result.runtimeType}',
    );
  }

  /// Specialized lookup for foreigner Carné de Extranjería (Migraciones).
  Future<CeValidationResult> lookupCe(String ce) async {
    final result = await lookup(
      type: IdentityDocumentType.ce,
      documentNumber: ce,
    );
    if (result is CeValidationResult) {
      return result;
    }
    throw FormatException(
      'Expected CeValidationResult but received ${result.runtimeType}',
    );
  }

  /// Validates syntax constraints for identity documents before issuing remote requests.
  void validateDocumentFormat({
    required IdentityDocumentType type,
    required String documentNumber,
  }) {
    final trimmed = documentNumber.trim();

    switch (type) {
      case IdentityDocumentType.dni:
        if (!_dniRegex.hasMatch(trimmed)) {
          throw ValidationException(
            message:
                'Invalid DNI format. A DNI must contain exactly 8 numeric digits.',
          );
        }
      case IdentityDocumentType.ruc:
        if (!_rucRegex.hasMatch(trimmed)) {
          throw ValidationException(
            message:
                'Invalid RUC format. A RUC must contain exactly 11 numeric digits starting with 10 or 20.',
          );
        }
      case IdentityDocumentType.ce:
        if (!_ceRegex.hasMatch(trimmed)) {
          throw ValidationException(
            message:
                'Invalid Carné de Extranjería format. A CE must contain between 7 and 12 alphanumeric characters.',
          );
        }
    }
  }

  /// Quick syntax check returning a boolean without throwing an exception.
  bool isValidDocumentNumber({
    required IdentityDocumentType type,
    required String documentNumber,
  }) {
    final trimmed = documentNumber.trim();
    return switch (type) {
      IdentityDocumentType.dni => _dniRegex.hasMatch(trimmed),
      IdentityDocumentType.ruc => _rucRegex.hasMatch(trimmed),
      IdentityDocumentType.ce => _ceRegex.hasMatch(trimmed),
    };
  }
}

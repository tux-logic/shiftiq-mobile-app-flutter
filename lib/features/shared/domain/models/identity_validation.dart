import 'package:flutter/foundation.dart';

/// Supported Peruvian identity document types.
enum IdentityDocumentType {
  dni('DNI'),
  ruc('RUC'),
  ce('CE');

  final String code;
  const IdentityDocumentType(this.code);

  static IdentityDocumentType fromCode(String code) {
    final upper = code.trim().toUpperCase();
    return switch (upper) {
      'DNI' => IdentityDocumentType.dni,
      'RUC' => IdentityDocumentType.ruc,
      'CE' || 'CEE' => IdentityDocumentType.ce,
      _ => throw ArgumentError('Unsupported identity document type: $code'),
    };
  }
}

/// Base sealed class for identity validation results across official registries.
@immutable
sealed class IdentityValidationResult {
  final IdentityDocumentType documentType;
  final String documentNumber;
  final bool verified;
  final String source;

  const IdentityValidationResult({
    required this.documentType,
    required this.documentNumber,
    required this.verified,
    required this.source,
  });
}

/// DNI identity validation result from RENIEC.
@immutable
class DniValidationResult extends IdentityValidationResult {
  final String firstName;
  final String lastName;
  final String fullName;

  const DniValidationResult({
    required super.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required super.verified,
    required super.source,
  }) : super(documentType: IdentityDocumentType.dni);

  DniValidationResult copyWith({
    String? documentNumber,
    String? firstName,
    String? lastName,
    String? fullName,
    bool? verified,
    String? source,
  }) {
    return DniValidationResult(
      documentNumber: documentNumber ?? this.documentNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      verified: verified ?? this.verified,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DniValidationResult &&
          runtimeType == other.runtimeType &&
          documentNumber == other.documentNumber &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          fullName == other.fullName &&
          verified == other.verified &&
          source == other.source;

  @override
  int get hashCode => Object.hash(
        documentNumber,
        firstName,
        lastName,
        fullName,
        verified,
        source,
      );

  @override
  String toString() =>
      'DniValidationResult(dni: $documentNumber, fullName: $fullName, verified: $verified, source: $source)';
}

/// RUC corporate/business identity validation result from SUNAT.
@immutable
class RucValidationResult extends IdentityValidationResult {
  final String businessName;
  final String? tradeName;
  final String address;
  final String condition;
  final String status;

  const RucValidationResult({
    required super.documentNumber,
    required this.businessName,
    this.tradeName,
    required this.address,
    required this.condition,
    required this.status,
    required super.verified,
    required super.source,
  }) : super(documentType: IdentityDocumentType.ruc);

  bool get isActive => status.trim().toUpperCase() == 'ACTIVO';
  bool get isHabido => condition.trim().toUpperCase() == 'HABIDO';

  RucValidationResult copyWith({
    String? documentNumber,
    String? businessName,
    String? tradeName,
    String? address,
    String? condition,
    String? status,
    bool? verified,
    String? source,
  }) {
    return RucValidationResult(
      documentNumber: documentNumber ?? this.documentNumber,
      businessName: businessName ?? this.businessName,
      tradeName: tradeName ?? this.tradeName,
      address: address ?? this.address,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      verified: verified ?? this.verified,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RucValidationResult &&
          runtimeType == other.runtimeType &&
          documentNumber == other.documentNumber &&
          businessName == other.businessName &&
          tradeName == other.tradeName &&
          address == other.address &&
          condition == other.condition &&
          status == other.status &&
          verified == other.verified &&
          source == other.source;

  @override
  int get hashCode => Object.hash(
        documentNumber,
        businessName,
        tradeName,
        address,
        condition,
        status,
        verified,
        source,
      );

  @override
  String toString() =>
      'RucValidationResult(ruc: $documentNumber, businessName: $businessName, status: $status, condition: $condition, verified: $verified, source: $source)';
}

/// Carné de Extranjería validation result from Migraciones.
@immutable
class CeValidationResult extends IdentityValidationResult {
  final String firstName;
  final String lastName;
  final String fullName;
  final String nationality;

  const CeValidationResult({
    required super.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.nationality,
    required super.verified,
    required super.source,
  }) : super(documentType: IdentityDocumentType.ce);

  CeValidationResult copyWith({
    String? documentNumber,
    String? firstName,
    String? lastName,
    String? fullName,
    String? nationality,
    bool? verified,
    String? source,
  }) {
    return CeValidationResult(
      documentNumber: documentNumber ?? this.documentNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      nationality: nationality ?? this.nationality,
      verified: verified ?? this.verified,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CeValidationResult &&
          runtimeType == other.runtimeType &&
          documentNumber == other.documentNumber &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          fullName == other.fullName &&
          nationality == other.nationality &&
          verified == other.verified &&
          source == other.source;

  @override
  int get hashCode => Object.hash(
        documentNumber,
        firstName,
        lastName,
        fullName,
        nationality,
        verified,
        source,
      );

  @override
  String toString() =>
      'CeValidationResult(ce: $documentNumber, fullName: $fullName, nationality: $nationality, verified: $verified, source: $source)';
}

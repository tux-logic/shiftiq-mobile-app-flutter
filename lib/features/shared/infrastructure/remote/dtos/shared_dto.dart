import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/identity_validation.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/media_upload.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/system_health.dart';

/// Data Transfer Object for Root Ping Response.
class PingResponseDto {
  final String status;
  final String app;
  final String docs;

  const PingResponseDto({
    required this.status,
    required this.app,
    required this.docs,
  });

  factory PingResponseDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'status': final String status,
        'app': final String app,
        'docs': final String docs,
      } =>
        PingResponseDto(status: status, app: app, docs: docs),
      _ => PingResponseDto(
          status: json['status']?.toString() ?? 'DOWN',
          app: json['app']?.toString() ?? 'ShiftIQ Platform API',
          docs: json['docs']?.toString() ?? '/swagger-ui.html',
        ),
    };
  }

  PingResponse toDomain() => PingResponse(
        status: status,
        app: app,
        docs: docs,
      );
}

/// Data Transfer Object for Health Check Probe.
class SystemHealthDto {
  final String status;

  const SystemHealthDto({
    required this.status,
  });

  factory SystemHealthDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'status': final String status} => SystemHealthDto(status: status),
      _ => SystemHealthDto(status: json['status']?.toString() ?? 'DOWN'),
    };
  }

  SystemHealth toDomain() => SystemHealth(status: status);
}

/// Data Transfer Object for Media Upload Result.
class MediaUploadResultDto {
  final String url;
  final String? publicId;
  final int? bytes;
  final String? format;
  final String? createdAt;

  const MediaUploadResultDto({
    required this.url,
    this.publicId,
    this.bytes,
    this.format,
    this.createdAt,
  });

  factory MediaUploadResultDto.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['url'] ?? json['imageUrl'] ?? '';
    final rawPublicId = json['publicId']?.toString();
    final rawBytes = json['bytes'] is int
        ? json['bytes'] as int
        : int.tryParse(json['bytes']?.toString() ?? '');
    final rawFormat = json['format']?.toString();
    final rawCreatedAt = json['createdAt']?.toString();

    return MediaUploadResultDto(
      url: rawUrl.toString(),
      publicId: rawPublicId,
      bytes: rawBytes,
      format: rawFormat,
      createdAt: rawCreatedAt,
    );
  }

  MediaUploadResult toDomain() {
    DateTime? parsedCreatedAt;
    if (createdAt != null && createdAt!.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAt!);
    }
    return MediaUploadResult(
      url: url,
      publicId: publicId,
      bytes: bytes,
      format: format,
      createdAt: parsedCreatedAt,
    );
  }
}

/// Base Data Transfer Object for Identity Validations.
sealed class IdentityValidationResultDto {
  final String type;
  final String documentNumber;
  final bool verified;
  final String source;

  const IdentityValidationResultDto({
    required this.type,
    required this.documentNumber,
    required this.verified,
    required this.source,
  });

  factory IdentityValidationResultDto.fromJson(Map<String, dynamic> json) {
    final docType = (json['type'] ?? '').toString().toUpperCase();
    return switch (docType) {
      'DNI' => DniValidationDto.fromJson(json),
      'RUC' => RucValidationDto.fromJson(json),
      'CE' || 'CEE' => CeValidationDto.fromJson(json),
      _ => throw FormatException(
          'Unsupported identity validation document type: $docType',
        ),
    };
  }

  IdentityValidationResult toDomain();
}

/// DTO for DNI identity query.
class DniValidationDto extends IdentityValidationResultDto {
  final String firstName;
  final String lastName;
  final String fullName;

  const DniValidationDto({
    required super.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required super.verified,
    required super.source,
  }) : super(type: 'DNI');

  factory DniValidationDto.fromJson(Map<String, dynamic> json) {
    return DniValidationDto(
      documentNumber: json['documentNumber']?.toString() ??
          json['dni']?.toString() ??
          '',
      firstName: json['firstName']?.toString() ??
          json['nombres']?.toString() ??
          '',
      lastName: json['lastName']?.toString() ??
          json['apellidoPaterno']?.toString() ??
          '',
      fullName: json['fullName']?.toString() ??
          json['nombreCompleto']?.toString() ??
          '',
      verified: json['verified'] == true || json['verified'] == 'true',
      source: json['source']?.toString() ?? 'RENIEC',
    );
  }

  @override
  DniValidationResult toDomain() => DniValidationResult(
        documentNumber: documentNumber,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName.isNotEmpty
            ? fullName
            : '$firstName $lastName'.trim(),
        verified: verified,
        source: source,
      );
}

/// DTO for RUC identity query.
class RucValidationDto extends IdentityValidationResultDto {
  final String businessName;
  final String? tradeName;
  final String address;
  final String condition;
  final String status;

  const RucValidationDto({
    required super.documentNumber,
    required this.businessName,
    this.tradeName,
    required this.address,
    required this.condition,
    required this.status,
    required super.verified,
    required super.source,
  }) : super(type: 'RUC');

  factory RucValidationDto.fromJson(Map<String, dynamic> json) {
    return RucValidationDto(
      documentNumber: json['documentNumber']?.toString() ??
          json['ruc']?.toString() ??
          '',
      businessName: json['businessName']?.toString() ??
          json['razonSocial']?.toString() ??
          '',
      tradeName: json['tradeName']?.toString(),
      address: json['address']?.toString() ??
          json['direccion']?.toString() ??
          '',
      condition: json['condition']?.toString() ??
          json['condicion']?.toString() ??
          'HABIDO',
      status: json['status']?.toString() ??
          json['estado']?.toString() ??
          'ACTIVO',
      verified: json['verified'] == true || json['verified'] == 'true',
      source: json['source']?.toString() ?? 'SUNAT',
    );
  }

  @override
  RucValidationResult toDomain() => RucValidationResult(
        documentNumber: documentNumber,
        businessName: businessName,
        tradeName: tradeName,
        address: address,
        condition: condition,
        status: status,
        verified: verified,
        source: source,
      );
}

/// DTO for CE identity query.
class CeValidationDto extends IdentityValidationResultDto {
  final String firstName;
  final String lastName;
  final String fullName;
  final String nationality;

  const CeValidationDto({
    required super.documentNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.nationality,
    required super.verified,
    required super.source,
  }) : super(type: 'CE');

  factory CeValidationDto.fromJson(Map<String, dynamic> json) {
    return CeValidationDto(
      documentNumber: json['documentNumber']?.toString() ??
          json['ce']?.toString() ??
          '',
      firstName: json['firstName']?.toString() ??
          json['nombres']?.toString() ??
          '',
      lastName: json['lastName']?.toString() ??
          json['apellidoPaterno']?.toString() ??
          '',
      fullName: json['fullName']?.toString() ??
          json['nombreCompleto']?.toString() ??
          '',
      nationality: json['nationality']?.toString() ??
          json['nacionalidad']?.toString() ??
          '',
      verified: json['verified'] == true || json['verified'] == 'true',
      source: json['source']?.toString() ?? 'MIGRACIONES',
    );
  }

  @override
  CeValidationResult toDomain() => CeValidationResult(
        documentNumber: documentNumber,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName.isNotEmpty
            ? fullName
            : '$firstName $lastName'.trim(),
        nationality: nationality,
        verified: verified,
        source: source,
      );
}

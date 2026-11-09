import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/application/usecases/manage_identity_validations.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/application/usecases/manage_media_uploads.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/application/usecases/manage_system_health.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/shared_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/infrastructure/remote/dtos/shared_dto.dart';

class MockSharedRepository implements SharedRepository {
  bool shouldFailPing = false;
  bool shouldFailHealth = false;
  bool returnDownHealth = false;

  final Map<String, IdentityValidationResult> mockIdentities = {};
  final List<Map<String, dynamic>> uploadedFiles = [];

  MockSharedRepository() {
    _seedIdentities();
  }

  void _seedIdentities() {
    mockIdentities['48765432'] = const DniValidationResult(
      documentNumber: '48765432',
      firstName: 'María',
      lastName: 'Fernández',
      fullName: 'María Fernández',
      verified: true,
      source: 'RENIEC',
    );

    mockIdentities['20549876123'] = const RucValidationResult(
      documentNumber: '20549876123',
      businessName: 'EMPRESA EJEMPLO S.A.C.',
      tradeName: 'Ejemplo Corp',
      address: 'AV. PRIMAVERA 1234, SANTIAGO DE SURCO, LIMA',
      condition: 'HABIDO',
      status: 'ACTIVO',
      verified: true,
      source: 'SUNAT',
    );

    mockIdentities['001234567'] = const CeValidationResult(
      documentNumber: '001234567',
      firstName: 'Juan',
      lastName: 'Pérez',
      fullName: 'Juan Pérez',
      nationality: 'VENEZUELA',
      verified: true,
      source: 'MIGRACIONES',
    );
  }

  @override
  Future<PingResponse> pingRoot() async {
    if (shouldFailPing) {
      throw NetworkException(details: 'Connection timed out');
    }
    return const PingResponse(
      status: 'UP',
      app: 'ShiftIQ Platform API',
      docs: '/swagger-ui.html',
    );
  }

  @override
  Future<SystemHealth> checkHealth() async {
    if (shouldFailHealth) {
      throw ServerException(message: 'Service Unavailable', statusCode: 503);
    }
    return SystemHealth(status: returnDownHealth ? 'DOWN' : 'UP');
  }

  @override
  Future<MediaUploadResult> uploadImage({
    required List<int> fileBytes,
    required String fileName,
    String? folder,
  }) async {
    uploadedFiles.add({
      'fileName': fileName,
      'bytesLength': fileBytes.length,
      'folder': folder,
    });

    final targetFolder = folder ?? 'uploads';
    return MediaUploadResult(
      url:
          'https://res.cloudinary.com/shiftiq/image/upload/v1728329482/$targetFolder/$fileName',
      publicId: '$targetFolder/${fileName.split('.').first}',
      bytes: fileBytes.length,
      format: fileName.split('.').last,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<IdentityValidationResult> lookupIdentity({
    required IdentityDocumentType type,
    required String documentNumber,
  }) async {
    final result = mockIdentities[documentNumber];
    if (result != null) {
      return result;
    }
    throw NotFoundException(
      message: 'Document not found in official registry.',
    );
  }
}

void main() {
  group('Shared Bounded Context - Unit Tests', () {
    late MockSharedRepository repository;
    late ManageSystemHealth manageSystemHealth;
    late ManageMediaUploads manageMediaUploads;
    late ManageIdentityValidations manageIdentityValidations;

    setUp(() {
      repository = MockSharedRepository();
      manageSystemHealth = ManageSystemHealth(repository: repository);
      manageMediaUploads = ManageMediaUploads(repository: repository);
      manageIdentityValidations =
          ManageIdentityValidations(repository: repository);
    });

    group('System Health Use Case', () {
      test('pingRoot returns UP status and documentation URL', () async {
        final ping = await manageSystemHealth.pingRoot();

        expect(ping.isUp, isTrue);
        expect(ping.status, equals('UP'));
        expect(ping.app, equals('ShiftIQ Platform API'));
        expect(ping.docs, equals('/swagger-ui.html'));
      });

      test('checkHealth returns operational status', () async {
        final health = await manageSystemHealth.checkHealth();

        expect(health.isHealthy, isTrue);
        expect(health.status, equals('UP'));
      });

      test('isPlatformOperational returns true when both probes are healthy',
          () async {
        final operational = await manageSystemHealth.isPlatformOperational();
        expect(operational, isTrue);
      });

      test('isPlatformOperational returns false when health probe fails or is DOWN',
          () async {
        repository.returnDownHealth = true;
        expect(await manageSystemHealth.isPlatformOperational(), isFalse);

        repository.returnDownHealth = false;
        repository.shouldFailPing = true;
        expect(await manageSystemHealth.isPlatformOperational(), isFalse);
      });
    });

    group('Media Uploads Use Case', () {
      test('Rejects upload when file payload is empty', () async {
        expect(
          () => manageMediaUploads.uploadImage(
            fileBytes: const [],
            fileName: 'sample.png',
          ),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('empty'),
          )),
        );
      });

      test('Rejects upload when file exceeds 10MB limit', () async {
        final largeFile = List<int>.filled(10 * 1024 * 1024 + 1, 0);

        expect(
          () => manageMediaUploads.uploadImage(
            fileBytes: largeFile,
            fileName: 'big_photo.jpg',
          ),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('exceeds the maximum limit'),
          )),
        );
      });

      test('Rejects upload when filename has unsupported extension', () async {
        expect(
          () => manageMediaUploads.uploadImage(
            fileBytes: [1, 2, 3],
            fileName: 'malicious.exe',
          ),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Unsupported image format'),
          )),
        );
      });

      test('Rejects upload when filename has no extension', () async {
        expect(
          () => manageMediaUploads.uploadImage(
            fileBytes: [1, 2, 3],
            fileName: 'noextension',
          ),
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('must include a valid image extension'),
          )),
        );
      });

      test('Successfully uploads valid images across supported formats',
          () async {
        final validExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'svg', 'avif'];

        for (final ext in validExtensions) {
          final result = await manageMediaUploads.uploadImage(
            fileBytes: [10, 20, 30],
            fileName: 'photo.$ext',
          );

          expect(result.url, contains('photo.$ext'));
          expect(result.bytes, equals(3));
        }
      });

      test('Dedicated folder helpers route to correct Cloudinary folders',
          () async {
        final sampleBytes = [1, 2, 3, 4];

        final vehicleResult = await manageMediaUploads.uploadVehiclePhoto(
          fileBytes: sampleBytes,
          fileName: 'car.png',
        );
        expect(vehicleResult.url, contains('/vehicles/car.png'));

        final inspectionResult = await manageMediaUploads.uploadInspectionPhoto(
          fileBytes: sampleBytes,
          fileName: 'inspection.webp',
        );
        expect(inspectionResult.url, contains('/inspections/inspection.webp'));

        final avatarResult = await manageMediaUploads.uploadAvatarPhoto(
          fileBytes: sampleBytes,
          fileName: 'user.jpg',
        );
        expect(avatarResult.url, contains('/avatars/user.jpg'));

        final taskResult = await manageMediaUploads.uploadTaskEvidencePhoto(
          fileBytes: sampleBytes,
          fileName: 'evidence.png',
        );
        expect(taskResult.url, contains('/workorders/evidence.png'));
      });
    });

    group('Identity Validations Use Case', () {
      test('Rejects invalid DNI format before issuing network request', () async {
        expect(
          () => manageIdentityValidations.lookupDni('1234567'), // 7 digits
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('exactly 8 numeric digits'),
          )),
        );

        expect(
          () => manageIdentityValidations.lookupDni('123456789'), // 9 digits
          throwsA(isA<ValidationException>()),
        );

        expect(
          () => manageIdentityValidations.lookupDni('4876543A'), // letter
          throwsA(isA<ValidationException>()),
        );
      });

      test('Successfully looks up valid DNI in RENIEC', () async {
        final result = await manageIdentityValidations.lookupDni('48765432');

        expect(result.documentNumber, equals('48765432'));
        expect(result.firstName, equals('María'));
        expect(result.lastName, equals('Fernández'));
        expect(result.fullName, equals('María Fernández'));
        expect(result.verified, isTrue);
        expect(result.source, equals('RENIEC'));
      });

      test('Rejects invalid RUC format before issuing network request', () async {
        expect(
          () => manageIdentityValidations.lookupRuc('1054987612'), // 10 digits
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('exactly 11 numeric digits'),
          )),
        );

        expect(
          () => manageIdentityValidations.lookupRuc('30549876123'), // starts with 30
          throwsA(isA<ValidationException>()),
        );
      });

      test('Successfully looks up valid RUC in SUNAT', () async {
        final result = await manageIdentityValidations.lookupRuc('20549876123');

        expect(result.documentNumber, equals('20549876123'));
        expect(result.businessName, equals('EMPRESA EJEMPLO S.A.C.'));
        expect(result.tradeName, equals('Ejemplo Corp'));
        expect(result.address, contains('AV. PRIMAVERA 1234'));
        expect(result.status, equals('ACTIVO'));
        expect(result.isActive, isTrue);
        expect(result.condition, equals('HABIDO'));
        expect(result.isHabido, isTrue);
        expect(result.verified, isTrue);
        expect(result.source, equals('SUNAT'));
      });

      test('Rejects invalid CE format before issuing network request', () async {
        expect(
          () => manageIdentityValidations.lookupCe('12345'), // too short (<7)
          throwsA(isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('between 7 and 12 alphanumeric characters'),
          )),
        );

        expect(
          () => manageIdentityValidations.lookupCe('001234567890123'), // too long (>12)
          throwsA(isA<ValidationException>()),
        );
      });

      test('Successfully looks up valid CE in Migraciones', () async {
        final result = await manageIdentityValidations.lookupCe('001234567');

        expect(result.documentNumber, equals('001234567'));
        expect(result.firstName, equals('Juan'));
        expect(result.lastName, equals('Pérez'));
        expect(result.fullName, equals('Juan Pérez'));
        expect(result.nationality, equals('VENEZUELA'));
        expect(result.verified, isTrue);
        expect(result.source, equals('MIGRACIONES'));
      });

      test('Throws NotFoundException when document does not exist in registry',
          () async {
        expect(
          () => manageIdentityValidations.lookupDni('99999999'),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('isValidDocumentNumber returns boolean without throwing exceptions', () {
        expect(
          manageIdentityValidations.isValidDocumentNumber(
            type: IdentityDocumentType.dni,
            documentNumber: '48765432',
          ),
          isTrue,
        );
        expect(
          manageIdentityValidations.isValidDocumentNumber(
            type: IdentityDocumentType.dni,
            documentNumber: '123',
          ),
          isFalse,
        );
        expect(
          manageIdentityValidations.isValidDocumentNumber(
            type: IdentityDocumentType.ruc,
            documentNumber: '20549876123',
          ),
          isTrue,
        );
        expect(
          manageIdentityValidations.isValidDocumentNumber(
            type: IdentityDocumentType.ruc,
            documentNumber: '15549876123', // doesn't start with 10 or 20
          ),
          isFalse,
        );
        expect(
          manageIdentityValidations.isValidDocumentNumber(
            type: IdentityDocumentType.ce,
            documentNumber: '001234567',
          ),
          isTrue,
        );
        expect(
          manageIdentityValidations.isValidDocumentNumber(
            type: IdentityDocumentType.ce,
            documentNumber: 'short',
          ),
          isFalse,
        );
      });
    });

    group('DTO Pattern Matching & Serialization', () {
      test('DniValidationDto parses RENIEC JSON payload', () {
        final json = {
          'type': 'DNI',
          'documentNumber': '48765432',
          'firstName': 'María',
          'lastName': 'Fernández',
          'fullName': 'María Fernández',
          'verified': true,
          'source': 'RENIEC',
        };

        final dto = IdentityValidationResultDto.fromJson(json);
        expect(dto, isA<DniValidationDto>());

        final domain = dto.toDomain();
        expect(domain, isA<DniValidationResult>());
        expect(domain.documentNumber, equals('48765432'));
        expect(domain.source, equals('RENIEC'));
      });

      test('RucValidationDto parses SUNAT JSON payload', () {
        final json = {
          'type': 'RUC',
          'documentNumber': '20549876123',
          'businessName': 'EMPRESA EJEMPLO S.A.C.',
          'tradeName': 'Ejemplo Corp',
          'address': 'AV. PRIMAVERA 1234, SANTIAGO DE SURCO, LIMA',
          'condition': 'HABIDO',
          'status': 'ACTIVO',
          'verified': true,
          'source': 'SUNAT',
        };

        final dto = IdentityValidationResultDto.fromJson(json);
        expect(dto, isA<RucValidationDto>());

        final domain = dto.toDomain();
        expect(domain, isA<RucValidationResult>());
        expect((domain as RucValidationResult).businessName,
            equals('EMPRESA EJEMPLO S.A.C.'));
        expect(domain.isActive, isTrue);
      });

      test('CeValidationDto parses Migraciones JSON payload', () {
        final json = {
          'type': 'CE',
          'documentNumber': '001234567',
          'firstName': 'Juan',
          'lastName': 'Pérez',
          'fullName': 'Juan Pérez',
          'nationality': 'VENEZUELA',
          'verified': true,
          'source': 'MIGRACIONES',
        };

        final dto = IdentityValidationResultDto.fromJson(json);
        expect(dto, isA<CeValidationDto>());

        final domain = dto.toDomain();
        expect(domain, isA<CeValidationResult>());
        expect((domain as CeValidationResult).nationality, equals('VENEZUELA'));
      });

      test('MediaUploadResultDto parses Cloudinary JSON payload', () {
        final json = {
          'url':
              'https://res.cloudinary.com/shiftiq/image/upload/v1728329482/vehicles/sample.jpg',
          'publicId': 'vehicles/sample',
          'bytes': 204800,
          'format': 'jpg',
          'createdAt': '2026-11-09T10:00:00.000Z',
        };

        final dto = MediaUploadResultDto.fromJson(json);
        final domain = dto.toDomain();

        expect(domain.url, contains('vehicles/sample.jpg'));
        expect(domain.bytes, equals(204800));
        expect(domain.format, equals('jpg'));
        expect(domain.createdAt?.year, equals(2026));
      });

      test('PingResponseDto and SystemHealthDto parse status endpoints', () {
        final pingDto = PingResponseDto.fromJson({
          'status': 'UP',
          'app': 'ShiftIQ Platform API',
          'docs': '/swagger-ui.html',
        });
        expect(pingDto.toDomain().isUp, isTrue);

        final healthDto = SystemHealthDto.fromJson({'status': 'UP'});
        expect(healthDto.toDomain().isHealthy, isTrue);
      });
    });
  });
}

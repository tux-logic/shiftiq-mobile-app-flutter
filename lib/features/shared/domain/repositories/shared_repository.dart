import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/identity_validation.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/media_upload.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/system_health.dart';

/// Contract for system health probes, media uploads, and identity validations.
abstract interface class SharedRepository {
  /// Pings the root endpoint to verify platform connectivity.
  Future<PingResponse> pingRoot();

  /// Performs a readiness probe against the system health endpoint.
  Future<SystemHealth> checkHealth();

  /// Uploads an image file to Cloudinary via backend multipart proxy.
  Future<MediaUploadResult> uploadImage({
    required List<int> fileBytes,
    required String fileName,
    String? folder,
  });

  /// Looks up official identity document records from RENIEC, SUNAT, or Migraciones.
  Future<IdentityValidationResult> lookupIdentity({
    required IdentityDocumentType type,
    required String documentNumber,
  });
}

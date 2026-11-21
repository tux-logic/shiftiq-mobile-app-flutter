import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';

/// Remote API client for Shared Kernel endpoints (Health, Media, Identity Validations).
class SharedApi {
  final ApiClient apiClient;

  SharedApi({required this.apiClient});

  /// Verifies that the platform service is running.
  Future<dynamic> pingRoot() async {
    return apiClient.get(ApiConstants.rootPing);
  }

  /// Queries the health readiness check endpoint.
  Future<dynamic> checkHealth() async {
    return apiClient.get(ApiConstants.health);
  }

  /// Uploads an image file to Cloudinary via backend multipart proxy.
  Future<dynamic> uploadMedia({
    required List<int> fileBytes,
    required String fileName,
    String? folder,
  }) async {
    final fields = <String, String>{};
    if (folder != null && folder.isNotEmpty) {
      fields['folder'] = folder;
    }

    return apiClient.uploadMultipart(
      ApiConstants.mediaUpload,
      fileBytes: fileBytes,
      fileName: fileName,
      fieldName: 'file',
      fields: fields.isNotEmpty ? fields : null,
    );
  }

  /// Queries official registries (RENIEC, SUNAT, Migraciones) via Factiliza.
  Future<dynamic> lookupIdentity({
    required String type,
    required String number,
  }) async {
    return apiClient.get(
      ApiConstants.identityValidationLookup,
      queryParameters: {
        'type': type,
        'number': number,
      },
    );
  }
}

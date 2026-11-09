import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/identity_validation.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/media_upload.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/system_health.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/repositories/shared_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/infrastructure/remote/dtos/shared_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/infrastructure/remote/shared_api.dart';

/// Implementation of SharedRepository coordinating remote API calls and domain mappers.
class SharedRepositoryImpl implements SharedRepository {
  final SharedApi sharedApi;

  SharedRepositoryImpl({required this.sharedApi});

  @override
  Future<PingResponse> pingRoot() async {
    final response = await sharedApi.pingRoot();
    if (response is Map<String, dynamic>) {
      return PingResponseDto.fromJson(response).toDomain();
    }
    return const PingResponse(
      status: 'UP',
      app: 'ShiftIQ Platform API',
      docs: '/swagger-ui.html',
    );
  }

  @override
  Future<SystemHealth> checkHealth() async {
    final response = await sharedApi.checkHealth();
    if (response is Map<String, dynamic>) {
      return SystemHealthDto.fromJson(response).toDomain();
    }
    return const SystemHealth(status: 'UP');
  }

  @override
  Future<MediaUploadResult> uploadImage({
    required List<int> fileBytes,
    required String fileName,
    String? folder,
  }) async {
    final response = await sharedApi.uploadMedia(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: folder,
    );
    if (response is Map<String, dynamic>) {
      return MediaUploadResultDto.fromJson(response).toDomain();
    }
    throw FormatException(
      'Unexpected response format from media upload: $response',
    );
  }

  @override
  Future<IdentityValidationResult> lookupIdentity({
    required IdentityDocumentType type,
    required String documentNumber,
  }) async {
    final response = await sharedApi.lookupIdentity(
      type: type.code,
      number: documentNumber,
    );
    if (response is Map<String, dynamic>) {
      return IdentityValidationResultDto.fromJson(response).toDomain();
    }
    throw FormatException(
      'Unexpected response format from identity lookup: $response',
    );
  }
}

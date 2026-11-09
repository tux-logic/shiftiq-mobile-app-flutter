import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/models/media_upload.dart';
import 'package:shiftiq_mobile_app_flutter/features/shared/domain/repositories/shared_repository.dart';

/// Application use case managing Cloudinary media uploads with format and size validation.
class ManageMediaUploads {
  final SharedRepository repository;

  /// Maximum allowed payload size: 10MB in bytes.
  static const int maxFileSizeInBytes = 10 * 1024 * 1024;

  /// Supported image extensions.
  static const Set<String> allowedExtensions = {
    'jpeg',
    'jpg',
    'png',
    'webp',
    'gif',
    'svg',
    'avif',
  };

  ManageMediaUploads({required this.repository});

  /// Validates file format and size constraints before delegating to repository.
  Future<MediaUploadResult> uploadImage({
    required List<int> fileBytes,
    required String fileName,
    MediaFolder folder = MediaFolder.uploads,
  }) async {
    validateFile(fileBytes: fileBytes, fileName: fileName);

    return repository.uploadImage(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: folder.folderName,
    );
  }

  /// Uploads client vehicle inspection photo to 'vehicles' folder.
  Future<MediaUploadResult> uploadVehiclePhoto({
    required List<int> fileBytes,
    required String fileName,
  }) {
    return uploadImage(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: MediaFolder.vehicles,
    );
  }

  /// Uploads work order entry/exit inspection image to 'inspections' folder.
  Future<MediaUploadResult> uploadInspectionPhoto({
    required List<int> fileBytes,
    required String fileName,
  }) {
    return uploadImage(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: MediaFolder.inspections,
    );
  }

  /// Uploads user avatar photo to 'avatars' folder.
  Future<MediaUploadResult> uploadAvatarPhoto({
    required List<int> fileBytes,
    required String fileName,
  }) {
    return uploadImage(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: MediaFolder.avatars,
    );
  }

  /// Uploads mechanic work order task evidence to 'workorders' folder.
  Future<MediaUploadResult> uploadTaskEvidencePhoto({
    required List<int> fileBytes,
    required String fileName,
  }) {
    return uploadImage(
      fileBytes: fileBytes,
      fileName: fileName,
      folder: MediaFolder.workorders,
    );
  }

  /// Performs client-side validation of file existence, format, and payload limits.
  void validateFile({
    required List<int> fileBytes,
    required String fileName,
  }) {
    if (fileBytes.isEmpty) {
      throw ValidationException(
        message: 'The selected file is empty. Please choose a valid image.',
      );
    }

    if (fileBytes.length > maxFileSizeInBytes) {
      throw ValidationException(
        message:
            'File size exceeds the maximum limit of 10MB (${fileBytes.length} bytes).',
      );
    }

    final trimmedName = fileName.trim();
    if (trimmedName.isEmpty) {
      throw ValidationException(
        message: 'File name cannot be empty.',
      );
    }

    final dotIndex = trimmedName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == trimmedName.length - 1) {
      throw ValidationException(
        message: 'File name must include a valid image extension.',
      );
    }

    final extension = trimmedName.substring(dotIndex + 1).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw ValidationException(
        message:
            'Unsupported image format "$extension". Allowed formats: ${allowedExtensions.join(', ')}.',
      );
    }
  }
}

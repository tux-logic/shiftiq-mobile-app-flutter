import 'package:flutter/foundation.dart';

/// Target folders for organizing Cloudinary media assets.
enum MediaFolder {
  vehicles('vehicles'),
  inspections('inspections'),
  products('products'),
  avatars('avatars'),
  workorders('workorders'),
  uploads('uploads');

  final String folderName;
  const MediaFolder(this.folderName);

  static MediaFolder fromString(String? value) {
    if (value == null) return MediaFolder.uploads;
    return MediaFolder.values.firstWhere(
      (folder) => folder.folderName.toLowerCase() == value.toLowerCase(),
      orElse: () => MediaFolder.uploads,
    );
  }
}

/// Represents the result of a media upload to Cloudinary.
@immutable
class MediaUploadResult {
  final String url;
  final String? publicId;
  final int? bytes;
  final String? format;
  final DateTime? createdAt;

  const MediaUploadResult({
    required this.url,
    this.publicId,
    this.bytes,
    this.format,
    this.createdAt,
  });

  MediaUploadResult copyWith({
    String? url,
    String? publicId,
    int? bytes,
    String? format,
    DateTime? createdAt,
  }) {
    return MediaUploadResult(
      url: url ?? this.url,
      publicId: publicId ?? this.publicId,
      bytes: bytes ?? this.bytes,
      format: format ?? this.format,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaUploadResult &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          publicId == other.publicId &&
          bytes == other.bytes &&
          format == other.format &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(url, publicId, bytes, format, createdAt);

  @override
  String toString() =>
      'MediaUploadResult(url: $url, publicId: $publicId, bytes: $bytes, format: $format, createdAt: $createdAt)';
}

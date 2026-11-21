import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_loading_helpers.dart';

/// Callback that uploads raw image bytes and returns the resulting public URL.
typedef CoverImageUploader = Future<String> Function(
  List<int> fileBytes,
  String fileName,
);

/// Intuitive cover photo selector for branch creation and editing.
class BranchCoverPicker extends StatefulWidget {
  final String? initialImageUrl;
  final CoverImageUploader onUploadImage;
  final ValueChanged<String?> onImageChanged;

  const BranchCoverPicker({
    super.key,
    this.initialImageUrl,
    required this.onUploadImage,
    required this.onImageChanged,
  });

  @override
  State<BranchCoverPicker> createState() => _BranchCoverPickerState();
}

class _BranchCoverPickerState extends State<BranchCoverPicker> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _localPreviewBytes;
  String? _imageUrl;
  bool _isUploading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _pickFrom(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _localPreviewBytes = bytes;
        _isUploading = true;
        _errorText = null;
      });

      final uploadedUrl = await widget.onUploadImage(bytes, picked.name);
      if (!mounted) return;

      setState(() {
        _imageUrl = uploadedUrl;
        _isUploading = false;
      });
      widget.onImageChanged(uploadedUrl);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showSourceSheet() {
    if (_isUploading) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: ShiftIQColors.primaryBlue,
                ),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFrom(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: ShiftIQColors.primaryBlue,
                ),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFrom(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasRemoteUrl = _imageUrl != null && _imageUrl!.isNotEmpty;
    final hasPreview = _localPreviewBytes != null || hasRemoteUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Branch cover photo (optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ShiftIQColors.graphiteText,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showSourceSheet,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 126,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ShiftIQColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _errorText != null
                      ? ShiftIQColors.severityCrimson
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_localPreviewBytes != null)
                    Image.memory(_localPreviewBytes!, fit: BoxFit.cover)
                  else if (hasRemoteUrl)
                    Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _EmptyCoverPlaceholder(),
                    )
                  else
                    const _EmptyCoverPlaceholder(),

                  if (hasPreview)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Change',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_isUploading)
                    Container(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.62),
                      child: const Center(
                        child: ShiftIQInlineProgress(
                          label: 'Subiendo imagen...',
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            _errorText!,
            style: const TextStyle(
              fontSize: 11.5,
              color: ShiftIQColors.severityCrimson,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyCoverPlaceholder extends StatelessWidget {
  const _EmptyCoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: ShiftIQColors.primaryBlue.withAlpha(18),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: ShiftIQColors.primaryBlue,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap to upload branch photo',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: ShiftIQColors.graphiteText,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'JPG, PNG or WEBP (max 10MB)',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Rounded thumbnail for a spare part, displaying its network image when
/// available and falling back gracefully to an inventory icon badge.
class SparePartThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;

  const SparePartThumbnail({
    super.key,
    this.imageUrl,
    this.size = 36,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final hasImage = url != null && url.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ShiftIQColors.primaryBlue.withAlpha(14),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: ShiftIQColors.borderSlate.withAlpha(140)),
        ),
        child: hasImage
            ? Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallbackIcon(),
              )
            : _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Center(
      child: Icon(
        Icons.settings_suggest_outlined,
        size: size * 0.5,
        color: ShiftIQColors.primaryBlue,
      ),
    );
  }
}

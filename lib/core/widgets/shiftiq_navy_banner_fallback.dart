import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Shared ShiftIQ navy-gradient banner fallback with a subtle watermark icon,
/// used when a branch or vehicle has no uploaded cover photo.
class ShiftIQNavyBannerFallback extends StatelessWidget {
  final IconData watermarkIcon;

  const ShiftIQNavyBannerFallback({
    super.key,
    this.watermarkIcon = Icons.store_mall_directory_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -18,
            child: Icon(
              watermarkIcon,
              size: 112,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Standard circular empty-state icon badge used across all ShiftIQ sections
/// when an API query or active filter returns no records.
class ShiftIQEmptyStateIcon extends StatelessWidget {
  const ShiftIQEmptyStateIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 28,
        color: Color(0xFF64748B),
      ),
    );
  }
}

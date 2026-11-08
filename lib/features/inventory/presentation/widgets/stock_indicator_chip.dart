import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';

class StockIndicatorChip extends StatelessWidget {
  final StockStatus status;
  final int currentStock;
  final String unit;

  const StockIndicatorChip({
    super.key,
    required this.status,
    required this.currentStock,
    this.unit = 'und',
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case StockStatus.normal:
        bg = ShiftIQColors.preventiveGreen.withAlpha(25);
        fg = ShiftIQColors.preventiveGreen;
        icon = Icons.check_circle_outline;
        break;
      case StockStatus.lowStock:
        bg = ShiftIQColors.severityAmber.withAlpha(30);
        fg = const Color(0xFFB45309); // Darker amber for contrast
        icon = Icons.warning_amber_rounded;
        break;
      case StockStatus.outOfStock:
        bg = ShiftIQColors.severityCrimson.withAlpha(25);
        fg = ShiftIQColors.severityCrimson;
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            '$currentStock $unit · ${status.label}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

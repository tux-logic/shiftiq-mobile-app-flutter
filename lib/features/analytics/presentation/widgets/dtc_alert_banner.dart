import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Compact, interactive telemetry alert strip with subtle pulsing indicator.
class DtcAlertBanner extends StatefulWidget {
  final int alertCount;
  final VoidCallback? onDetailsPressed;

  const DtcAlertBanner({
    super.key,
    required this.alertCount,
    this.onDetailsPressed,
  });

  @override
  State<DtcAlertBanner> createState() => _DtcAlertBannerState();
}

class _DtcAlertBannerState extends State<DtcAlertBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alertCount <= 0) return const SizedBox.shrink();

    final isPlural = widget.alertCount != 1;
    final label = isPlural
        ? '${widget.alertCount} vehículos con alertas DTC activas'
        : '1 vehículo con alerta DTC activa';

    return Material(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: widget.onDetailsPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ShiftIQColors.severityCrimson.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.45, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: ShiftIQColors.severityCrimson,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ShiftIQColors.severityCrimson,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

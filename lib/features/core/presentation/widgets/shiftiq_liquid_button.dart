import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Translucent Liquid Glass pill/rectangular button with visible ShiftIQ
/// ice-blue glass tint, crisp border, and high-contrast primary-blue text.
class ShiftIQLiquidButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool expand;

  const ShiftIQLiquidButton({
    super.key,
    this.label,
    this.icon,
    required this.onPressed,
    this.height = 44,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return RepaintBoundary(
      child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: ShiftIQColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: radius,
              child: Container(
                width: expand ? double.infinity : null,
                height: height,
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShiftIQColors.primaryBlue.withValues(alpha: 0.09),
                      ShiftIQColors.accentSkyBlue.withValues(alpha: 0.20),
                    ],
                  ),
                  border: Border.all(
                    color: ShiftIQColors.primaryBlue.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: ShiftIQColors.primaryBlue),
                      if (label != null) const SizedBox(width: 8),
                    ],
                    if (label != null)
                      Text(
                        label!,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.primaryBlue,
                          letterSpacing: 0.1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Circular Liquid Glass icon button supporting both light map surfaces and
/// dark-scrimmed banner surfaces (`onDarkBackground: true`).
class ShiftIQLiquidIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final bool isPrimary;
  final bool onDarkBackground;

  const ShiftIQLiquidIconButton({
    super.key,
    required this.icon,
    this.tooltip,
    required this.onPressed,
    this.size = 42,
    this.iconSize = 20,
    this.isPrimary = false,
    this.onDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = onDarkBackground
        ? Colors.white
        : (isPrimary ? ShiftIQColors.primaryBlue : ShiftIQColors.graphiteText);

    final button = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(
              alpha: onDarkBackground ? 0.18 : 0.10,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: onDarkBackground
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.48),
                            (isPrimary
                                    ? ShiftIQColors.primaryBlue
                                    : ShiftIQColors.accentSkyBlue)
                                .withValues(alpha: 0.16),
                          ],
                        ),
                  color: onDarkBackground
                      ? Colors.white.withValues(alpha: 0.22)
                      : null,
                  border: Border.all(
                    color: onDarkBackground
                        ? Colors.white.withValues(alpha: 0.42)
                        : ShiftIQColors.primaryBlue.withValues(alpha: 0.28),
                    width: 1.2,
                  ),
                ),
                child: Icon(icon, size: iconSize, color: foregroundColor),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

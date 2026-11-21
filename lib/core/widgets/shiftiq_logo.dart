import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

enum LogoSize {
  small(44, 18, 12),
  medium(72, 26, 14),
  large(96, 32, 16);

  final double boxSize;
  final double titleSize;
  final double subtitleSize;

  const LogoSize(this.boxSize, this.titleSize, this.subtitleSize);
}

/// Official ShiftIQ Workshop branded logo with modern automotive engineering aesthetics.
class ShiftIqLogo extends StatelessWidget {
  final LogoSize size;
  final bool showText;
  final bool isDark;

  const ShiftIqLogo({
    super.key,
    this.size = LogoSize.medium,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: size.boxSize,
      height: size.boxSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ShiftIQColors.primaryBlue,
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(size.boxSize * 0.25),
        border: Border.all(
          color: ShiftIQColors.accentSkyBlue.withAlpha(120),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ShiftIQColors.accentSkyBlue.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle diagnostic grid/pulse
          Positioned(
            right: 4,
            bottom: 4,
            child: Icon(
              Icons.sensors,
              size: size.boxSize * 0.35,
              color: ShiftIQColors.accentSkyBlue.withAlpha(60),
            ),
          ),
          // Core automotive car repair icon
          Icon(
            Icons.car_repair,
            color: Colors.white,
            size: size.boxSize * 0.55,
          ),
        ],
      ),
    );

    if (!showText) return iconBox;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconBox,
        const SizedBox(height: 14),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: size.titleSize,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : ShiftIQColors.primaryBlue,
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(text: 'Shift'),
              const TextSpan(
                text: 'IQ',
                style: TextStyle(
                  color: ShiftIQColors.accentSkyBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: ' Workshop',
                style: TextStyle(
                  fontSize: size.titleSize * 0.82,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : ShiftIQColors.graphiteText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Gestión Inteligente de Talleres Automotrices',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size.subtitleSize,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}


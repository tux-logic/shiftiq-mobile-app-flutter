import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_top_progress_bar.dart';

/// Smooth 220ms fade-and-slide transition used when cold-start content arrives,
/// replacing blocking spinners and gray skeleton placeholders.
class ShiftIQContentTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ShiftIQContentTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: child,
    );
  }
}

/// Spinner-free inline action label with an animated horizontal sweep bar
/// for buttons, uploaders, and submit controls.
class ShiftIQInlineProgress extends StatelessWidget {
  final String label;
  final Color textColor;
  final double fontSize;

  const ShiftIQInlineProgress({
    super.key,
    required this.label,
    this.textColor = Colors.white,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const SizedBox(
          width: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: ShiftIQTopProgressBar(isLoading: true, height: 2.5),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Sleek 2.5px non-blocking top gradient progress bar used across ShiftIQ
/// screens during background fetches and Stale-While-Revalidate refreshes.
class ShiftIQTopProgressBar extends StatefulWidget {
  final bool isLoading;
  final double height;

  const ShiftIQTopProgressBar({
    super.key,
    required this.isLoading,
    this.height = 2.5,
  });

  @override
  State<ShiftIQTopProgressBar> createState() => _ShiftIQTopProgressBarState();
}

class _ShiftIQTopProgressBarState extends State<ShiftIQTopProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShiftIQTopProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ClipRect(
          child: ColoredBox(
            color: ShiftIQColors.primaryBlue.withValues(alpha: 0.10),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TopSweepPainter(progress: _controller.value),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopSweepPainter extends CustomPainter {
  final double progress;

  const _TopSweepPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final barWidth = size.width * 0.42;
    final startX = -barWidth + (size.width + barWidth) * progress;
    final rect = Rect.fromLTWH(startX, 0, barWidth, size.height);

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          ShiftIQColors.primaryBlue,
          ShiftIQColors.secondaryTeal,
          ShiftIQColors.accentSkyBlue,
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TopSweepPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

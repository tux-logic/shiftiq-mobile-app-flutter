import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tactile press-scale wrapper with subtle haptic feedback shared across all
/// interactive cards in every role view.
class ShiftIQTactileCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool enableHaptics;

  const ShiftIQTactileCard({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.975,
    this.enableHaptics = true,
  });

  @override
  State<ShiftIQTactileCard> createState() => _ShiftIQTactileCardState();
}

class _ShiftIQTactileCardState extends State<ShiftIQTactileCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        if (widget.enableHaptics) {
          HapticFeedback.selectionClick();
        }
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

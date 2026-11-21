import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Semantic variants for [ShiftIQToast].
enum ShiftIQToastType {
  success,
  error,
  warning,
  info,
}

/// Top-floating minimalist pill toast with smooth slide-and-fade animation.
///
/// Designed for errors, warnings, and non-visible background actions
/// (e.g. clipboard copy, PDF download, password reset) without colliding
/// with the bottom floating navigation bar.
class ShiftIQToast {
  ShiftIQToast._();

  static OverlayEntry? _activeEntry;

  /// Displays a floating pill toast near the top of the screen.
  static void show(
    BuildContext context, {
    required String message,
    ShiftIQToastType type = ShiftIQToastType.info,
    Duration duration = const Duration(milliseconds: 2600),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _activeEntry?.remove();
    _activeEntry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _ShiftIQToastOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () {
          if (_activeEntry == entry) {
            entry.remove();
            _activeEntry = null;
          }
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }
}

class _ShiftIQToastOverlay extends StatefulWidget {
  final String message;
  final ShiftIQToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ShiftIQToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ShiftIQToastOverlay> createState() => _ShiftIQToastOverlayState();
}

class _ShiftIQToastOverlayState extends State<_ShiftIQToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (Color accent, IconData icon) = switch (widget.type) {
      ShiftIQToastType.success => (
          ShiftIQColors.preventiveGreen,
          Icons.check_rounded,
        ),
      ShiftIQToastType.error => (
          ShiftIQColors.severityCrimson,
          Icons.error_outline_rounded,
        ),
      ShiftIQToastType.warning => (
          ShiftIQColors.severityOrange,
          Icons.warning_amber_rounded,
        ),
      ShiftIQToastType.info => (
          ShiftIQColors.primaryBlue,
          Icons.info_outline_rounded,
        ),
    };

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.up,
              onDismissed: (_) {
                _dismissTimer?.cancel();
                widget.onDismissed();
              },
              child: Center(
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ShiftIQColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 15, color: accent),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ShiftIQColors.graphiteText,
                            ),
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
      ),
    );
  }
}

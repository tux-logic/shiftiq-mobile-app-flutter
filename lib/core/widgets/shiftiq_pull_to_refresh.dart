import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_skeleton.dart';

/// Spinner-free pull-to-refresh wrapper aligned with ShiftIQ's skeleton model.
///
/// Tracks overscroll pull distance on both Android clamping and iOS bouncing
/// scrollables, displays a minimalist pill hint while pulling, triggers light
/// haptics at the threshold, and swaps to [skeleton] while [onRefresh] runs.
class ShiftIQPullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Widget skeleton;
  final double triggerDistance;

  const ShiftIQPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.skeleton = const ShiftIQSkeletonCardList(),
    this.triggerDistance = 68.0,
  });

  @override
  State<ShiftIQPullToRefresh> createState() => _ShiftIQPullToRefreshState();
}

class _ShiftIQPullToRefreshState extends State<ShiftIQPullToRefresh> {
  double _pullExtent = 0.0;
  bool _armed = false;
  bool _isRefreshing = false;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is OverscrollNotification && notification.overscroll < 0) {
      if (notification.metrics.axis != Axis.vertical) return false;
      _updatePull(_pullExtent + (-notification.overscroll * 0.55));
    } else if (notification is ScrollUpdateNotification) {
      if (notification.metrics.axis != Axis.vertical) return false;
      if (notification.metrics.pixels < 0) {
        _updatePull(-notification.metrics.pixels);
      } else if (_pullExtent > 0 && notification.metrics.pixels > 0) {
        _resetPull();
      }
    } else if (notification is ScrollEndNotification) {
      if (_pullExtent >= widget.triggerDistance) {
        _triggerRefresh();
      } else {
        _resetPull();
      }
    }
    return false;
  }

  void _updatePull(double nextExtent) {
    final clamped = nextExtent.clamp(0.0, widget.triggerDistance * 1.4);
    final isNowArmed = clamped >= widget.triggerDistance;
    if (isNowArmed && !_armed) {
      HapticFeedback.lightImpact();
    }
    if (clamped != _pullExtent || isNowArmed != _armed) {
      setState(() {
        _pullExtent = clamped;
        _armed = isNowArmed;
      });
    }
  }

  void _resetPull() {
    if (_pullExtent == 0 && !_armed) return;
    setState(() {
      _pullExtent = 0.0;
      _armed = false;
    });
  }

  Future<void> _triggerRefresh() async {
    setState(() {
      _isRefreshing = true;
      _pullExtent = 0.0;
      _armed = false;
    });
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_pullExtent / widget.triggerDistance).clamp(0.0, 1.0);

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _isRefreshing
                ? KeyedSubtree(
                    key: const ValueKey('pull_refresh_skeleton'),
                    child: widget.skeleton,
                  )
                : KeyedSubtree(
                    key: const ValueKey('pull_refresh_content'),
                    child: widget.child,
                  ),
          ),
        ),
        if (!_isRefreshing && _pullExtent > 8)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(0, (_pullExtent * 0.25).clamp(0.0, 18.0)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _armed
                              ? ShiftIQColors.primaryBlue
                              : ShiftIQColors.borderSlate,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _armed
                                ? Icons.sync_rounded
                                : Icons.arrow_downward_rounded,
                            size: 15,
                            color: _armed
                                ? ShiftIQColors.primaryBlue
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _armed
                                ? 'Suelta para actualizar'
                                : 'Desliza para actualizar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _armed
                                  ? ShiftIQColors.primaryBlue
                                  : const Color(0xFF64748B),
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
      ],
    );
  }
}

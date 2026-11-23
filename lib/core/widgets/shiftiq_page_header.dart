import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Unified dark-navy ShiftIQ gradient header shared across role-scoped screens.
class ShiftIQPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badgeLabel;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget> actions;

  const ShiftIQPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeLabel,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(
                    minWidth: 34,
                    minHeight: 34,
                  ),
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badgeLabel != null && badgeLabel!.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(22),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha(45),
                          ),
                        ),
                        child: Text(
                          badgeLabel!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Global layout wrapper that subtly collapses [header] when scrolling down
/// and reveals it smoothly when scrolling up, maximizing vertical space across
/// all ShiftIQ screens while keeping pull-to-refresh bounce unaffected.
class ShiftIQCollapsibleHeaderBody extends StatefulWidget {
  final Widget header;
  final Widget body;

  const ShiftIQCollapsibleHeaderBody({
    super.key,
    required this.header,
    required this.body,
  });

  @override
  State<ShiftIQCollapsibleHeaderBody> createState() =>
      _ShiftIQCollapsibleHeaderBodyState();
}

class _ShiftIQCollapsibleHeaderBodyState
    extends State<ShiftIQCollapsibleHeaderBody> {
  bool _headerVisible = true;
  double _accumulatedDelta = 0;

  bool _handleScrollNotification(ScrollUpdateNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final metrics = notification.metrics;
    final delta = notification.scrollDelta ?? 0;
    if (delta == 0) return false;

    // Always keep header visible near the top or during pull-to-refresh overscroll.
    if (metrics.pixels <= 16) {
      if (!_headerVisible) {
        setState(() => _headerVisible = true);
      }
      _accumulatedDelta = 0;
      return false;
    }

    // Ignore bottom overscroll bounce.
    if (metrics.pixels >= metrics.maxScrollExtent) {
      return false;
    }

    // Reset accumulator if scroll direction reverses.
    if ((delta > 0 && _accumulatedDelta < 0) ||
        (delta < 0 && _accumulatedDelta > 0)) {
      _accumulatedDelta = 0;
    }
    _accumulatedDelta += delta;

    if (_accumulatedDelta > 18 && _headerVisible) {
      setState(() => _headerVisible = false);
      _accumulatedDelta = 0;
    } else if (_accumulatedDelta < -12 && !_headerVisible) {
      setState(() => _headerVisible = true);
      _accumulatedDelta = 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRect(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            heightFactor: _headerVisible ? 1.0 : 0.0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              opacity: _headerVisible ? 1.0 : 0.0,
              child: widget.header,
            ),
          ),
        ),
        Expanded(
          child: SafeArea(
            top: !_headerVisible,
            bottom: false,
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: _handleScrollNotification,
              child: widget.body,
            ),
          ),
        ),
      ],
    );
  }
}

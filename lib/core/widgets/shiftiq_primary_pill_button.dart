import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// High-contrast ShiftIQ Dark Navy -> Primary Blue elevated pill CTA.
class ShiftIQPrimaryPillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const ShiftIQPrimaryPillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ShiftIQColors.primaryBlue.withAlpha(75),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 19, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inherited scope broadcasting the active tab index of [MainPage] so child
/// pages inside an [IndexedStack] can animate their floating CTAs on tab entry.
class ShiftIQActiveTabScope extends InheritedWidget {
  final int activeIndex;

  const ShiftIQActiveTabScope({
    super.key,
    required this.activeIndex,
    required super.child,
  });

  static bool isTabActive(BuildContext context, int tabIndex) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ShiftIQActiveTabScope>();
    return scope == null || scope.activeIndex == tabIndex;
  }

  @override
  bool updateShouldNotify(ShiftIQActiveTabScope oldWidget) =>
      activeIndex != oldWidget.activeIndex;
}

/// Animated wrapper around [ShiftIQPrimaryPillButton] providing smooth scale +
/// fade entrance and exit transitions when [visible] toggles.
class ShiftIQAnimatedFloatingPill extends StatelessWidget {
  final bool visible;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;

  const ShiftIQAnimatedFloatingPill({
    super.key,
    required this.visible,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.only(bottom: 84),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: visible
          ? Padding(
              key: const ValueKey('fab_visible'),
              padding: padding,
              child: ShiftIQPrimaryPillButton(
                label: label,
                icon: icon,
                onPressed: onPressed,
              ),
            )
          : const SizedBox.shrink(key: ValueKey('fab_hidden')),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/models/financial_analytics_snapshot.dart';

/// Minimalist, animated pill-bar chart comparing completed work orders and appointments.
class ActivityBarChart extends StatefulWidget {
  final List<FinancialAnalyticsSnapshot> snapshots;

  const ActivityBarChart({
    super.key,
    required this.snapshots,
  });

  @override
  State<ActivityBarChart> createState() => _ActivityBarChartState();
}

class _ActivityBarChartState extends State<ActivityBarChart> {
  int? _activeIndex;
  int _animationSeed = 0;

  @override
  void didUpdateWidget(covariant ActivityBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshots != widget.snapshots) {
      _activeIndex = null;
      _animationSeed++;
    }
  }

  void _updateIndex(Offset localPosition, double width, int count) {
    if (count == 0 || width <= 0) return;
    final idx = ((localPosition.dx / width) * count)
        .floor()
        .clamp(0, count - 1);
    if (idx != _activeIndex) {
      HapticFeedback.selectionClick();
      setState(() => _activeIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = widget.snapshots.length > 14
        ? widget.snapshots.sublist(widget.snapshots.length - 14)
        : widget.snapshots;

    final selected =
        _activeIndex != null && _activeIndex! < snapshots.length
            ? snapshots[_activeIndex!]
            : null;
    final totalOrders = snapshots.fold<int>(
      0,
      (sum, item) => sum + item.completedWorkOrdersCount,
    );
    final totalAppointments = snapshots.fold<int>(
      0,
      (sum, item) => sum + item.totalAppointmentsCount,
    );

    final localeCode = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat('d MMM', localeCode);
    final caption = selected != null
        ? '${dateFmt.format(selected.snapshotDate)} · ${selected.completedWorkOrdersCount} OTs · ${selected.totalAppointmentsCount} Citas'
        : '$totalOrders OTs · $totalAppointments Citas';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actividad operativa',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        key: ValueKey<String>(caption),
                        child: Text(
                          caption,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ShiftIQColors.graphiteText,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const _LegendDot(
                color: ShiftIQColors.primaryBlue,
                label: 'OTs',
              ),
              const SizedBox(width: 12),
              const _LegendDot(
                color: ShiftIQColors.secondaryTeal,
                label: 'Citas',
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (snapshots.isEmpty)
            SizedBox(
              height: 96,
              child: Center(
                child: Text(
                  'Sin actividad registrada',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 96,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _updateIndex(
                      d.localPosition,
                      constraints.maxWidth,
                      snapshots.length,
                    ),
                    onHorizontalDragUpdate: (d) => _updateIndex(
                      d.localPosition,
                      constraints.maxWidth,
                      snapshots.length,
                    ),
                    onHorizontalDragEnd: (_) =>
                        setState(() => _activeIndex = null),
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey<int>(_animationSeed),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 620),
                      curve: Curves.easeOutCubic,
                      builder: (context, progress, _) {
                        return CustomPaint(
                          painter: _MinimalPillBarPainter(
                            snapshots: snapshots,
                            activeIndex: _activeIndex,
                            progress: progress,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _MinimalPillBarPainter extends CustomPainter {
  final List<FinancialAnalyticsSnapshot> snapshots;
  final int? activeIndex;
  final double progress;

  _MinimalPillBarPainter({
    required this.snapshots,
    required this.activeIndex,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (snapshots.isEmpty) return;

    final maxVal = snapshots.fold<int>(
      1,
      (maxSoFar, s) => math.max(
        maxSoFar,
        math.max(s.completedWorkOrdersCount, s.totalAppointmentsCount),
      ),
    );

    final baselinePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      baselinePaint,
    );

    final slotWidth = size.width / snapshots.length;
    final barWidth = math.min(6.0, math.max(3.0, slotWidth * 0.24));
    const barGap = 3.0;

    for (var i = 0; i < snapshots.length; i++) {
      final item = snapshots[i];
      final isDimmed = activeIndex != null && activeIndex != i;
      final alpha = isDimmed ? 0.25 : 1.0;

      final centerX = slotWidth * i + slotWidth / 2;
      final rawWo =
          (item.completedWorkOrdersCount / maxVal) * (size.height - 6) * progress;
      final rawApt =
          (item.totalAppointmentsCount / maxVal) * (size.height - 6) * progress;
      final woHeight = math.max(3.0, rawWo);
      final aptHeight = math.max(3.0, rawApt);

      final woRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - barWidth - barGap / 2,
          size.height - woHeight,
          barWidth,
          woHeight,
        ),
        const Radius.circular(99),
      );

      final aptRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX + barGap / 2,
          size.height - aptHeight,
          barWidth,
          aptHeight,
        ),
        const Radius.circular(99),
      );

      canvas.drawRRect(
        woRect,
        Paint()..color = ShiftIQColors.primaryBlue.withValues(alpha: alpha),
      );
      canvas.drawRRect(
        aptRect,
        Paint()..color = ShiftIQColors.secondaryTeal.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MinimalPillBarPainter oldDelegate) {
    return oldDelegate.snapshots != snapshots ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.progress != progress;
  }
}

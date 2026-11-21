import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/models/financial_analytics_snapshot.dart';

/// Minimalist, animated area-line chart displaying branch revenue trends.
class RevenueTrendChart extends StatefulWidget {
  final List<FinancialAnalyticsSnapshot> snapshots;
  final int selectedRangeDays;
  final ValueChanged<int> onRangeChanged;

  const RevenueTrendChart({
    super.key,
    required this.snapshots,
    required this.selectedRangeDays,
    required this.onRangeChanged,
  });

  @override
  State<RevenueTrendChart> createState() => _RevenueTrendChartState();
}

class _RevenueTrendChartState extends State<RevenueTrendChart> {
  int? _activeIndex;
  int _animationSeed = 0;

  @override
  void didUpdateWidget(covariant RevenueTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshots != widget.snapshots ||
        oldWidget.selectedRangeDays != widget.selectedRangeDays) {
      _activeIndex = null;
      _animationSeed++;
    }
  }

  void _updateTouchIndex(Offset localPosition, double width) {
    if (widget.snapshots.isEmpty || width <= 0) return;
    if (widget.snapshots.length == 1) {
      if (_activeIndex != 0) {
        HapticFeedback.selectionClick();
        setState(() => _activeIndex = 0);
      }
      return;
    }
    final ratio = (localPosition.dx / width).clamp(0.0, 1.0);
    final idx = (ratio * (widget.snapshots.length - 1)).round();
    if (idx != _activeIndex) {
      HapticFeedback.selectionClick();
      setState(() => _activeIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = widget.snapshots;
    final hasData = snapshots.isNotEmpty;
    final activeSnapshot =
        hasData && _activeIndex != null && _activeIndex! < snapshots.length
            ? snapshots[_activeIndex!]
            : null;

    final totalRevenue = snapshots.fold<double>(
      0.0,
      (sum, item) => sum + item.totalRevenue,
    );
    final displayedAmount =
        activeSnapshot != null ? activeSnapshot.totalRevenue : totalRevenue;
    final localeCode = Localizations.localeOf(context).languageCode;
    final dateFmt = DateFormat('d MMM', localeCode);
    final subtitleText = activeSnapshot != null
        ? dateFmt.format(activeSnapshot.snapshotDate)
        : '${widget.selectedRangeDays}d';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingresos',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: displayedAmount),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedAmount, _) {
                        return Text(
                          'S/ ${NumberFormat('#,##0.00', 'en_US').format(animatedAmount)}',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: ShiftIQColors.graphiteText,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: Text(
                        subtitleText,
                        key: ValueKey<String>(subtitleText),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: activeSnapshot != null
                              ? ShiftIQColors.primaryBlue
                              : Colors.blueGrey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _RangePillSelector(
                selectedDays: widget.selectedRangeDays,
                onSelected: (days) {
                  HapticFeedback.selectionClick();
                  widget.onRangeChanged(days);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!hasData)
            SizedBox(
              height: 132,
              child: Center(
                child: Text(
                  'Sin movimientos registrados',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade400,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 132,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) =>
                        _updateTouchIndex(d.localPosition, constraints.maxWidth),
                    onHorizontalDragStart: (d) =>
                        _updateTouchIndex(d.localPosition, constraints.maxWidth),
                    onHorizontalDragUpdate: (d) =>
                        _updateTouchIndex(d.localPosition, constraints.maxWidth),
                    onHorizontalDragEnd: (_) =>
                        setState(() => _activeIndex = null),
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey<int>(_animationSeed),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 680),
                      curve: Curves.easeOutCubic,
                      builder: (context, progress, _) {
                        return CustomPaint(
                          painter: _MinimalAreaPainter(
                            values:
                                snapshots.map((s) => s.totalRevenue).toList(),
                            activeIndex: _activeIndex,
                            progress: progress,
                            lineColor: ShiftIQColors.primaryBlue,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            _AxisDateFooter(snapshots: snapshots, localeCode: localeCode),
          ],
        ],
      ),
    );
  }
}

class _RangePillSelector extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onSelected;

  const _RangePillSelector({
    required this.selectedDays,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [7, 14, 30].map((days) {
          final isSelected = days == selectedDays;
          return GestureDetector(
            onTap: () => onSelected(days),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '${days}D',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ShiftIQColors.graphiteText
                      : Colors.blueGrey.shade500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AxisDateFooter extends StatelessWidget {
  final List<FinancialAnalyticsSnapshot> snapshots;
  final String localeCode;

  const _AxisDateFooter({
    required this.snapshots,
    required this.localeCode,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM', localeCode);
    final first = fmt.format(snapshots.first.snapshotDate);
    final mid = fmt.format(snapshots[snapshots.length ~/ 2].snapshotDate);
    final last = fmt.format(snapshots.last.snapshotDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(first, style: _labelStyle),
        if (snapshots.length > 2) Text(mid, style: _labelStyle),
        Text(last, style: _labelStyle),
      ],
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    color: Color(0xFF94A3B8),
  );
}

class _MinimalAreaPainter extends CustomPainter {
  final List<double> values;
  final int? activeIndex;
  final double progress;
  final Color lineColor;

  _MinimalAreaPainter({
    required this.values,
    required this.activeIndex,
    required this.progress,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const topPad = 10.0;
    const bottomPad = 6.0;
    final chartHeight = math.max(1.0, size.height - topPad - bottomPad);

    final baselinePaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - bottomPad),
      Offset(size.width, size.height - bottomPad),
      baselinePaint,
    );
    canvas.drawLine(
      Offset(0, topPad + chartHeight * 0.5),
      Offset(size.width, topPad + chartHeight * 0.5),
      baselinePaint,
    );

    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final span = (maxVal - minVal).abs();

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : (i / (values.length - 1)) * size.width;
      final normalized = span < 0.01 ? 0.5 : (values[i] - minVal) / span;
      final y = topPad + chartHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    if (points.length == 1) {
      linePath.lineTo(points.first.dx + 0.1, points.first.dy);
    } else {
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final ctrlX = (p0.dx + p1.dx) / 2;
        linePath.cubicTo(ctrlX, p0.dy, ctrlX, p1.dy, p1.dx, p1.dy);
      }
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height - bottomPad)
      ..lineTo(points.first.dx, size.height - bottomPad)
      ..close();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.16),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, chartHeight));

    canvas.drawPath(areaPath, areaPaint);

    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, strokePaint);
    canvas.restore();

    if (activeIndex != null && activeIndex! < points.length) {
      final pt = points[activeIndex!];
      final guidePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.28)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(pt.dx, 0),
        Offset(pt.dx, size.height - bottomPad),
        guidePaint,
      );

      canvas.drawCircle(
        pt,
        6,
        Paint()..color = lineColor.withValues(alpha: 0.18),
      );
      canvas.drawCircle(pt, 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(
        pt,
        3.5,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MinimalAreaPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor;
  }
}

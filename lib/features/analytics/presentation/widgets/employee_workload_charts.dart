import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';

/// Animated 4-axis radar (spider) chart summarizing the employee's operational
/// profile: assigned work orders, pending tasks, completed tasks, and DTC alerts.
class EmployeeRadarOverviewChart extends StatelessWidget {
  final int assignedOrders;
  final int pendingTasks;
  final int completedTasks;
  final int dtcAlerts;

  const EmployeeRadarOverviewChart({
    super.key,
    required this.assignedOrders,
    required this.pendingTasks,
    required this.completedTasks,
    required this.dtcAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final values = [
      assignedOrders.toDouble(),
      pendingTasks.toDouble(),
      completedTasks.toDouble(),
      dtcAlerts.toDouble(),
    ];
    final maxVal = math.max(
      1.0,
      values.reduce((a, b) => math.max(a, b)),
    );
    final normalized = values.map((v) => (v / maxVal).clamp(0.0, 1.0)).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Balance Operativo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ShiftIQColors.graphiteText,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Distribución en tiempo real de tu cola',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              final animatedValues =
                  normalized.map((v) => v * progress).toList();
              return SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 42,
                        vertical: 28,
                      ),
                      child: CustomPaint(
                        size: const Size(164, 164),
                        painter: _RadarChartPainter(values: animatedValues),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: _RadarAxisTag(
                        label: 'OTs Activas',
                        value: assignedOrders,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: _RadarAxisTag(
                        label: 'Pendientes',
                        value: pendingTasks,
                        color: ShiftIQColors.severityAmber,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: _RadarAxisTag(
                        label: 'Completadas',
                        value: completedTasks,
                        color: ShiftIQColors.preventiveGreen,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: _RadarAxisTag(
                        label: 'Alertas DTC',
                        value: dtcAlerts,
                        color: ShiftIQColors.severityCrimson,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RadarAxisTag extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _RadarAxisTag({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values;

  const _RadarChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const angles = [
      -math.pi / 2,
      0.0,
      math.pi / 2,
      math.pi,
    ];

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final level in [0.25, 0.5, 0.75, 1.0]) {
      final path = Path();
      for (int i = 0; i < angles.length; i++) {
        final r = radius * level;
        final pt = Offset(
          center.dx + r * math.cos(angles[i]),
          center.dy + r * math.sin(angles[i]),
        );
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (final angle in angles) {
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        gridPaint,
      );
    }

    final dataPoints = <Offset>[];
    final dataPath = Path();
    for (int i = 0; i < angles.length; i++) {
      final val = i < values.length ? values[i] : 0.0;
      final r = radius * (val == 0 ? 0.08 : val);
      final pt = Offset(
        center.dx + r * math.cos(angles[i]),
        center.dy + r * math.sin(angles[i]),
      );
      dataPoints.add(pt);
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();

    final fillPaint = Paint()
      ..color = ShiftIQColors.primaryBlue.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = ShiftIQColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(dataPath, fillPaint);
    canvas.drawPath(dataPath, strokePaint);

    final dotColors = [
      ShiftIQColors.primaryBlue,
      ShiftIQColors.severityAmber,
      ShiftIQColors.preventiveGreen,
      ShiftIQColors.severityCrimson,
    ];
    for (int i = 0; i < dataPoints.length; i++) {
      canvas.drawCircle(
        dataPoints[i],
        4.2,
        Paint()..color = dotColors[i],
      );
      canvas.drawCircle(
        dataPoints[i],
        2.0,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}

/// Animated radial donut chart displaying the employee's task completion ratio
/// (`completedTasksCount` vs `pendingTasksCount`) matching ShiftIQ's chart card style.
class EmployeeTaskRingChart extends StatelessWidget {
  final int completedTasks;
  final int pendingTasks;

  const EmployeeTaskRingChart({
    super.key,
    required this.completedTasks,
    required this.pendingTasks,
  });

  @override
  Widget build(BuildContext context) {
    final total = completedTasks + pendingTasks;
    final ratio = total == 0 ? 0.0 : (completedTasks / total).clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Rendimiento de Tareas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ShiftIQColors.graphiteText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            total == 0
                ? 'Sin tareas registradas aún'
                : '$total ${total == 1 ? 'tarea asignada' : 'tareas en total'}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: ratio),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, animatedRatio, _) {
                  return SizedBox(
                    width: 112,
                    height: 112,
                    child: CustomPaint(
                      painter: _TaskRingPainter(
                        ratio: animatedRatio,
                        hasData: total > 0,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: ShiftIQColors.graphiteText,
                              ),
                            ),
                            const Text(
                              'Completado',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(
                      color: ShiftIQColors.preventiveGreen,
                      label: 'Completadas',
                      count: completedTasks,
                    ),
                    const SizedBox(height: 12),
                    _LegendRow(
                      color: ShiftIQColors.severityAmber,
                      label: 'Pendientes',
                      count: pendingTasks,
                    ),
                    const SizedBox(height: 12),
                    _LegendRow(
                      color: ShiftIQColors.primaryBlue,
                      label: 'Total',
                      count: total,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskRingPainter extends CustomPainter {
  final double ratio;
  final bool hasData;

  const _TaskRingPainter({required this.ratio, required this.hasData});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 12.0;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = hasData
          ? ShiftIQColors.severityAmber.withValues(alpha: 0.28)
          : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (!hasData || ratio <= 0) return;

    final progressPaint = Paint()
      ..color = ShiftIQColors.preventiveGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * ratio,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TaskRingPainter oldDelegate) =>
      oldDelegate.ratio != ratio || oldDelegate.hasData != hasData;
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: ShiftIQColors.graphiteText,
          ),
        ),
      ],
    );
  }
}

/// Animated pill-bar chart comparing completed vs pending tasks across
/// each work order in the employee's active queue.
class EmployeeQueueWorkloadChart extends StatelessWidget {
  final List<EmployeeAssignedWorkOrderSummary> orders;
  final ValueChanged<EmployeeAssignedWorkOrderSummary>? onOrderTap;

  const EmployeeQueueWorkloadChart({
    super.key,
    required this.orders,
    this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    final maxTasks = orders.fold<int>(
      1,
      (maxVal, o) => math.max(maxVal, o.assignedTasksCount),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Avance por Orden',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MiniDotLabel(
                    color: ShiftIQColors.preventiveGreen,
                    label: 'Listas',
                  ),
                  const SizedBox(width: 10),
                  _MiniDotLabel(
                    color: ShiftIQColors.severityAmber,
                    label: 'Pend.',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...orders.take(5).map((order) {
            final total = order.assignedTasksCount;
            final pending = order.pendingTasksCount.clamp(0, total);
            final completed = (total - pending).clamp(0, total);
            final totalFraction = (total / maxTasks).clamp(0.0, 1.0);
            final completedFraction =
                total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: onOrderTap != null ? () => onOrderTap!(order) : null,
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OT #${order.internalNumber.toString().padLeft(6, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                        Text(
                          '$completed/$total completadas',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth =
                            constraints.maxWidth * totalFraction;
                        return Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: barWidth),
                              duration: const Duration(milliseconds: 550),
                              curve: Curves.easeOutCubic,
                              builder: (context, animatedWidth, _) {
                                return Container(
                                  width: animatedWidth,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: ShiftIQColors.severityAmber
                                        .withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: completedFraction,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: ShiftIQColors.preventiveGreen,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MiniDotLabel extends StatelessWidget {
  final Color color;
  final String label;

  const _MiniDotLabel({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

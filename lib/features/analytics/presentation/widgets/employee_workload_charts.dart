import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';

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

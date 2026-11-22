import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';

/// Animated 7-day pill-bar chart showing completed tasks per day
/// (`task.completedAt`) plus average execution duration (`completedAt - startedAt`).
class EmployeeWeeklyActivityChart extends StatelessWidget {
  final List<EmployeeDailyCompletion> dailyCompletions;
  final double? avgCompletionMinutes;

  const EmployeeWeeklyActivityChart({
    super.key,
    required this.dailyCompletions,
    this.avgCompletionMinutes,
  });

  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  String _formatDuration(double minutes) {
    final rounded = minutes.round();
    if (rounded < 60) return '$rounded min/tarea';
    final hours = rounded ~/ 60;
    final rem = rounded % 60;
    return rem == 0 ? '${hours}h/tarea' : '${hours}h ${rem}m';
  }

  @override
  Widget build(BuildContext context) {
    final days = dailyCompletions.isNotEmpty
        ? dailyCompletions
        : List.generate(7, (i) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            return EmployeeDailyCompletion(
              date: today.subtract(Duration(days: 6 - i)),
              count: 0,
            );
          });

    final totalWeek = days.fold<int>(0, (sum, d) => sum + d.count);
    final maxCount = days.fold<int>(1, (m, d) => math.max(m, d.count));

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Productividad Semanal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalWeek ${totalWeek == 1 ? 'tarea completada' : 'tareas completadas'} en 7 días',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (avgCompletionMinutes != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.primaryBlue.withAlpha(16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: ShiftIQColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(avgCompletionMinutes!),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 118,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < days.length; i++) ...[
                  Expanded(
                    child: _DayPillBar(
                      label: _weekdayLabels[(days[i].date.weekday - 1) % 7],
                      count: days[i].count,
                      fraction: (days[i].count / maxCount).clamp(0.0, 1.0),
                      isToday: i == days.length - 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPillBar extends StatelessWidget {
  final String label;
  final int count;
  final double fraction;
  final bool isToday;

  const _DayPillBar({
    required this.label,
    required this.count,
    required this.fraction,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final targetHeight = count == 0 ? 6.0 : 14.0 + (58.0 * fraction);
    final barColor = count == 0
        ? const Color(0xFFE2E8F0)
        : isToday
            ? ShiftIQColors.primaryBlue
            : ShiftIQColors.preventiveGreen;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          count > 0 ? '$count' : '',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isToday
                ? ShiftIQColors.primaryBlue
                : ShiftIQColors.graphiteText,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 6.0, end: targetHeight),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
          builder: (context, height, _) {
            return Container(
              width: 18,
              height: height,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            color: isToday
                ? ShiftIQColors.primaryBlue
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

/// Animated 3-segment radial donut chart displaying the employee's real
/// task status breakdown in bay: Completed, In Progress (`DOING`), and Pending.
class EmployeeTaskRingChart extends StatelessWidget {
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;

  const EmployeeTaskRingChart({
    super.key,
    required this.completedTasks,
    this.inProgressTasks = 0,
    required this.pendingTasks,
  });

  @override
  Widget build(BuildContext context) {
    final total = completedTasks + inProgressTasks + pendingTasks;
    final completedRatio = total == 0 ? 0.0 : completedTasks / total;
    final inProgressRatio = total == 0 ? 0.0 : inProgressTasks / total;
    final pendingRatio = total == 0 ? 0.0 : pendingTasks / total;
    final percent = (completedRatio * 100).round();

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
            'Estado en Bahía',
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
                : '$total ${total == 1 ? 'tarea asignada' : 'tareas en tu cola'}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) {
                  return SizedBox(
                    width: 112,
                    height: 112,
                    child: CustomPaint(
                      painter: _TaskRingPainter(
                        completedRatio: completedRatio * progress,
                        inProgressRatio: inProgressRatio * progress,
                        pendingRatio: pendingRatio * progress,
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
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: ShiftIQColors.secondaryTeal,
                      label: 'En progreso',
                      count: inProgressTasks,
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: ShiftIQColors.severityAmber,
                      label: 'Pendientes',
                      count: pendingTasks,
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
  final double completedRatio;
  final double inProgressRatio;
  final double pendingRatio;
  final bool hasData;

  const _TaskRingPainter({
    required this.completedRatio,
    required this.inProgressRatio,
    required this.pendingRatio,
    required this.hasData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 12.0;
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (!hasData) return;

    var startAngle = -math.pi / 2;
    final segments = [
      (completedRatio, ShiftIQColors.preventiveGreen),
      (inProgressRatio, ShiftIQColors.secondaryTeal),
      (pendingRatio, ShiftIQColors.severityAmber),
    ];

    for (final (ratio, color) in segments) {
      if (ratio <= 0) continue;
      final sweep = math.pi * 2 * ratio;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _TaskRingPainter oldDelegate) =>
      oldDelegate.completedRatio != completedRatio ||
      oldDelegate.inProgressRatio != inProgressRatio ||
      oldDelegate.pendingRatio != pendingRatio ||
      oldDelegate.hasData != hasData;
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

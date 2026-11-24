import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';

/// Interactive 7-day bar chart powered by `fl_chart` showing completed tasks
/// per day (`task.completedAt`) plus average execution duration.
class EmployeeWeeklyActivityChart extends StatefulWidget {
  final List<EmployeeDailyCompletion> dailyCompletions;
  final double? avgCompletionMinutes;

  const EmployeeWeeklyActivityChart({
    super.key,
    required this.dailyCompletions,
    this.avgCompletionMinutes,
  });

  @override
  State<EmployeeWeeklyActivityChart> createState() =>
      _EmployeeWeeklyActivityChartState();
}

class _EmployeeWeeklyActivityChartState
    extends State<EmployeeWeeklyActivityChart> {
  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  int _touchedIndex = -1;

  String _formatDuration(double minutes) {
    final rounded = minutes.round();
    if (rounded < 60) return '$rounded min/tarea';
    final hours = rounded ~/ 60;
    final rem = rounded % 60;
    return rem == 0 ? '${hours}h/tarea' : '${hours}h ${rem}m';
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.dailyCompletions.isNotEmpty
        ? widget.dailyCompletions
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
              if (widget.avgCompletionMinutes != null)
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
                        _formatDuration(widget.avgCompletionMinutes!),
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
            height: 148,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 1).toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.spot == null) {
                        _touchedIndex = -1;
                      } else {
                        _touchedIndex = response.spot!.touchedBarGroupIndex;
                      }
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => ShiftIQColors.graphiteText,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final count = days[group.x].count;
                      return BarTooltipItem(
                        '$count ${count == 1 ? 'tarea' : 'tareas'}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isToday = idx == days.length - 1;
                        final label =
                            _weekdayLabels[(days[idx].date.weekday - 1) % 7];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  isToday ? FontWeight.w800 : FontWeight.w600,
                              color: isToday
                                  ? ShiftIQColors.primaryBlue
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: math.max(1, (maxCount / 2).ceil()).toDouble(),
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(days.length, (i) {
                  final isTouched = i == _touchedIndex;
                  final isToday = i == days.length - 1;
                  final count = days[i].count;
                  final barColor = count == 0
                      ? const Color(0xFFE2E8F0)
                      : isTouched
                          ? ShiftIQColors.accentSkyBlue
                          : isToday
                              ? ShiftIQColors.primaryBlue
                              : ShiftIQColors.preventiveGreen;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        width: isTouched ? 20 : 16,
                        color: barColor,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (maxCount + 1).toDouble(),
                          color: const Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive 3-segment donut chart powered by `fl_chart` displaying the
/// employee's real task status breakdown: Completed, In Progress, and Pending.
class EmployeeTaskRingChart extends StatefulWidget {
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
  State<EmployeeTaskRingChart> createState() => _EmployeeTaskRingChartState();
}

class _EmployeeTaskRingChartState extends State<EmployeeTaskRingChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total =
        widget.completedTasks + widget.inProgressTasks + widget.pendingTasks;
    final completedRatio = total == 0 ? 0.0 : widget.completedTasks / total;
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
              SizedBox(
                width: 124,
                height: 124,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: total == 0 ? 0 : 3,
                        centerSpaceRadius: 38,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                _touchedIndex = -1;
                              } else {
                                _touchedIndex = response
                                    .touchedSection!.touchedSectionIndex;
                              }
                            });
                          },
                        ),
                        sections: total == 0
                            ? [
                                PieChartSectionData(
                                  value: 1,
                                  color: const Color(0xFFE2E8F0),
                                  radius: 14,
                                  showTitle: false,
                                ),
                              ]
                            : [
                                PieChartSectionData(
                                  value: widget.completedTasks.toDouble(),
                                  color: ShiftIQColors.preventiveGreen,
                                  radius: _touchedIndex == 0 ? 18 : 14,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: widget.inProgressTasks.toDouble(),
                                  color: ShiftIQColors.secondaryTeal,
                                  radius: _touchedIndex == 1 ? 18 : 14,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  value: widget.pendingTasks.toDouble(),
                                  color: ShiftIQColors.severityAmber,
                                  radius: _touchedIndex == 2 ? 18 : 14,
                                  showTitle: false,
                                ),
                              ],
                      ),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 21,
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
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(
                      color: ShiftIQColors.preventiveGreen,
                      label: 'Completadas',
                      count: widget.completedTasks,
                      highlighted: _touchedIndex == 0,
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: ShiftIQColors.secondaryTeal,
                      label: 'En progreso',
                      count: widget.inProgressTasks,
                      highlighted: _touchedIndex == 1,
                    ),
                    const SizedBox(height: 10),
                    _LegendRow(
                      color: ShiftIQColors.severityAmber,
                      label: 'Pendientes',
                      count: widget.pendingTasks,
                      highlighted: _touchedIndex == 2,
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

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final bool highlighted;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted ? color.withAlpha(18) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
      ),
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

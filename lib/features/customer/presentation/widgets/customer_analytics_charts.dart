import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Interactive donut chart powered by `fl_chart` showing the customer's
/// vehicle health and active workshop activity without plain counter tiles.
class CustomerFleetHealthRingChart extends StatefulWidget {
  final int activeVehiclesCount;
  final int activeDtcAlertsCount;
  final int activeWorkOrdersCount;
  final int pendingQuotesCount;

  const CustomerFleetHealthRingChart({
    super.key,
    required this.activeVehiclesCount,
    required this.activeDtcAlertsCount,
    required this.activeWorkOrdersCount,
    required this.pendingQuotesCount,
  });

  @override
  State<CustomerFleetHealthRingChart> createState() =>
      _CustomerFleetHealthRingChartState();
}

class _CustomerFleetHealthRingChartState
    extends State<CustomerFleetHealthRingChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final healthyVehicles = (widget.activeVehiclesCount -
            widget.activeDtcAlertsCount.clamp(0, widget.activeVehiclesCount))
        .clamp(0, widget.activeVehiclesCount);
    final totalSignals = healthyVehicles +
        widget.activeDtcAlertsCount +
        widget.activeWorkOrdersCount +
        widget.pendingQuotesCount;

    final healthRatio = widget.activeVehiclesCount <= 0
        ? 1.0
        : (healthyVehicles / widget.activeVehiclesCount).clamp(0.0, 1.0);
    final healthPercent = (healthRatio * 100).round();

    final segments = <_RingSegment>[
      if (healthyVehicles > 0)
        _RingSegment(
          label: 'Vehículos OK',
          count: healthyVehicles,
          color: ShiftIQColors.secondaryTeal,
        ),
      if (widget.activeDtcAlertsCount > 0)
        _RingSegment(
          label: 'Alertas DTC',
          count: widget.activeDtcAlertsCount,
          color: ShiftIQColors.severityCrimson,
        ),
      if (widget.activeWorkOrdersCount > 0)
        _RingSegment(
          label: 'Órdenes activas',
          count: widget.activeWorkOrdersCount,
          color: ShiftIQColors.primaryBlue,
        ),
      if (widget.pendingQuotesCount > 0)
        _RingSegment(
          label: 'Cotizaciones',
          count: widget.pendingQuotesCount,
          color: const Color(0xFFD97706),
        ),
    ];

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
            'Estado de tu Flota y Servicios',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: ShiftIQColors.graphiteText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            totalSignals == 0
                ? 'Sin actividad reciente registrada'
                : '${widget.activeVehiclesCount} vehículos · ${widget.activeWorkOrdersCount} órdenes en taller',
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
                    RepaintBoundary(
                      child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: segments.length > 1 ? 3 : 0,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                        sections: segments.isEmpty
                            ? [
                                PieChartSectionData(
                                  value: 1,
                                  color: const Color(0xFFE2E8F0),
                                  radius: 14,
                                  showTitle: false,
                                ),
                              ]
                            : [
                                for (var i = 0; i < segments.length; i++)
                                  PieChartSectionData(
                                    value: segments[i].count.toDouble(),
                                    color: segments[i].color,
                                    radius: _touchedIndex == i ? 19 : 15,
                                    showTitle: false,
                                  ),
                              ],
                      ),
                    ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$healthPercent%',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: ShiftIQColors.graphiteText,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'salud',
                          style: TextStyle(
                            fontSize: 10.5,
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
                  children: segments.isEmpty
                      ? const [
                          Text(
                            'Sin métricas activas aún',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ]
                      : [
                          for (var i = 0; i < segments.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            _LegendRow(
                              color: segments[i].color,
                              label: segments[i].label,
                              value: '${segments[i].count}',
                              highlighted: _touchedIndex == i,
                            ),
                          ],
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

/// Interactive bar chart powered by `fl_chart` showing service investment (`S/`)
/// across the customer's recent work orders.
class CustomerWorkOrderSpendingChart extends StatefulWidget {
  final List<WorkOrder> workOrders;

  const CustomerWorkOrderSpendingChart({
    super.key,
    required this.workOrders,
  });

  @override
  State<CustomerWorkOrderSpendingChart> createState() =>
      _CustomerWorkOrderSpendingChartState();
}

class _CustomerWorkOrderSpendingChartState
    extends State<CustomerWorkOrderSpendingChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final orders = widget.workOrders.take(5).toList().reversed.toList();
    if (orders.isEmpty) return const SizedBox.shrink();

    final maxAmount = orders.fold<double>(
      100.0,
      (prev, o) => o.totalAmount > prev ? o.totalAmount : prev,
    );
    final totalSpent = orders.fold<double>(0.0, (acc, o) => acc + o.totalAmount);

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
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial de Servicios',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Monto por orden de trabajo (S/)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: ShiftIQColors.primaryBlue.withAlpha(18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'S/ ${totalSpent.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: ShiftIQColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 148,
            child: RepaintBoundary(
              child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxAmount / 3,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
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
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= orders.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            orders[idx].vehiclePlate,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: _touchedIndex == idx
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _touchedIndex == idx
                                  ? ShiftIQColors.primaryBlue
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.spot == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = response.spot!.touchedBarGroupIndex;
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0F172A),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final order = orders[groupIndex];
                      return BarTooltipItem(
                        '${order.formattedNumber}\nS/ ${order.totalAmount.toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < orders.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: orders[i].totalAmount,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          color: _touchedIndex == i
                              ? ShiftIQColors.primaryBlue
                              : orders[i].status.color,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxAmount * 1.15,
                            color: const Color(0xFFF1F5F9),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingSegment {
  final String label;
  final int count;
  final Color color;

  const _RingSegment({
    required this.label,
    required this.count,
    required this.color,
  });
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool highlighted;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
              color: highlighted
                  ? ShiftIQColors.graphiteText
                  : const Color(0xFF475569),
            ),
          ),
        ),
        Text(
          value,
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

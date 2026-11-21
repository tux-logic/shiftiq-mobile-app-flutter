import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Descriptor for a single Kanban status tab with an optional live item count.
class ShiftIQKanbanTabItem {
  final String label;
  final int count;

  const ShiftIQKanbanTabItem({
    required this.label,
    required this.count,
  });
}

/// Minimalist underline TabBar shared across ShiftIQ Kanban-style list screens
/// (Work Orders, Appointments, Inventory, and Telemetry).
class ShiftIQKanbanTabBar extends StatelessWidget {
  final TabController controller;
  final List<ShiftIQKanbanTabItem> tabs;

  const ShiftIQKanbanTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
        indicatorColor: ShiftIQColors.primaryBlue,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: ShiftIQColors.borderSlate.withValues(alpha: 0.6),
        labelColor: ShiftIQColors.primaryBlue,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        tabs: tabs
            .map(
              (item) => Tab(
                height: 44,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.label),
                    if (item.count > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '${item.count}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

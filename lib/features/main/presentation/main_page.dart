import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/views/dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/views/appointments_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/views/inventory_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/views/telemetry_dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_page.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({super.key, this.initialIndex = 0});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(
            onNavigateToOrders: () => _onDestinationSelected(1),
            onNavigateToAppointments: () => _onDestinationSelected(2),
            onNavigateToInventory: () => _onDestinationSelected(3),
            onNavigateToIot: () => _onDestinationSelected(4),
          ),
          const WorkOrdersPage(),
          const AppointmentsPage(),
          const InventoryPage(),
          const TelemetryDashboardPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        indicatorColor: ShiftIQColors.primaryBlue.withAlpha(35),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: ShiftIQColors.primaryBlue),
            label: 'Panel',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build, color: ShiftIQColors.primaryBlue),
            label: 'Órdenes',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: ShiftIQColors.primaryBlue),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: ShiftIQColors.primaryBlue),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors, color: ShiftIQColors.primaryBlue),
            label: 'Telemetría',
          ),
        ],
      ),
    );
  }
}

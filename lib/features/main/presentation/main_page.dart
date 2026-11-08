import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/dashboard_view_model.dart';

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
    return ChangeNotifierProvider(
      create: (_) => getIt<DashboardViewModel>(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardPage(
              onNavigateToOrders: () => _onDestinationSelected(1),
              onNavigateToAppointments: () => _onDestinationSelected(2),
              onNavigateToInventory: () => _onDestinationSelected(3),
              onNavigateToIot: () => _onDestinationSelected(4),
            ),
            _buildPlaceholderPage(
              title: 'Órdenes de Trabajo (OTs)',
              subtitle: 'Hito 3: Gestión de Tareas y Repuestos Mecánicos',
              icon: Icons.build_outlined,
            ),
            _buildPlaceholderPage(
              title: 'Citas y Flota de Clientes',
              subtitle: 'Hito 4: Agenda Semanal y Directorio de Clientes',
              icon: Icons.calendar_month_outlined,
            ),
            _buildPlaceholderPage(
              title: 'Inventario y Lotes',
              subtitle: 'Hito 5: Catálogo de Repuestos y Stock Mínimo',
              icon: Icons.inventory_2_outlined,
            ),
            _buildPlaceholderPage(
              title: 'Telemetría IoT & OBD-II',
              subtitle: 'Hito 6: Códigos DTC y Diagnóstico de Sensores en Vivo',
              icon: Icons.sensors_outlined,
            ),
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
      ),
    );
  }

  Widget _buildPlaceholderPage({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ShiftIQColors.primaryBlue.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: ShiftIQColors.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

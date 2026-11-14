import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/views/dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/views/appointments_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/views/inventory_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/views/telemetry_dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_page.dart';

class _NavDestinationSpec {
  final Key key;
  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;
  final Widget page;

  const _NavDestinationSpec({
    required this.key,
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
    required this.page,
  });
}

/// Role-scoped main navigation shell for workshop staff and owners/admins.
class MainPage extends StatefulWidget {
  final int initialIndex;
  final MobileRoleScope? roleScope;
  final List<Widget>? overridePages;

  const MainPage({
    super.key,
    this.initialIndex = 0,
    this.roleScope,
    this.overridePages,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  MobileRoleScope get _effectiveScope {
    if (widget.roleScope != null) return widget.roleScope!;
    if (getIt.isRegistered<SessionStorage>()) {
      return RoleRouter.resolveScope(getIt<SessionStorage>().roles);
    }
    return MobileRoleScope.employee;
  }

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

  List<_NavDestinationSpec> _buildDestinations(MobileRoleScope scope) {
    final override = widget.overridePages;
    if (scope == MobileRoleScope.ownerAdmin) {
      return [
        _NavDestinationSpec(
          key: const Key('nav_dashboard'),
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard_rounded,
          labelKey: 'dashboard_tab',
          page: override != null && override.isNotEmpty
              ? override[0]
              : DashboardPage(
                  onNavigateToOrders: () => _onDestinationSelected(1),
                  onNavigateToAppointments: () => _onDestinationSelected(2),
                  onNavigateToInventory: () => _onDestinationSelected(3),
                  onNavigateToIot: () => _onDestinationSelected(4),
                ),
        ),
        _NavDestinationSpec(
          key: const Key('nav_orders'),
          icon: Icons.build_outlined,
          selectedIcon: Icons.build_rounded,
          labelKey: 'orders_tab',
          page: override != null && override.length > 1
              ? override[1]
              : const WorkOrdersPage(),
        ),
        _NavDestinationSpec(
          key: const Key('nav_appointments'),
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month_rounded,
          labelKey: 'appointments_tab',
          page: override != null && override.length > 2
              ? override[2]
              : const AppointmentsPage(),
        ),
        _NavDestinationSpec(
          key: const Key('nav_inventory'),
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2_rounded,
          labelKey: 'inventory_tab',
          page: override != null && override.length > 3
              ? override[3]
              : const InventoryPage(),
        ),
        _NavDestinationSpec(
          key: const Key('nav_telemetry'),
          icon: Icons.sensors_outlined,
          selectedIcon: Icons.sensors_rounded,
          labelKey: 'telemetry_tab',
          page: override != null && override.length > 4
              ? override[4]
              : const TelemetryDashboardPage(),
        ),
      ];
    }

    // Employee operational scope: Work Orders, Appointments, Telemetry.
    return [
      _NavDestinationSpec(
        key: const Key('nav_orders'),
        icon: Icons.build_outlined,
        selectedIcon: Icons.build_rounded,
        labelKey: 'orders_tab',
        page: override != null && override.isNotEmpty
            ? override[0]
            : const WorkOrdersPage(),
      ),
      _NavDestinationSpec(
        key: const Key('nav_appointments'),
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        labelKey: 'appointments_tab',
        page: override != null && override.length > 1
            ? override[1]
            : const AppointmentsPage(),
      ),
      _NavDestinationSpec(
        key: const Key('nav_telemetry'),
        icon: Icons.sensors_outlined,
        selectedIcon: Icons.sensors_rounded,
        labelKey: 'telemetry_tab',
        page: override != null && override.length > 2
            ? override[2]
            : const TelemetryDashboardPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scope = _effectiveScope;
    if (scope == MobileRoleScope.customer) {
      return const CustomerHomePage();
    }

    final loc = AppLocalizations.of(context);
    final specs = _buildDestinations(scope);
    final safeIndex = _currentIndex.clamp(0, specs.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: specs.map((spec) => spec.page).toList(),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          height: 68,
          indicatorColor: ShiftIQColors.primaryBlue.withAlpha(24),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? ShiftIQColors.primaryBlue
                  : const Color(0xFF64748B),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 22,
              color: selected
                  ? ShiftIQColors.primaryBlue
                  : const Color(0xFF64748B),
            );
          }),
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: NavigationBar(
            key: const Key('main_navigation_bar'),
            selectedIndex: safeIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: specs
                .map(
                  (spec) => NavigationDestination(
                    key: spec.key,
                    icon: Icon(spec.icon),
                    selectedIcon: Icon(spec.selectedIcon),
                    label: loc.translate(spec.labelKey),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

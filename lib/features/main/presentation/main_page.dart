import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_floating_nav_bar.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/views/dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/views/employee_dashboard_page.dart';
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

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  int _transitionDirection = 1;
  late final AnimationController _tabController;
  late final Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  MobileRoleScope? _cachedScope;
  late List<_NavDestinationSpec> _cachedSpecs;

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
    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _fadeAnimation = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _tabController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _tabController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == _currentIndex) return;
    final direction = index > _currentIndex ? 1 : -1;
    setState(() {
      _transitionDirection = direction;
      _currentIndex = index;
      _slideAnimation = Tween<Offset>(
        begin: Offset(0.025 * _transitionDirection, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _tabController, curve: Curves.easeOutCubic),
      );
    });
    _tabController.forward(from: 0.0);
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

    // Employee operational scope: Personal Dashboard, Work Orders, and Telemetry.
    return [
      _NavDestinationSpec(
        key: const Key('nav_dashboard'),
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard_rounded,
        labelKey: 'dashboard_tab',
        page: override != null && override.isNotEmpty
            ? override[0]
            : EmployeeDashboardPage(
                onNavigateToOrders: () => _onDestinationSelected(1),
                onNavigateToTelemetry: () => _onDestinationSelected(2),
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
    if (_cachedScope != scope) {
      _cachedScope = scope;
      _cachedSpecs = _buildDestinations(scope);
    }
    final specs = _cachedSpecs;
    final safeIndex = _currentIndex.clamp(0, specs.length - 1);

    return Scaffold(
      extendBody: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ShiftIQActiveTabScope(
            activeIndex: safeIndex,
            child: IndexedStack(
              index: safeIndex,
              children: specs.map((spec) => spec.page).toList(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ShiftIQFloatingNavBar(
        key: const Key('main_navigation_bar'),
        selectedIndex: safeIndex,
        onDestinationSelected: _onDestinationSelected,
        items: specs
            .map(
              (spec) => ShiftIQNavItem(
                key: spec.key,
                icon: spec.icon,
                selectedIcon: spec.selectedIcon,
                label: loc.translate(spec.labelKey),
              ),
            )
            .toList(),
      ),
    );
  }
}

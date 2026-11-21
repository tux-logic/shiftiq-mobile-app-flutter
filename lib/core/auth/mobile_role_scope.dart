import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/main/presentation/main_page.dart';

/// Represents the three target user scopes supported by the ShiftIQ mobile app.
enum MobileRoleScope {
  /// End customer (`ROLE_USER` or `ROLE_CUSTOMER`) without branch-admin access.
  customer,

  /// Workshop staff member (`ROLE_EMPLOYEE` and operational branch roles).
  employee,

  /// Workshop owner or platform administrator (`ROLE_OWNER` or `ROLE_ADMIN`).
  ownerAdmin,
}

/// Resolves the mobile role scope and initial destination from session roles.
class RoleRouter {
  RoleRouter._();

  static MobileRoleScope resolveScope(List<String> roles) {
    final normalized = roles.map((r) => r.trim().toUpperCase()).toSet();

    if (normalized.contains('ROLE_ADMIN') ||
        normalized.contains('ADMIN') ||
        normalized.contains('ROLE_OWNER') ||
        normalized.contains('OWNER')) {
      return MobileRoleScope.ownerAdmin;
    }

    if (normalized.contains('ROLE_EMPLOYEE') ||
        normalized.contains('EMPLOYEE') ||
        normalized.contains('ROLE_BRANCH_MANAGER') ||
        normalized.contains('BRANCH_MANAGER') ||
        normalized.contains('ROLE_ASSISTANT') ||
        normalized.contains('ASSISTANT')) {
      return MobileRoleScope.employee;
    }

    return MobileRoleScope.customer;
  }

  /// Returns the post-authentication destination widget for the given [roles].
  static Widget resolveHomeForSession(
    SessionStorage sessionStorage, {
    bool preferActiveBranch = false,
  }) {
    final scope = resolveScope(sessionStorage.roles);
    return switch (scope) {
      MobileRoleScope.customer => const CustomerHomePage(),
      MobileRoleScope.employee || MobileRoleScope.ownerAdmin =>
        (preferActiveBranch && sessionStorage.hasActiveBranch)
            ? const MainPage()
            : const BranchSelectionPage(),
    };
  }
}

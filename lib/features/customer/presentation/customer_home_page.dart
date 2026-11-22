import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/logout.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';

/// Dedicated mobile landing shell for `ROLE_USER` / `ROLE_CUSTOMER` accounts.
class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.translate('logout_dialog_title')),
        content: Text(loc.translate('customer_logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ShiftIQColors.severityCrimson,
            ),
            child: Text(loc.translate('logout_upper')),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await getIt<LogoutUseCase>().execute();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(viewModel: getIt<LoginViewModel>()),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final session = getIt<SessionStorage>();
    final email = session.username ?? '';

    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: ShiftIQCollapsibleHeaderBody(
        header: ShiftIQPageHeader(
          title: loc.translate('customer_portal_title'),
          subtitle: email.isNotEmpty ? email : null,
          actions: [
            ShiftIQLiquidIconButton(
              key: const Key('customer_logout_button'),
              tooltip: loc.translate('logout_dialog_title'),
              icon: Icons.logout_rounded,
              onDarkBackground: true,
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ShiftIQColors.secondaryTeal.withAlpha(45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ShiftIQColors.secondaryTeal.withAlpha(120),
                      ),
                    ),
                    child: Text(
                      loc.translate('role_customer_badge'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    loc.translate('customer_welcome_title'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    loc.translate('customer_welcome_subtitle'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              loc.translate('customer_services_section'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            _CustomerModuleCard(
              icon: Icons.directions_car_filled_outlined,
              accentColor: ShiftIQColors.primaryBlue,
              title: loc.translate('customer_vehicles_title'),
              subtitle: loc.translate('customer_vehicles_subtitle'),
            ),
            const SizedBox(height: 12),
            _CustomerModuleCard(
              icon: Icons.calendar_month_outlined,
              accentColor: ShiftIQColors.secondaryTeal,
              title: loc.translate('customer_appointments_title'),
              subtitle: loc.translate('customer_appointments_subtitle'),
            ),
            const SizedBox(height: 12),
            _CustomerModuleCard(
              icon: Icons.build_circle_outlined,
              accentColor: ShiftIQColors.preventiveGreen,
              title: loc.translate('customer_orders_title'),
              subtitle: loc.translate('customer_orders_subtitle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerModuleCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;

  const _CustomerModuleCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

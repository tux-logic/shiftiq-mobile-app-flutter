import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';

/// Displays a compact ShiftIQ-styled bottom sheet confirming session sign-out
/// without aggressive red alert styling. Returns `true` when the user confirms.
Future<bool> showShiftIQLogoutConfirmationSheet(BuildContext context) async {
  final loc = AppLocalizations.of(context);
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                loc.translate('logout_dialog_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.translate('customer_logout_confirm'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ShiftIQLiquidButton(
                      expand: true,
                      height: 48,
                      borderRadius: 16,
                      label: loc.translate('cancel'),
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        key: const Key('btn_confirm_logout'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return confirmed == true;
}

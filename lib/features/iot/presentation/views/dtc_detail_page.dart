import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/create_work_order_page.dart';

class DtcDetailPage extends StatelessWidget {
  final DtcAlert alert;
  final String branchId;
  final TelemetryViewModel viewModel;

  const DtcDetailPage({
    super.key,
    required this.alert,
    required this.branchId,
    required this.viewModel,
  });

  void _openWorkOrder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateWorkOrderPage(
          branchId: branchId,
          initialPlate: alert.vehiclePlate,
          initialCustomerName: alert.customerName,
          initialModel: alert.vehicleModel,
          initialDiagnostic:
              'Alerta OBD-II Código ${alert.code}: ${alert.description}. Diagnóstico IA: ${alert.aiDiagnosticRecommendation}',
        ),
      ),
    );
  }

  Future<void> _resolveDtc(BuildContext context) async {
    await viewModel.updateDtcStatus(alert.id, DtcStatus.resolved, branchId);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: ShiftIQCollapsibleHeaderBody(
        header: ShiftIQPageHeader(
          title: 'Diagnóstico ${alert.code}',
          subtitle: '${alert.vehiclePlate} · ${alert.vehicleModel}',
          showBackButton: true,
        ),
        body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ShiftIQColors.borderSlate),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withAlpha(9),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ShiftIQColors.graphiteText,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          alert.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        alert.severity.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: alert.severity.color,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        alert.formattedTimeAgo,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sistema: ${alert.systemCategory}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI Technical Recommendation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShiftIQColors.primaryBlue.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ShiftIQColors.primaryBlue.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: ShiftIQColors.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Recomendación Técnica IA ShiftIQ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ShiftIQColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.aiDiagnosticRecommendation,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Freeze Frame Data Table
            const Text(
              'Parámetros Freeze Frame en el Momento del Fallo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ShiftIQColors.graphiteText,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ShiftIQColors.borderSlate),
              ),
              child: Column(
                children: alert.freezeFrame.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: ShiftIQColors.surfaceVariant),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resolveDtc(context),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: Text(loc.translate('mark_resolved')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ShiftIQColors.preventiveGreen,
                      side: const BorderSide(color: ShiftIQColors.preventiveGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openWorkOrder(context),
                    icon: const Icon(Icons.post_add_rounded, size: 16),
                    label: Text(loc.translate('open_ot_bay')),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

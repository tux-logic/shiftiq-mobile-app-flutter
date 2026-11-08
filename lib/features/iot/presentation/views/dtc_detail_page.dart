import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/aggregates/dtc_alert.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código DTC marcado como RESUELTO'),
          backgroundColor: ShiftIQColors.preventiveGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnóstico ${alert.code}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${alert.vehiclePlate} · ${alert.vehicleModel}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Code Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ShiftIQColors.borderSlate),
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
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Marcar Resuelto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ShiftIQColors.preventiveGreen,
                      side: const BorderSide(color: ShiftIQColors.preventiveGreen),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openWorkOrder(context),
                    icon: const Icon(Icons.post_add, size: 16),
                    label: const Text('Abrir OT en Bahía'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ShiftIQColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

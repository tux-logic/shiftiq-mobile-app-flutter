import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';

class DtcAlertDto {
  final String id;
  final String branchId;
  final String vehicleId;
  final String vehiclePlate;
  final String vehicleModel;
  final String customerName;
  final String code;
  final String description;
  final String systemCategory;
  final String severity;
  final String aiDiagnosticRecommendation;
  final String detectedAt;
  final String status;
  final Map<String, dynamic>? freezeFrame;

  const DtcAlertDto({
    required this.id,
    required this.branchId,
    required this.vehicleId,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.customerName,
    required this.code,
    required this.description,
    required this.systemCategory,
    required this.severity,
    required this.aiDiagnosticRecommendation,
    required this.detectedAt,
    required this.status,
    this.freezeFrame,
  });

  factory DtcAlertDto.fromJson(Map<String, dynamic> json) {
    return DtcAlertDto(
      id: json['id']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? json['branch_id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? json['vehicle_id']?.toString() ?? '',
      vehiclePlate: json['vehiclePlate']?.toString() ?? json['vehicle_plate']?.toString() ?? 'S/P',
      vehicleModel: json['vehicleModel']?.toString() ?? json['vehicle_model']?.toString() ?? 'Vehículo General',
      customerName: json['customerName']?.toString() ?? json['customer_name']?.toString() ?? 'Cliente General',
      code: json['dtcCode']?.toString() ?? json['code']?.toString() ?? 'P0000',
      description: json['description']?.toString() ?? 'Código DTC',
      systemCategory: json['systemCategory']?.toString() ?? json['system_category']?.toString() ?? 'Motor',
      severity: json['severity']?.toString() ?? 'MODERATE',
      aiDiagnosticRecommendation: json['aiDiagnosticRecommendation']?.toString() ??
          json['ai_diagnostic_recommendation']?.toString() ??
          'Inspección computarizada requerida',
      detectedAt: json['createdAt']?.toString() ??
          json['detectedAt']?.toString() ??
          json['detected_at']?.toString() ??
          DateTime.now().toIso8601String(),
      status: json['status']?.toString() ?? 'ACTIVE',
      freezeFrame: json['freezeFrame'] as Map<String, dynamic>?,
    );
  }

  DtcAlert toDomain() {
    Map<String, String> convertedFreezeFrame = {};
    if (freezeFrame != null) {
      freezeFrame!.forEach((key, val) {
        convertedFreezeFrame[key] = val.toString();
      });
    }

    return DtcAlert(
      id: id,
      branchId: branchId,
      vehicleId: vehicleId,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      customerName: customerName,
      code: code,
      description: description,
      systemCategory: systemCategory,
      severity: DtcSeverity.fromString(severity),
      aiDiagnosticRecommendation: aiDiagnosticRecommendation,
      detectedAt: DateTime.tryParse(detectedAt) ?? DateTime.now(),
      status: DtcStatus.fromString(status),
      freezeFrame: convertedFreezeFrame,
    );
  }
}

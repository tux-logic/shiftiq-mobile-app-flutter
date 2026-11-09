import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_severity.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';

export 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_severity.dart';
export 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/valueobjects/dtc_status.dart';

/// Aggregate root representing an onboard diagnostic trouble code fault alert.
class DtcAlert {
  final String id;
  final String branchId;
  final String vehicleId;
  final String vehiclePlate;
  final String vehicleModel;
  final String customerName;
  final String code; // e.g. P0300, P0171, P0420
  final String description;
  final String systemCategory;
  final DtcSeverity severity;
  final String aiDiagnosticRecommendation;
  final DateTime detectedAt;
  final DtcStatus status;
  final Map<String, String> freezeFrame;

  const DtcAlert({
    required this.id,
    required this.branchId,
    required this.vehicleId,
    required this.vehiclePlate,
    this.vehicleModel = 'Vehículo General',
    this.customerName = 'Cliente del Taller',
    required this.code,
    required this.description,
    required this.systemCategory,
    required this.severity,
    required this.aiDiagnosticRecommendation,
    required this.detectedAt,
    this.status = DtcStatus.active,
    this.freezeFrame = const {},
  });

  bool get isActive => status == DtcStatus.active;
  bool get isCritical => severity == DtcSeverity.critical;

  String get formattedTimeAgo {
    final diff = DateTime.now().difference(detectedAt);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else {
      return 'Hace ${diff.inDays} días';
    }
  }

  DtcAlert copyWith({
    String? id,
    String? branchId,
    String? vehicleId,
    String? vehiclePlate,
    String? vehicleModel,
    String? customerName,
    String? code,
    String? description,
    String? systemCategory,
    DtcSeverity? severity,
    String? aiDiagnosticRecommendation,
    DateTime? detectedAt,
    DtcStatus? status,
    Map<String, String>? freezeFrame,
  }) {
    return DtcAlert(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      customerName: customerName ?? this.customerName,
      code: code ?? this.code,
      description: description ?? this.description,
      systemCategory: systemCategory ?? this.systemCategory,
      severity: severity ?? this.severity,
      aiDiagnosticRecommendation:
          aiDiagnosticRecommendation ?? this.aiDiagnosticRecommendation,
      detectedAt: detectedAt ?? this.detectedAt,
      status: status ?? this.status,
      freezeFrame: freezeFrame ?? this.freezeFrame,
    );
  }
}

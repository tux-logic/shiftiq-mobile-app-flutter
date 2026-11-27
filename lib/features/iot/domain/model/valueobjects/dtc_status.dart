import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';

enum DtcStatus {
  active('ACTIVE', 'Active / Unresolved'),
  inInspection('IN_INSPECTION', 'In Inspection'),
  resolved('RESOLVED', 'Resolved / Cleared');

  final String value;
  final String label;

  const DtcStatus(this.value, this.label);

  String localizedLabel(AppLocalizations loc) {
    switch (this) {
      case DtcStatus.active:
        return loc.translate('dtc_status_active');
      case DtcStatus.inInspection:
        return loc.translate('dtc_status_in_inspection');
      case DtcStatus.resolved:
        return loc.translate('dtc_status_resolved');
    }
  }

  static DtcStatus fromString(String? val) {
    if (val == null) return DtcStatus.active;
    return DtcStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DtcStatus.active,
    );
  }
}

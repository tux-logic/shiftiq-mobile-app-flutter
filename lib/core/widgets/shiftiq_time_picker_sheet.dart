import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Shows a wheel-based 24h time picker in a modal bottom sheet, avoiding
/// Flutter Material's `showTimePicker` keyboard-resize `BoxConstraints` bug.
Future<TimeOfDay?> showShiftIQTimePickerSheet(
  BuildContext context, {
  required TimeOfDay initialTime,
  TimeOfDay? minimumTime,
  TimeOfDay? maximumTime,
  String? title,
  String? confirmLabel,
}) {
  final minDate = minimumTime != null
      ? DateTime(2026, 1, 1, minimumTime.hour, minimumTime.minute)
      : null;
  final maxDate = maximumTime != null
      ? DateTime(2026, 1, 1, maximumTime.hour, maximumTime.minute)
      : null;
  final validBounds =
      minDate != null && maxDate != null ? !minDate.isAfter(maxDate) : true;

  var selected = DateTime(2026, 1, 1, initialTime.hour, initialTime.minute);
  if (validBounds) {
    if (minDate != null && selected.isBefore(minDate)) selected = minDate;
    if (maxDate != null && selected.isAfter(maxDate)) selected = maxDate;
  }

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) {
      final loc = AppLocalizations.of(sheetCtx);
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title ?? loc.translate('select_time_title'),
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(null),
                      child: Text(loc.translate('cancel')),
                    ),
                  ],
                ),
                SizedBox(
                  height: 180,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: selected,
                    minimumDate: validBounds ? minDate : null,
                    maximumDate: validBounds ? maxDate : null,
                    onDateTimeChanged: (dt) {
                      selected = dt;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const Key('btn_confirm_time_picker'),
                    onPressed: () => Navigator.of(sheetCtx).pop(
                      TimeOfDay(hour: selected.hour, minute: selected.minute),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: ShiftIQColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmLabel ?? loc.translate('confirm'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

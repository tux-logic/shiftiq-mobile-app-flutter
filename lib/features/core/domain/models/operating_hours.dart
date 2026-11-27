import 'package:flutter/material.dart';

/// Represents one weekday entry of workshop or branch operating hours.
class OperatingHoursDay {
  final String dayOfWeek;
  final bool open;
  final String? openTime;
  final String? closeTime;
  final int slotDurationMinutes;
  final String? source;

  const OperatingHoursDay({
    required this.dayOfWeek,
    required this.open,
    this.openTime,
    this.closeTime,
    this.slotDurationMinutes = 60,
    this.source,
  });

  OperatingHoursDay copyWith({
    String? dayOfWeek,
    bool? open,
    String? openTime,
    String? closeTime,
    int? slotDurationMinutes,
    String? source,
  }) {
    return OperatingHoursDay(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      open: open ?? this.open,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toRequestJson() => {
        'dayOfWeek': dayOfWeek,
        'open': open,
        'openTime': open ? openTime : null,
        'closeTime': open ? closeTime : null,
        'slotDurationMinutes': slotDurationMinutes,
      };
}

/// Represents a date-specific holiday or special-hours exception.
class OperatingHoursException {
  final String id;
  final String date;
  final bool open;
  final String? openTime;
  final String? closeTime;
  final String? reason;

  const OperatingHoursException({
    required this.id,
    required this.date,
    required this.open,
    this.openTime,
    this.closeTime,
    this.reason,
  });
}

/// Resolved effective operating hours for a specific calendar date.
class EffectiveOperatingHours {
  final bool open;
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;
  final int slotDurationMinutes;
  final String? reason;
  final String source;

  const EffectiveOperatingHours({
    required this.open,
    this.openTime,
    this.closeTime,
    this.slotDurationMinutes = 60,
    this.reason,
    this.source = 'DEFAULT',
  });

  /// Default fallback documented by the backend (`08:30 - 18:00`, 60m slots).
  static const EffectiveOperatingHours defaultFallback = EffectiveOperatingHours(
    open: true,
    openTime: TimeOfDay(hour: 8, minute: 30),
    closeTime: TimeOfDay(hour: 18, minute: 0),
    slotDurationMinutes: 60,
    source: 'DEFAULT',
  );

  /// Latest valid appointment start time within the operating window.
  TimeOfDay? get latestStartTime {
    if (!open || closeTime == null) return null;
    final openMin =
        openTime != null ? openTime!.hour * 60 + openTime!.minute : 0;
    final closeMin = closeTime!.hour * 60 + closeTime!.minute;
    final latestMin = (closeMin - slotDurationMinutes) >= openMin
        ? closeMin - slotDurationMinutes
        : closeMin;
    return TimeOfDay(hour: latestMin ~/ 60, minute: latestMin % 60);
  }

  /// Human-readable range such as `08:30 - 18:00`.
  String get formattedRange {
    if (!open || openTime == null || closeTime == null) return 'Closed';
    return '${_fmt(openTime!)} - ${_fmt(closeTime!)}';
  }

  /// Returns whether [dateTime]'s time-of-day falls inside this open window.
  bool isWithinHours(DateTime dateTime) {
    if (!open || openTime == null || closeTime == null) return false;
    final mins = dateTime.hour * 60 + dateTime.minute;
    final minAllowed = openTime!.hour * 60 + openTime!.minute;
    final maxAllowed = (latestStartTime ?? closeTime!).hour * 60 +
        (latestStartTime ?? closeTime!).minute;
    return mins >= minAllowed && mins <= maxAllowed;
  }

  /// Clamps [dateTime]'s time-of-day to `[openTime, latestStartTime]`.
  DateTime clampDateTime(DateTime dateTime) {
    if (!open || openTime == null || closeTime == null) return dateTime;
    final mins = dateTime.hour * 60 + dateTime.minute;
    final minAllowed = openTime!.hour * 60 + openTime!.minute;
    final maxAllowed = (latestStartTime ?? closeTime!).hour * 60 +
        (latestStartTime ?? closeTime!).minute;
    final clamped = mins.clamp(minAllowed, maxAllowed);
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      clamped ~/ 60,
      clamped % 60,
    );
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? parseTimeOfDay(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return TimeOfDay(hour: h, minute: m);
  }
}

/// Combined weekly schedule and date exceptions for a single branch.
class BranchOperatingSchedule {
  final List<OperatingHoursDay> weeklyDays;
  final List<OperatingHoursException> exceptions;

  const BranchOperatingSchedule({
    this.weeklyDays = const [],
    this.exceptions = const [],
  });

  static const List<String> weekdayKeys = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  /// Resolves effective hours for [date] following backend precedence:
  /// date exception -> weekly day -> default `08:30 - 18:00`.
  EffectiveOperatingHours resolveForDate(DateTime date) {
    final isoDate =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final matchingException =
        exceptions.where((e) => e.date == isoDate).firstOrNull;
    if (matchingException != null) {
      return EffectiveOperatingHours(
        open: matchingException.open,
        openTime:
            EffectiveOperatingHours.parseTimeOfDay(matchingException.openTime),
        closeTime:
            EffectiveOperatingHours.parseTimeOfDay(matchingException.closeTime),
        reason: matchingException.reason,
        source: 'EXCEPTION',
      );
    }

    final dayKey = weekdayKeys[(date.weekday - 1).clamp(0, 6)];
    final matchingDay =
        weeklyDays.where((d) => d.dayOfWeek.toUpperCase() == dayKey).firstOrNull;
    if (matchingDay != null) {
      return EffectiveOperatingHours(
        open: matchingDay.open,
        openTime: EffectiveOperatingHours.parseTimeOfDay(matchingDay.openTime) ??
            (matchingDay.open
                ? EffectiveOperatingHours.defaultFallback.openTime
                : null),
        closeTime:
            EffectiveOperatingHours.parseTimeOfDay(matchingDay.closeTime) ??
                (matchingDay.open
                    ? EffectiveOperatingHours.defaultFallback.closeTime
                    : null),
        slotDurationMinutes: matchingDay.slotDurationMinutes,
        source: matchingDay.source ?? 'BRANCH',
      );
    }

    return EffectiveOperatingHours.defaultFallback;
  }
}

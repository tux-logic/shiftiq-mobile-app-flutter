import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';

class DateStripSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateStripSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Generate dates: 3 days before today up to 14 days ahead
    final dates = List.generate(
      18,
      (index) => today.add(Duration(days: index - 3)),
    );

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;
          final isToday =
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          final weekdayName = _weekdayAbbrev(date.weekday);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDateSelected(date),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primaryLight
                            : AppColors.neutralBorder,
                    width: isToday && !isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekdayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white.withAlpha(200)
                            : AppColors.neutralLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.neutralDark,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekdayAbbrev(int weekday) {
    switch (weekday) {
      case 1:
        return 'LUN';
      case 2:
        return 'MAR';
      case 3:
        return 'MIÉ';
      case 4:
        return 'JUE';
      case 5:
        return 'VIE';
      case 6:
        return 'SÁB';
      case 7:
        return 'DOM';
      default:
        return '';
    }
  }
}

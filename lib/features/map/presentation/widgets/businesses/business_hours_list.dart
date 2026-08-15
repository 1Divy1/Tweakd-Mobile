import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/business_detail_entity.dart';

/// The business's weekly schedule, always all seven days.
///
/// The backend may send a partial `hours` array — **a missing weekday means
/// closed**, so gaps are filled rather than skipped, otherwise the list would
/// read as "we just don't know" when it actually means "shut".
///
/// Times are wall-clock in the business's own timezone and are printed exactly
/// as received; converting them to the viewer's timezone would be wrong.
class BusinessHoursList extends StatelessWidget {
  final BusinessDetailEntity business;

  const BusinessHoursList({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now().weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var weekday = 1; weekday <= 7; weekday++)
          _HoursRow(
            label: _weekdayLabel(l10n, weekday),
            value: _valueFor(l10n, weekday),
            isToday: weekday == today,
          ),
      ],
    );
  }

  String _valueFor(AppLocalizations l10n, int weekday) {
    final hours = business.hoursFor(weekday);
    if (hours == null || hours.isClosed) {
      return hours?.notes ?? l10n.mapHoursClosed;
    }

    final open = hours.openingHour;
    final close = hours.closingHour;
    if (open == null || close == null) return l10n.mapHoursClosed;

    final range = '$open – $close';
    return hours.runsPastMidnight ? '$range ${l10n.mapHoursNextDay}' : range;
  }

  String _weekdayLabel(AppLocalizations l10n, int weekday) => switch (weekday) {
        1 => l10n.mapWeekdayMonday,
        2 => l10n.mapWeekdayTuesday,
        3 => l10n.mapWeekdayWednesday,
        4 => l10n.mapWeekdayThursday,
        5 => l10n.mapWeekdayFriday,
        6 => l10n.mapWeekdaySaturday,
        _ => l10n.mapWeekdaySunday,
      };
}

class _HoursRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isToday;

  const _HoursRow({
    required this.label,
    required this.value,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final weight = isToday ? FontWeight.w700 : FontWeight.w500;
    final color = isToday ? AppColors.ink : AppColors.ink2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: weight, color: color),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: weight,
                color: isToday ? AppColors.ink : AppColors.mute,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

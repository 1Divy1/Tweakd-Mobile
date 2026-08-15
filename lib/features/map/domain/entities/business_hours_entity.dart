import 'package:equatable/equatable.dart';

/// One row of a business's opening schedule.
///
/// [weekday] is ISO-8601 (1 = Monday … 7 = Sunday), which lines up exactly with
/// Dart's `DateTime.weekday`. The list can be empty or partial: **a weekday
/// with no row is closed**, so the UI fills gaps rather than hiding them.
///
/// [openingHour]/[closingHour] are `"HH:mm"` wall-clock strings in the
/// business's own timezone, never UTC — they are displayed verbatim and never
/// converted. A [closingHour] at or before [openingHour] means the business
/// trades past midnight.
class BusinessHoursEntity extends Equatable {
  final int weekday;
  final bool isClosed;
  final String? openingHour;
  final String? closingHour;
  final String? notes;

  const BusinessHoursEntity({
    required this.weekday,
    required this.isClosed,
    this.openingHour,
    this.closingHour,
    this.notes,
  });

  /// True when the shift runs into the next day (e.g. 22:00 → 04:00).
  bool get runsPastMidnight {
    final open = openingHour;
    final close = closingHour;
    if (isClosed || open == null || close == null) return false;
    return close.compareTo(open) <= 0;
  }

  @override
  List<Object?> get props => [weekday, isClosed, openingHour, closingHour, notes];
}

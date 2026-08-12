import 'package:car_social_media_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/map_event_enums.dart';

/// Date, time and distance formatting for the map-events UI.
///
/// Everything here takes a [BuildContext] so `DateFormat` gets the app's active
/// locale — the language switcher would otherwise leave English month names in
/// a Romanian page. Timestamps arrive from the data layer already converted to
/// local time, so nothing here converts again.
class MapEventFormat {
  MapEventFormat._();

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toString();

  /// `09:00`. 24-hour on purpose: the app is metric and European, and an event
  /// list reads better without am/pm noise.
  static String time(BuildContext context, DateTime value) =>
      DateFormat.Hm(_locale(context)).format(value);

  /// `Sun, 16 Aug`
  static String dayAndMonth(BuildContext context, DateTime value) =>
      DateFormat('EEE, d MMM', _locale(context)).format(value);

  /// `16` — the big number on the calendar tile.
  static String dayNumber(BuildContext context, DateTime value) =>
      DateFormat.d(_locale(context)).format(value);

  /// `AUG` — the calendar tile's month strip.
  static String monthShort(BuildContext context, DateTime value) =>
      DateFormat.MMM(_locale(context)).format(value).toUpperCase();

  /// `Sun, 16 Aug · 09:00 – 13:00`, or `Sun, 16 Aug · 09:00` for an open-ended
  /// event. When the end falls on another day it gets its own date, so an
  /// overnight cruise doesn't read as ending nine hours before it started.
  static String dateRange(
    BuildContext context,
    DateTime start,
    DateTime? end,
  ) {
    final head = '${dayAndMonth(context, start)} · ${time(context, start)}';
    if (end == null) return head;

    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    return sameDay
        ? '$head – ${time(context, end)}'
        : '$head – ${dayAndMonth(context, end)}, ${time(context, end)}';
  }

  /// `Fri, 14 Aug, 23:59` — the registration deadline's own format, which
  /// always shows a date because it's usually a different day from the event.
  static String deadline(BuildContext context, DateTime value) =>
      '${dayAndMonth(context, value)}, ${time(context, value)}';

  /// Straight-line distance, in km, as the app shows it everywhere:
  /// one decimal below 10 km, whole numbers above.
  static String distance(AppLocalizations l10n, double km) {
    final text = km < 10 ? km.toStringAsFixed(1) : km.round().toString();
    return l10n.mapEventsDistanceKm(text);
  }

  /// The chip over an event's cover.
  static String statusLabel(AppLocalizations l10n, MapEventStatus status) =>
      switch (status) {
        MapEventStatus.upcoming => l10n.mapEventsStatusUpcoming,
        MapEventStatus.live => l10n.mapEventsStatusLive,
        MapEventStatus.previous => l10n.mapEventsStatusPrevious,
        MapEventStatus.hidden => l10n.mapEventsStatusHidden,
        MapEventStatus.canceled => l10n.mapEventsStatusCanceled,
      };

  /// The badge "My events" puts on anything the admins haven't cleared yet.
  /// Accepted events get no badge — that's the normal state, and labelling it
  /// would just add noise to the list.
  static String? approvalLabel(
    AppLocalizations l10n,
    MapEventApproval approval,
  ) =>
      switch (approval) {
        MapEventApproval.pending => l10n.mapEventsApprovalPending,
        MapEventApproval.rejected => l10n.mapEventsApprovalRejected,
        MapEventApproval.accepted => null,
      };
}

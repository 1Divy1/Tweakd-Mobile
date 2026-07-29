import 'package:car_social_media_app/l10n/app_localizations.dart';

/// Compact "2m / 1h / 1d" age for inbox rows.
String messageCompactAgo(AppLocalizations l10n, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return l10n.messagesTimeNow;
  if (diff.inMinutes < 60) return l10n.messagesTimeMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.messagesTimeHours(diff.inHours);
  if (diff.inDays < 7) return l10n.messagesTimeDays(diff.inDays);
  return l10n.messagesTimeWeeks((diff.inDays / 7).floor());
}

/// Wall-clock "8:12" stamp under bubble groups and on the date pill.
String messageClockTime(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

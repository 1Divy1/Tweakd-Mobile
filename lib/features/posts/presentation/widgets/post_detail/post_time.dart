import '../../../../../l10n/app_localizations.dart';

/// Short, localized relative timestamp for a post or comment (e.g. "3h", "2d").
/// Falls back to an absolute day/month for anything older than ~4 weeks.
String postTimeAgo(AppLocalizations l10n, DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return l10n.postTimeNow;
  if (diff.inMinutes < 60) return l10n.postTimeMinutes(diff.inMinutes);
  if (diff.inHours < 24) return l10n.postTimeHours(diff.inHours);
  if (diff.inDays < 7) return l10n.postTimeDays(diff.inDays);
  if (diff.inDays < 28) return l10n.postTimeWeeks((diff.inDays / 7).floor());
  return '${time.day}/${time.month}/${time.year}';
}

import 'package:car_social_media_app/features/posts/presentation/widgets/post_detail/post_time.dart';
import 'package:car_social_media_app/l10n/app_localizations.dart';

/// The short relative stamp used on cards ("6d", "30m"), reusing the posts
/// time-ago. Anything under a minute is reported as "1m" rather than "now", so
/// the surrounding copy ("… ago") still reads correctly.
String _shortAgo(AppLocalizations l10n, DateTime time) {
  final ago = postTimeAgo(l10n, time);
  return ago == l10n.postTimeNow ? l10n.postTimeMinutes(1) : ago;
}

/// "6d ago" — under the author's name on a board card.
String feedbackCreatedAgo(AppLocalizations l10n, DateTime createdAt) =>
    l10n.feedbackFeedTimeAgo(_shortAgo(l10n, createdAt));

/// "shipped 3d ago" — under the author's name on a completed card. Falls back
/// to the created stamp if the backend ever omits `completed_at`.
String feedbackShippedAgo(
  AppLocalizations l10n,
  DateTime? completedAt,
  DateTime createdAt,
) =>
    l10n.feedbackFeedShippedAgo(_shortAgo(l10n, completedAt ?? createdAt));

/// "1.2k" style compact vote counter, so a runaway request can't blow the
/// button's width out.
String feedbackCompactCount(int n) {
  final sign = n < 0 ? '-' : '';
  final v = n.abs();
  if (v < 1000) return '$sign$v';
  final thousands = v / 1000;
  final digits = thousands >= 10 ? 0 : 1;
  final text = thousands.toStringAsFixed(digits).replaceFirst('.0', '');
  return '$sign${text}k';
}

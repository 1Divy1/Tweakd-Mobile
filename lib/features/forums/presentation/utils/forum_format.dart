import 'package:tweakd/features/posts/presentation/widgets/post_detail/post_time.dart';
import 'package:tweakd/l10n/app_localizations.dart';

/// "1.2k" style compact count for thread/reply counters.
String forumCompactCount(int n) {
  if (n < 1000) return '$n';
  final v = n / 1000;
  final digits = v >= 10 ? 0 : 1;
  final s = v.toStringAsFixed(digits).replaceFirst('.0', '');
  return '${s}k';
}

/// "active 20m ago" line under thread titles, reusing the posts time-ago.
String forumActiveAgo(AppLocalizations l10n, DateTime time) {
  final ago = postTimeAgo(l10n, time);
  if (ago == l10n.postTimeNow) return l10n.forumsActiveNow;
  return l10n.forumsActiveAgo(ago);
}

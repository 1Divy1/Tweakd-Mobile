import 'package:tweakd/l10n/app_localizations.dart';

import '../../domain/entities/contest.dart';

/// Countdown and rank copy for contests. Both times a contest carries are
/// *planned* — an organizer opens and closes it by hand — so the countdowns
/// here are a guide, and once a planned time has passed the copy drops the
/// clock rather than sitting at "0m".
class ContestFormat {
  ContestFormat._();

  /// `1h 18m left` / `4m left`.
  static String timeLeft(AppLocalizations l10n, Duration left) {
    final minutes = _roundedMinutes(left);
    if (minutes < 60) return l10n.contestsTimeLeftMinutes(minutes);
    return l10n.contestsTimeLeftHours(minutes ~/ 60, minutes % 60);
  }

  /// `opens in 48m` / `opens in 1h 5m` / `waiting for the organizer` once the
  /// planned opening has gone by without anyone opening it.
  static String opensIn(AppLocalizations l10n, Duration until) {
    final minutes = _roundedMinutes(until);
    if (minutes <= 0) return l10n.contestsOpensSoon;
    if (minutes < 60) return l10n.contestsOpensInMinutes(minutes);
    return l10n.contestsOpensInHours(minutes ~/ 60, minutes % 60);
  }

  /// The chip on a card: while open, the countdown to the planned end (or a
  /// plain "voting open" past it); "opens in" while scheduled; "results in"
  /// once finished.
  static String chipLabel(
    AppLocalizations l10n,
    ContestEntity contest,
    DateTime now,
  ) {
    if (contest.isFinished) return l10n.contestsResultsIn;
    if (contest.isOpen) return openLabel(l10n, contest, now);
    return opensIn(l10n, contest.opensIn(now));
  }

  /// An open contest's line: the countdown while the planned end is ahead,
  /// "voting open" after it — the organizer closes it when they close it.
  static String openLabel(
    AppLocalizations l10n,
    ContestEntity contest,
    DateTime now,
  ) {
    return contest.hasPlannedTimeLeft(now)
        ? timeLeft(l10n, contest.timeLeft(now))
        : l10n.contestsVotingOpenNow;
  }

  /// `1st` / `2nd` / `3rd` / `4th`.
  static String rank(AppLocalizations l10n, int rank) => switch (rank) {
        1 => l10n.contestsRank1,
        2 => l10n.contestsRank2,
        3 => l10n.contestsRank3,
        _ => l10n.contestsRankN(rank),
      };

  static int _roundedMinutes(Duration d) {
    if (d.isNegative) return 0;
    return (d.inSeconds / 60).round();
  }
}

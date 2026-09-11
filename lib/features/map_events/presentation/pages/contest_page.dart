import 'dart:async';

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/contest.dart';
import '../bloc/contest_detail/bloc.dart';
import '../bloc/contest_detail/event.dart';
import '../bloc/contest_detail/state.dart';
import '../bloc/event_contests/bloc.dart';
import '../bloc/event_contests/event.dart' as tab_events;
import '../utils/contest_formatting.dart';
import '../utils/map_event_error_mapper.dart';
import '../utils/participant_card_builder.dart';
import '../widgets/contests/contest_status_chip.dart';
import '../widgets/contests/leaderboard_row.dart';
import '../widgets/contests/participant_card_share_sheet.dart';
import '../widgets/contests/vote_sheet.dart';
import '../widgets/contests/winner_reveal.dart';
import '../widgets/shared/map_event_chips.dart';

/// One contest: header with the three stats, the judging note, the board,
/// and a footer that is the vote CTA while open and the share button once
/// finished. The header goes dark once results are in — the one page-level
/// style the design uses to say "this is over".
///
/// Optionally receives the tab's [EventContestsBloc] so a vote here updates
/// the tab's card without a read when the user goes back.
class ContestPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final EventContestsBloc? tabBloc;

  const ContestPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    this.tabBloc,
  });

  @override
  State<ContestPage> createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Countdown copy ticks once a minute; the board itself moves on realtime.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ContestDetailBloc, ContestDetailState>(
      listenWhen: (a, b) =>
          a.actionError != b.actionError ||
          a.justVotedCarId != b.justVotedCarId ||
          a.contest != b.contest,
      listener: (context, state) {
        final contest = state.contest;
        if (contest != null && !state.isVoting) {
          widget.tabBloc?.add(tab_events.EventContestUpdated(contest));
        }
        final error = state.actionError;
        final voted = state.justVotedCarId;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(mapEventErrorMessage(l10n, error)),
            behavior: SnackBarBehavior.floating,
          ));
          context.read<ContestDetailBloc>().add(const ClearContestActionError());
        } else if (voted != null && contest != null) {
          final entry = contest.entryFor(voted);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.contestsVoteCounted(
              entry == null ? '' : '${entry.car.brand} ${entry.car.model}',
            )),
            behavior: SnackBarBehavior.floating,
          ));
          context.read<ContestDetailBloc>().add(const ClearContestActionError());
        }
      },
      builder: (context, state) {
        final contest = state.contest;
        final finished = contest?.isFinished ?? false;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: contest == null
              ? _LoadingOrError(state: state)
              : Column(
                  children: [
                    _Header(
                      contest: contest,
                      eventTitle: widget.eventTitle,
                      now: _now,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: () async => context
                            .read<ContestDetailBloc>()
                            .add(const RefreshContest()),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
                          children: [
                            if (finished) ...[
                              WinnerReveal(
                                contest: contest,
                                onShare: () => _share(context, contest),
                              ),
                              const SizedBox(height: 20),
                            ],
                            _Criteria(contest: contest),
                            const SizedBox(height: 20),
                            _Board(
                              contest: contest,
                              isVoting: state.isVoting,
                              now: _now,
                              onVote: (carId) => context
                                  .read<ContestDetailBloc>()
                                  .add(CastVote(carId)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _Footer(
                      contest: contest,
                      isVoting: state.isVoting,
                      now: _now,
                      onVote: () => _pickVote(context, contest),
                      onShare: () => _share(context, contest),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _pickVote(BuildContext context, ContestEntity contest) async {
    final bloc = context.read<ContestDetailBloc>();
    final carId = await showVoteSheet(context, contest: contest, now: _now);
    if (carId != null) bloc.add(CastVote(carId));
  }

  /// The finished contest's share action.
  ///
  /// The viewer's own card is server-derived: it exists only once an organizer
  /// marks the whole event finished, and it lives on the event page — so an
  /// entrant is sent there, or told it isn't ready yet. Anyone else can still
  /// send the winner's result out through the OS share sheet; it isn't theirs,
  /// so it isn't postable.
  Future<void> _share(BuildContext context, ContestEntity contest) async {
    if (contest.myEntry != null) {
      if (contest.event?.isFinished ?? false) {
        await context.push('/map-events/${widget.eventId}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.participantCardNotReady),
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }
    final entry = contest.winner;
    if (entry == null) return;

    // The tab bloc knows every contest of the event, which is what makes the
    // card's contests list complete; a deep link has only this one.
    final eventContests = widget.tabBloc?.state.contests ?? const [];
    final data = ParticipantCardBuilder.build(
      eventContests:
          eventContests.any((c) => c.id == contest.id) ? eventContests : [contest],
      carId: entry.car.id,
      fallbackEventTitle: widget.eventTitle,
    );
    if (data == null) return;

    final router = GoRouter.of(context);
    final eventId = widget.eventId;
    await showParticipantCardShareSheet(
      context,
      data: data,
      isMine: false,
      // The car route reads ownership from `extra`; without it the owner's own
      // car opens read-only.
      onOpenCar: () =>
          router.push('/garage/cars/${data.car.id}', extra: false),
      onOpenEvent: () => router.push('/map-events/$eventId'),
      onOpenContest: (contestId) =>
          router.push('/map-events/$eventId/contests/$contestId'),
    );
  }
}

class _Header extends StatelessWidget {
  final ContestEntity contest;
  final String eventTitle;
  final DateTime now;

  const _Header({required this.contest, required this.eventTitle, required this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final finished = contest.isFinished;
    final live = contest.isOpen;
    final fg = finished ? Colors.white : AppColors.ink;
    final muted = finished ? Colors.white.withValues(alpha: 0.6) : AppColors.mute;

    final stats = [
      ('${contest.votesCount}', l10n.contestsStatVotesCast, false),
      ('${contest.entries.length}', l10n.contestsStatCarsIn, false),
      finished
          ? (l10n.contestsClosed, l10n.contestsStatVoting, false)
          : live
              ? (
                  ContestFormat.openLabel(l10n, contest, now).toUpperCase(),
                  contest.hasPlannedTimeLeft(now)
                      ? l10n.contestsStatRemaining
                      : l10n.contestsStatStatus,
                  true,
                )
              : (
                  ContestFormat.opensIn(l10n, contest.opensIn(now)).toUpperCase(),
                  l10n.contestsStatStatus,
                  false,
                ),
    ];

    return Container(
      color: finished ? AppColors.ink : AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: fg,
                  ),
                  Expanded(
                    child: Text(
                      eventTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
                  if (live) ...[
                    const SizedBox(width: 8),
                    ContestStatusChip(contest: contest, now: now, small: true),
                  ],
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      contest.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 18,
                      runSpacing: 10,
                      children: [
                        for (final (value, label, accent) in stats)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: accent && !finished ? AppColors.accent : fg,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Criteria extends StatelessWidget {
  final ContestEntity contest;

  const _Criteria({required this.contest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final criteria = contest.criteria;
    final author = contest.createdByUsername;
    if ((criteria == null || criteria.isEmpty) && author == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(
          label: contest.isFinished ? l10n.contestsHowItWasJudged : l10n.contestsHowItWorks,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (criteria != null && criteria.isNotEmpty)
                Text(
                  criteria,
                  style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.ink2),
                ),
              if (author != null) ...[
                if (criteria != null && criteria.isNotEmpty) const SizedBox(height: 11),
                Text(
                  l10n.contestsSetBy(author),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.mute),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Board extends StatelessWidget {
  final ContestEntity contest;
  final bool isVoting;
  final DateTime now;
  final ValueChanged<String> onVote;

  const _Board({
    required this.contest,
    required this.isVoting,
    required this.now,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewer = contest.viewer;
    final votable = viewer.canVote && !isVoting;
    final ownCars = viewer.liveEntryCarIds.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MapEventSectionLabel(
                label: contest.isFinished
                    ? l10n.contestsFinalStandings
                    : contest.isScheduled
                        ? l10n.contestsCarsEntered
                        : l10n.contestsLeaderboard,
              ),
            ),
            if (contest.isOpen)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LiveDot(color: AppColors.accent),
                  const SizedBox(width: 5),
                  Text(
                    l10n.contestsUpdatingLive,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (contest.entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.contestsNoEntriesYet,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.mute),
            ),
          ),
        for (final entry in contest.entries) ...[
          LeaderboardRow(
            entry: entry,
            totalVotes: contest.votesCount,
            isMine: viewer.voteCarId == entry.car.id,
            showVoteButton: contest.isOpen && viewer.canVote && !ownCars.contains(entry.car.id),
            onVote: votable ? () => onVote(entry.car.id) : null,
          ),
          const SizedBox(height: 7),
        ],
        if (contest.isScheduled) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              l10n.contestsVotingOpensAt(TimeOfDay.fromDateTime(contest.opensAt).format(context)),
              style: const TextStyle(fontSize: 12, color: AppColors.muteSoft),
            ),
          ),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final ContestEntity contest;
  final bool isVoting;
  final DateTime now;
  final VoidCallback onVote;
  final VoidCallback onShare;

  const _Footer({
    required this.contest,
    required this.isVoting,
    required this.now,
    required this.onVote,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewer = contest.viewer;

    Widget? child;
    if (contest.isFinished) {
      // An entrant's button leads to their card (on the event page, once the
      // organizer finishes the event); anyone else can share the result. With
      // no winner at all (nobody voted) an entrant still has a card.
      final mine = contest.myEntry != null;
      if (mine || contest.winner != null) {
        child = _Primary(
          label: mine ? l10n.participantCardYourCard : l10n.contestsShareTheResult,
          icon: mine ? Icons.emoji_events_rounded : Icons.ios_share_rounded,
          filled: mine,
          onTap: onShare,
        );
      }
    } else if (contest.isOpen) {
      if (!viewer.canVote) {
        child = _Hint(text: l10n.contestsAttendToVote);
      } else if (viewer.hasVoted) {
        final entry = contest.myVoteEntry;
        child = Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.contestsYourVote,
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    entry == null ? '—' : '${entry.car.brand} ${entry.car.model}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: isVoting ? null : onVote,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.bg,
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              child: Text(l10n.contestsChange),
            ),
          ],
        );
      } else {
        child = _Primary(
          label: contest.isClosingSoon(now)
              ? l10n.contestsVoteBeforeClose
              : l10n.contestsCastYourVote,
          icon: Icons.check_rounded,
          filled: true,
          onTap: isVoting ? null : onVote,
        );
      }
    }
    if (child == null) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: child,
        ),
      ),
    );
  }
}

class _Primary extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _Primary({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: filled ? AppColors.accent : AppColors.bg,
          foregroundColor: filled ? Colors.white : AppColors.ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.mute),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12.5, color: AppColors.mute)),
        ),
      ],
    );
  }
}

class _LoadingOrError extends StatelessWidget {
  final ContestDetailState state;

  const _LoadingOrError({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final error = state.error;

    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 12,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.ink,
            ),
          ),
          Center(
            child: error == null
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 34, color: AppColors.muteSoft),
                        const SizedBox(height: 14),
                        Text(
                          mapEventErrorMessage(l10n, error),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14.5, height: 1.4, color: AppColors.ink2),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.read<ContestDetailBloc>().add(const RefreshContest()),
                          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                          child: Text(l10n.mapEventsRetry),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest.dart';
import '../../bloc/event_contests/state.dart';
import '../shared/map_event_chips.dart';
import 'contest_card.dart';

/// The CONTESTS tab: the viewer's standing strip, then VOTING OPEN NOW /
/// OPENS LATER / RESULTS, then the one-line rule at the bottom.
class ContestsTab extends StatelessWidget {
  final EventContestsState state;
  final DateTime now;

  /// The viewer's first accepted event car's name, for the standing strip.
  final String? myCarName;
  final bool showEnter;
  final ValueChanged<ContestEntity> onOpen;
  final VoidCallback onEnter;

  const ContestsTab({
    super.key,
    required this.state,
    required this.now,
    required this.myCarName,
    required this.showEnter,
    required this.onOpen,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.status == EventContestsStatus.loading && !state.hasContests) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasContests) {
      return _Empty(title: l10n.contestsEmptyTitle, body: l10n.contestsEmptyBody);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showEnter) ...[
          _StandingStrip(
            state: state,
            myCarName: myCarName,
            onEnter: onEnter,
          ),
          const SizedBox(height: 20),
        ],
        _Group(
          label: l10n.contestsSectionVotingOpen,
          contests: state.open,
          now: now,
          onOpen: onOpen,
        ),
        _Group(
          label: l10n.contestsSectionOpensLater,
          contests: state.scheduled,
          now: now,
          onOpen: onOpen,
        ),
        _Group(
          label: l10n.contestsSectionResults,
          contests: state.finished,
          now: now,
          onOpen: onOpen,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            l10n.contestsFooterNote,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: AppColors.muteSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  final String label;
  final List<ContestEntity> contests;
  final DateTime now;
  final ValueChanged<ContestEntity> onOpen;

  const _Group({
    required this.label,
    required this.contests,
    required this.now,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (contests.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MapEventSectionLabel(label: label),
        const SizedBox(height: 10),
        for (final c in contests) ...[
          ContestCard(contest: c, now: now, onOpen: () => onOpen(c)),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

/// The dark strip at the top: "Your M4 is entered in 2 contests · 1 vote
/// still open to you", with ENTER / MANAGE.
class _StandingStrip extends StatelessWidget {
  final EventContestsState state;
  final String? myCarName;
  final VoidCallback onEnter;

  const _StandingStrip({
    required this.state,
    required this.myCarName,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entered = state.myEnteredCount;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.inkPanel.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 16,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entered > 0
                      ? l10n.contestsStandingEntered(entered)
                      : l10n.contestsStandingNotEntered,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkPanel,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.contestsVotesOpenToYou(state.unvotedOpenCount),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.inkPanel.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: state.isSaving ? null : onEnter,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.inkPanel.withValues(alpha: 0.12),
              foregroundColor: AppColors.inkPanel,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
            child: state.isSaving
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.inkPanel,
                    ),
                  )
                : Text(entered > 0 ? l10n.contestsManage : l10n.contestsEnterCar),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String title;
  final String body;

  const _Empty({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.emoji_events_outlined,
              size: 20,
              color: AppColors.muteSoft,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.mute,
            ),
          ),
        ],
      ),
    );
  }
}

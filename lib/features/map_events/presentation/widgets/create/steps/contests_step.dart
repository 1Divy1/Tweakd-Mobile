import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/create_contest/state.dart';
import '../../../bloc/create_event/bloc.dart';
import '../../../bloc/create_event/event.dart';
import '../../../bloc/create_event/state.dart';
import '../../../utils/map_event_formatting.dart';
import '../create_event_chrome.dart';
import '../create_event_fields.dart';
import 'draft_contest_sheet.dart';

/// Step 5 — contests, all of them optional.
///
/// Nothing here talks to the API. Contests can only be created against an event
/// id, so these are held as [PendingContest] rows and flushed by
/// `CreateMapEventBloc` once `POST /map-events` has landed. They are born
/// `scheduled` and stay inert until the organizer opens voting, which the
/// backend still refuses to do before staff approve the event.
class ContestsStep extends StatelessWidget {
  final CreateMapEventState state;

  const ContestsStep({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<CreateMapEventBloc>();
    final isFull =
        state.pendingContests.length >= CreateMapEventBloc.maxContests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateEventStepHeader(
          title: l10n.mapEventsStepContestsTitle,
          subtitle: l10n.mapEventsStepContestsSubtitle,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: CreateEventOptionalChip(label: l10n.mapEventsOptional),
        ),
        const SizedBox(height: 16),

        // The step stays reachable when the category list didn't load — it's
        // optional, and blocking the whole wizard on reference data for a step
        // the organizer can skip would be the wrong trade.
        if (state.contestCategories.isEmpty) ...[
          EventHint(l10n.mapEventsContestsUnavailable),
        ] else ...[
          for (final contest in state.pendingContests) ...[
            _DraftContestCard(
              contest: contest,
              startsAt: state.startsAt,
              endsAt: state.endsAt,
              onEdit: () => _edit(context, contest),
              onRemove: () => bloc.add(RemoveDraftContest(contest.localId)),
            ),
            const SizedBox(height: 8),
          ],
          if (isFull)
            EventHint(
              l10n.mapEventsContestsFullHint(CreateMapEventBloc.maxContests),
            )
          else
            EventDashedButton(
              label: l10n.mapEventsAddContest,
              icon: Icons.emoji_events_outlined,
              onTap: () => _edit(context, null),
            ),
        ],
      ],
    );
  }

  Future<void> _edit(BuildContext context, PendingContest? editing) async {
    final bloc = context.read<CreateMapEventBloc>();

    final result = await showDraftContestSheet(
      context,
      categories: state.contestCategories,
      eventStartsAt: state.startsAt,
      eventEndsAt: state.endsAt,
      editing: editing,
    );
    if (result == null) return;

    bloc.add(
      editing == null ? AddDraftContest(result) : UpdateDraftContest(result),
    );
  }
}

class _DraftContestCard extends StatelessWidget {
  final PendingContest contest;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _DraftContestCard({
    required this.contest,
    required this.startsAt,
    required this.endsAt,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(kCreateEventRadius),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(kCreateEventRadius),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contest.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _window(context, l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.3,
                        color: AppColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.mute,
                tooltip: l10n.mapEventsRemoveContest,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The voting window in words. The opening side falls back to naming the
  /// choice until the event's start is set; the closing side is always a real
  /// instant the organizer picked.
  String _window(BuildContext context, AppLocalizations l10n) {
    final start = startsAt;
    final closes = contest.closesAt;
    if (start == null) {
      final opens = switch (contest.opensChoice) {
        ContestOpensChoice.now => l10n.mapEventsContestOpensNow,
        ContestOpensChoice.atEventStart => l10n.mapEventsContestOpensAtStart,
        ContestOpensChoice.custom => l10n.mapEventsContestCustomTime,
      };
      final closesLabel = closes == null
          ? l10n.mapEventsContestCustomTime
          : MapEventFormat.deadline(context, closes);
      return '$opens → $closesLabel';
    }

    final times = contest.resolve(start, endsAt);
    return '${MapEventFormat.deadline(context, times.opensAt)} → '
        '${MapEventFormat.deadline(context, times.closesAt)}';
  }
}

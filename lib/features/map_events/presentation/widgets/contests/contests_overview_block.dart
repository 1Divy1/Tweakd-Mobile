import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest.dart';
import '../../bloc/event_contests/state.dart';
import 'contest_card.dart';

/// The CONTESTS block on the Overview tab: the two most relevant contests
/// (live ones first) and an "ALL N CONTESTS" button into the tab. With no
/// contests, the quiet "No contests" card the event page always had.
class ContestsOverviewBlock extends StatelessWidget {
  final EventContestsState state;
  final DateTime now;
  final ValueChanged<ContestEntity> onOpen;
  final VoidCallback onSeeAll;

  const ContestsOverviewBlock({
    super.key,
    required this.state,
    required this.now,
    required this.onOpen,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!state.hasContests) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.emoji_events_outlined,
                size: 17,
                color: AppColors.muteSoft,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.contestsEmptyTitle,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.contestsEmptyBody,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: AppColors.ink2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final live = state.open;
    final shown = (live.isNotEmpty ? live : state.contests).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final c in shown) ...[
          ContestCard(contest: c, now: now, onOpen: () => onOpen(c)),
          const SizedBox(height: 12),
        ],
        if (state.contests.length > shown.length)
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.contestsAllCount(state.contests.length),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.ink,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

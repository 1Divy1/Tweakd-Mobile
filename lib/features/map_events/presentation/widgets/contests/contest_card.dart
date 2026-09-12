import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest.dart';
import 'contest_category_icon.dart';
import 'contest_status_chip.dart';
import 'leaderboard_row.dart';

/// The compact card on the contests tab and the overview block: title, chip,
/// "N cars · N votes", then whatever the state calls for — the top two rows
/// and a vote CTA while open, the stacked entrants while scheduled, the winner
/// row once finished. Tap anywhere to open the contest.
class ContestCard extends StatelessWidget {
  final ContestEntity contest;
  final DateTime now;
  final VoidCallback onOpen;

  const ContestCard({
    super.key,
    required this.contest,
    required this.now,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final live = contest.isOpen;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: live ? AppColors.accentSoft : AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: ContestCategoryGlyph(
                      icon: contest.category.icon,
                      color: live ? AppColors.accent : AppColors.mute,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          contest.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 7,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ContestStatusChip(contest: contest, now: now, small: true),
                            Text(
                              l10n.contestsCarsAndVotes(
                                contest.entries.length,
                                contest.votesCount,
                              ),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.mute,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.muteSoft,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (contest.isFinished)
                _WinnerRow(contest: contest)
              else if (contest.isScheduled)
                _EntrantsRow(contest: contest)
              else
                _LiveRows(contest: contest, now: now),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinnerRow extends StatelessWidget {
  final ContestEntity contest;

  const _WinnerRow({required this.contest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final winner = contest.winner;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: winner == null
          ? Text(
              l10n.contestsNoVotesResult,
              style: TextStyle(fontSize: 12.5, color: AppColors.mute),
            )
          : Row(
              children: [
                CarImage(
                  imageUrl: winner.car.coverImage?.url,
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.contestsWinner,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        '${winner.car.brand} ${winner.car.model}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${winner.votesCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
    );
  }
}

class _EntrantsRow extends StatelessWidget {
  final ContestEntity contest;

  const _EntrantsRow({required this.contest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shown = contest.entries.take(4).toList();
    final mine = contest.viewer.liveEntryCarIds.isNotEmpty;

    return Row(
      children: [
        if (shown.isNotEmpty) ...[
          SizedBox(
            height: 26,
            width: 26 + (shown.length - 1) * 19.0,
            child: Stack(
              children: [
                for (var i = 0; i < shown.length; i++)
                  Positioned(
                    left: i * 19.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: CarImage(
                        imageUrl: shown[i].car.coverImage?.url,
                        width: 22,
                        height: 22,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            [
              l10n.contestsCarsEnteredCount(contest.entries.length),
              if (mine) l10n.contestsYoursIsIn,
            ].join(' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: AppColors.mute),
          ),
        ),
      ],
    );
  }
}

class _LiveRows extends StatelessWidget {
  final ContestEntity contest;
  final DateTime now;

  const _LiveRows({required this.contest, required this.now});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final top = contest.entries.take(2).toList();
    final viewer = contest.viewer;
    final soon = contest.isClosingSoon(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (top.isEmpty)
          Text(
            l10n.contestsNoEntriesYet,
            style: TextStyle(fontSize: 12.5, color: AppColors.mute),
          ),
        for (var i = 0; i < top.length; i++) ...[
          if (i > 0) const SizedBox(height: 5),
          LeaderboardRow(
            entry: top[i],
            totalVotes: contest.votesCount,
            isMine: viewer.voteCarId == top[i].car.id,
            dense: true,
          ),
        ],
        if (viewer.canVote && !viewer.hasVoted) ...[
          const SizedBox(height: 8),
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    soon ? l10n.contestsVoteBeforeClose : l10n.contestsCastYourVote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest.dart';
import '../../utils/contest_formatting.dart';
import '../../utils/map_event_formatting.dart';
import 'contest_category_icon.dart';
import 'contest_status_chip.dart';
import 'leaderboard_row.dart';

/// One contest on the organizer's console. Open: the top three live rows and
/// FULL BOARD / FINISH NOW. Scheduled: EDIT / OPEN VOTING NOW. Finished: the
/// winner row and "results published". Pending entry requests, when any,
/// sit between the header and the actions with ACCEPT / DECLINE per car.
class OrgContestCard extends StatelessWidget {
  final ContestEntity contest;
  final DateTime now;
  final bool isBusy;
  final VoidCallback onOpen;
  final VoidCallback onFinish;
  final VoidCallback onOpenNow;
  final VoidCallback onExtend;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(String carId) onAccept;
  final void Function(String carId) onDecline;

  const OrgContestCard({
    super.key,
    required this.contest,
    required this.now,
    required this.isBusy,
    required this.onOpen,
    required this.onFinish,
    required this.onOpenNow,
    required this.onExtend,
    required this.onEdit,
    required this.onDelete,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final live = contest.isOpen;
    final finished = contest.isFinished;
    final subtitle = live
        ? l10n.contestsLeftAndVotes(
            ContestFormat.openLabel(l10n, contest, now),
            contest.votesCount,
          )
        : finished
            ? l10n.contestsClosedAtVotes(
                MapEventFormat.time(context, contest.finishedAt ?? contest.closesAt),
                contest.votesCount,
              )
            : l10n.contestsOpensAndCars(
                ContestFormat.opensIn(l10n, contest.opensIn(now)),
                contest.entries.length,
              );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: live ? AppColors.accentSoft : AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: ContestCategoryGlyph(
                  icon: contest.category.icon,
                  color: live ? AppColors.accent : AppColors.mute,
                  size: 17,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: InkWell(
                  onTap: onOpen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        contest.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.mute),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StateChip(contest: contest),
            ],
          ),
          if (contest.pendingEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            _PendingEntries(
              contest: contest,
              isBusy: isBusy,
              onAccept: onAccept,
              onDecline: onDecline,
            ),
          ],
          if ((live || finished) && contest.entries.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final entry in contest.entries.take(live ? 3 : 1)) ...[
              LeaderboardRow(entry: entry, totalVotes: contest.votesCount, dense: true),
              const SizedBox(height: 6),
            ],
          ],
          const SizedBox(height: 6),
          if (live)
            Row(
              children: [
                Expanded(
                  child: _Action(label: l10n.contestsFullBoard, onTap: onOpen),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Action(label: l10n.contestsExtend, onTap: isBusy ? null : onExtend),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Action(
                    label: l10n.contestsFinishNow,
                    icon: Icons.emoji_events_rounded,
                    dark: true,
                    onTap: isBusy ? null : onFinish,
                  ),
                ),
              ],
            )
          else if (contest.isScheduled)
            Row(
              children: [
                _IconAction(icon: Icons.delete_outline_rounded, onTap: isBusy ? null : onDelete),
                const SizedBox(width: 8),
                Expanded(
                  child: _Action(label: l10n.contestsEdit, onTap: isBusy ? null : onEdit),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _Action(
                    label: l10n.contestsOpenVotingNow,
                    accent: true,
                    onTap: isBusy ? null : onOpenNow,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 14, color: AppColors.mute),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      contest.winner == null
                          ? l10n.contestsNoVotesResult
                          : l10n.contestsResultsPublished,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.ink2),
                    ),
                  ),
                ],
              ),
            ),
          if (isBusy) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(minHeight: 2, color: AppColors.accent),
          ],
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final ContestEntity contest;

  const _StateChip({required this.contest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (bg, fg, label) = contest.isOpen
        ? (AppColors.accent, Colors.white, l10n.contestsChipOpen)
        : contest.isFinished
            ? (AppColors.ink, Colors.white, l10n.contestsChipClosed)
            : (AppColors.bg, AppColors.mute, l10n.contestsChipScheduled);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contest.isOpen) ...[const LiveDot(), const SizedBox(width: 5)],
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingEntries extends StatelessWidget {
  final ContestEntity contest;
  final bool isBusy;
  final void Function(String carId) onAccept;
  final void Function(String carId) onDecline;

  const _PendingEntries({
    required this.contest,
    required this.isBusy,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.accentSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.contestsPendingEntries(contest.pendingEntries.length),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          for (final pending in contest.pendingEntries) ...[
            Row(
              children: [
                CarImage(
                  imageUrl: pending.car.coverImage?.url,
                  width: 34,
                  height: 34,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${pending.car.brand} ${pending.car.model}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        pending.car.ownerUsername == null ? '' : '@${pending.car.ownerUsername}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.mute),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _SmallAction(
                  label: l10n.contestsDecline,
                  onTap: isBusy ? null : () => onDecline(pending.car.id),
                ),
                const SizedBox(width: 6),
                _SmallAction(
                  label: l10n.contestsAccept,
                  accent: true,
                  onTap: isBusy ? null : () => onAccept(pending.car.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool dark;
  final bool accent;
  final VoidCallback? onTap;

  const _Action({
    required this.label,
    this.icon,
    this.dark = false,
    this.accent = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = accent ? AppColors.accent : dark ? AppColors.ink : AppColors.bg;
    final fg = accent || dark ? Colors.white : AppColors.ink;

    return Material(
      color: onTap == null ? bg.withValues(alpha: 0.6) : bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: dark ? AppColors.accent : fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: onTap == null ? AppColors.muteSoft : AppColors.ink2),
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final bool accent;
  final VoidCallback? onTap;

  const _SmallAction({required this.label, this.accent = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: accent ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

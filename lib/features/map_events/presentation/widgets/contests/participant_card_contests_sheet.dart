import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../utils/contest_formatting.dart';
import 'participant_card.dart';

/// Every contest the card's car was entered in, each row tapping through to
/// that contest.
///
/// This is where the card's "+N more" goes. The card itself must stay a fixed
/// height whatever the contest count, so it cannot expand in place — and the
/// owner asked for the full list on that tap.
Future<void> showParticipantCardContestsSheet(
  BuildContext context, {
  required List<ParticipantCardContest> contests,
  required void Function(String contestId) onOpenContest,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ContestsSheet(
      contests: contests,
      onOpenContest: onOpenContest,
    ),
  );
}

class _ContestsSheet extends StatelessWidget {
  final List<ParticipantCardContest> contests;
  final void Function(String contestId) onOpenContest;

  const _ContestsSheet({required this.contests, required this.onOpenContest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.participantCardContestsSheetTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.ink,
                    style: IconButton.styleFrom(backgroundColor: AppColors.bg),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: contests.length,
                itemBuilder: (context, i) => _ContestRow(
                  contest: contests[i],
                  onTap: () {
                    // Close the sheet first so the contest page isn't pushed
                    // underneath it.
                    Navigator.of(context).pop();
                    onOpenContest(contests[i].contestId);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContestRow extends StatelessWidget {
  final ParticipantCardContest contest;
  final VoidCallback onTap;

  const _ContestRow({required this.contest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rank = contest.rank;
    final onPodium = contest.isOnPodium;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          children: [
            if (onPodium)
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            Expanded(
              child: Text(
                contest.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              // A placement when there is one, else plainly that they entered.
              rank != null && onPodium
                  ? ContestFormat.rank(l10n, rank)
                  : l10n.participantCardTookPart,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: onPodium
                    ? AppColors.ink
                    : AppColors.ink.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.ink.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

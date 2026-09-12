import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/contest.dart';
import 'contest_rank_badge.dart';

/// The finished contest's hero: the winner's cover under a WINNER pill, who
/// owns it and by how much, then the "badge awarded" row. If the viewer's own
/// car is on the podium, the "That's your car — SHARE" strip follows.
class WinnerReveal extends StatelessWidget {
  final ContestEntity contest;
  final VoidCallback onShare;

  const WinnerReveal({super.key, required this.contest, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final winner = contest.winner;
    final mine = contest.myPodiumEntry;

    if (winner == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, size: 20, color: AppColors.muteSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.contestsNoWinner,
                style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.ink2),
              ),
            ),
          ],
        ),
      );
    }

    final owner = winner.car.ownerUsername;
    final shortCategory = contest.category.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.push('/garage/cars/${winner.car.id}', extra: false),
                child: AspectRatio(
                  aspectRatio: 2.1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CarImage(imageUrl: winner.car.coverImage?.url, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x000A0A0A), Color(0xD10A0A0A)],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                l10n.contestsWinner,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${winner.car.brand} ${winner.car.model}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (owner != null && owner.isNotEmpty) '@$owner',
                                l10n.contestsVotesOf(winner.votesCount, contest.votesCount),
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
                child: Row(
                  children: [
                    ContestRankBadge(icon: contest.category.icon, rank: 1, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.contestsBadgeAwarded(shortCategory),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.contestsBadgeAwardedBody,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.5, color: AppColors.mute),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (mine != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: AppColors.accentSoft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.contestsThatsYourCar,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.contestsPostToFeedHint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: AppColors.ink2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onShare,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                  child: Text(l10n.contestsShare),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

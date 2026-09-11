import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/features/garage/presentation/widgets/car_image.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/contest.dart';

/// One leaderboard row: rank, cover, brand + model over @owner, the count and
/// its share. The viewer's own vote gets the accent wash and ring; a VOTE /
/// VOTED button appears while voting is open. Tapping the car opens its page.
class LeaderboardRow extends StatelessWidget {
  final ContestEntryEntity entry;
  final int totalVotes;
  final bool isMine;
  final bool dense;
  final bool showVoteButton;
  final VoidCallback? onVote;

  const LeaderboardRow({
    super.key,
    required this.entry,
    required this.totalVotes,
    this.isMine = false,
    this.dense = false,
    this.showVoteButton = false,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final car = entry.car;
    final rank = entry.finalRank ?? entry.rank;
    final lead = rank == 1 && totalVotes > 0;
    final pct = totalVotes == 0 ? 0 : (entry.votesCount / totalVotes * 100).round();
    final owner = car.ownerUsername;

    return Material(
      color: isMine ? AppColors.accentSoft.withValues(alpha: 0.45) : AppColors.bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/garage/cars/${car.id}', extra: false),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 10 : 11,
            vertical: dense ? 7 : 9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: isMine
                ? Border.all(color: AppColors.accent, width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: lead ? 17 : 14,
                    fontWeight: FontWeight.w800,
                    color: lead
                        ? AppColors.accent
                        : rank <= 3
                            ? AppColors.ink
                            : AppColors.muteSoft,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CarImage(
                imageUrl: car.coverImage?.url,
                width: dense ? 34 : 40,
                height: dense ? 34 : 40,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${car.brand} ${car.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: dense ? 12.5 : 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (owner != null && owner.isNotEmpty) '@$owner',
                        if (isMine) '· ${l10n.contestsYourVote}',
                      ].join(' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isMine ? FontWeight.w700 : FontWeight.w500,
                        color: isMine ? AppColors.accent : AppColors.mute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedCount(
                    value: entry.votesCount,
                    style: TextStyle(
                      fontSize: dense ? 14 : 15.5,
                      fontWeight: FontWeight.w800,
                      color: lead ? AppColors.accent : AppColors.ink,
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.mute,
                    ),
                  ),
                ],
              ),
              if (showVoteButton) ...[
                const SizedBox(width: 8),
                _VoteButton(isMine: isMine, onTap: onVote),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The count pops when it changes, so a moving board reads as moving.
class _AnimatedCount extends StatefulWidget {
  final int value;
  final TextStyle style;

  const _AnimatedCount({required this.value, required this.style});

  @override
  State<_AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<_AnimatedCount> {
  double _scale = 1;

  @override
  void didUpdateWidget(covariant _AnimatedCount old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      setState(() => _scale = 1.18);
      Future.delayed(const Duration(milliseconds: 220), () {
        if (mounted) setState(() => _scale = 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Text('${widget.value}', style: widget.style),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final bool isMine;
  final VoidCallback? onTap;

  const _VoteButton({required this.isMine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: isMine ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Text(
            isMine ? l10n.contestsVoted : l10n.contestsVote,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: isMine ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

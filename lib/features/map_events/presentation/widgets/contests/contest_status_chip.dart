import 'package:tweakd/core/theme/app_colors.dart';
import 'package:tweakd/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/contest.dart';
import '../../utils/contest_formatting.dart';

/// The small pill that says where a contest is: accent with a blinking dot
/// while voting, ink "RESULTS IN" once finished, quiet "opens in" while
/// scheduled — scheduled is never live, whatever `opens_at` says, because only
/// an organizer opens a contest. Same shape as [MapEventStatusChip].
class ContestStatusChip extends StatelessWidget {
  final ContestEntity contest;
  final DateTime now;
  final bool small;

  const ContestStatusChip({
    super.key,
    required this.contest,
    required this.now,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final live = contest.isOpen;
    final (bg, fg) = contest.isFinished
        ? (AppColors.ink, AppColors.inkPanel)
        : live
            ? (AppColors.accent, Colors.white)
            : (AppColors.bg, AppColors.mute);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            const LiveDot(),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              ContestFormat.chipLabel(l10n, contest, now).toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: small ? 9 : 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pulsing dot that marks "live". Honours reduced-motion: with animations
/// disabled it's a plain dot.
class LiveDot extends StatefulWidget {
  final Color color;
  final double size;

  const LiveDot({super.key, this.color = Colors.white, this.size = 5});

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.25).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

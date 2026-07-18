import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/app_shimmer.dart';
import '../../../../../core/theme/app_colors.dart';

/// Skeleton placeholder shown while a conversation's history loads. Mirrors
/// the transcript with alternating incoming / outgoing bubble stubs, using the
/// same static skeleton style as the forums screen.
class ChatLoadingView extends StatelessWidget {
  const ChatLoadingView({super.key});

  // A representative run of bubbles: (isMine, widthFactor).
  static const _bubbles = <(bool, double)>[
    (false, 0.55),
    (false, 0.35),
    (true, 0.5),
    (false, 0.62),
    (true, 0.4),
    (true, 0.58),
    (false, 0.3),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        // Reversed like the real transcript so bubbles sit at the bottom.
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          for (final (isMine, widthFactor) in _bubbles.reversed)
            _BubbleSkeleton(isMine: isMine, widthFactor: widthFactor),
        ],
      ),
    );
  }
}

class _BubbleSkeleton extends StatelessWidget {
  final bool isMine;
  final double widthFactor;

  const _BubbleSkeleton({required this.isMine, required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: FractionallySizedBox(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          widthFactor: widthFactor,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.line2,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

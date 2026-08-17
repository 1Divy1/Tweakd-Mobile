import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// The board header: an accent eyebrow over the "Feedback" title, with the
/// accent "+ NEW" compose button on the right.
class FeedbackFeedTopBar extends StatelessWidget {
  final VoidCallback onCompose;

  const FeedbackFeedTopBar({super.key, required this.onCompose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 2,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.feedbackFeedEyebrow,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.feedbackFeedTitle,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ComposeButton(label: l10n.feedbackFeedNew, onTap: onCompose),
        ],
      ),
    );
  }
}

class _ComposeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ComposeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF4D00),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

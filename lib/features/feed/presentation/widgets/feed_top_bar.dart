import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// The feed's top bar: the "Tweakd." wordmark on the left and the likes /
/// direct-messages pill buttons on the right. Those two destinations don't
/// exist yet, so the buttons are UI-only and surface a "coming soon" notice.
class FeedTopBar extends StatelessWidget {
  const FeedTopBar({super.key});

  void _comingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.feedComingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          // Brand wordmark — "Tweakd" with an accent full stop.
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: 'Tweakd'),
                TextSpan(text: '.', style: TextStyle(color: AppColors.accent)),
              ],
            ),
          ),
          const Spacer(),
          _PillButton(
            icon: Icons.favorite_border_rounded,
            onTap: () => _comingSoon(context),
          ),
          const SizedBox(width: 10),
          _PillButton(
            icon: Icons.mode_comment_outlined,
            onTap: () => _comingSoon(context),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PillButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, color: AppColors.ink, size: 22),
      ),
    );
  }
}

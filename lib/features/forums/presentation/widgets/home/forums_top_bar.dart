import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../shared/forum_pill_button.dart';

/// Forums home header: browse button, "Forums / Your paddock" title, and the
/// new-thread button.
class ForumsTopBar extends StatelessWidget {
  final VoidCallback onBrowse;
  final VoidCallback onNewThread;

  const ForumsTopBar({
    super.key,
    required this.onBrowse,
    required this.onNewThread,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          ForumPillButton(icon: Icons.explore_outlined, onTap: onBrowse),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.forumsTitle,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.forumsSubtitle,
                  style: const TextStyle(
                    color: AppColors.mute,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ForumPillButton(icon: Icons.add_rounded, onTap: onNewThread),
        ],
      ),
    );
  }
}
